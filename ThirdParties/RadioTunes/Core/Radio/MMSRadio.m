//
//  MMSRadio.m
//  Radio
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import "MMSRadio.h"
#import "avcodec.h"
#import "avformat.h"
#import "AudioPacket.h"
#import "Reachability.h"

@interface MMSRadio() {
    dispatch_queue_t _decodeQueue;
    
    AVFormatContext *_formatCtx;
    AVCodecContext *_codecCtx;
    
    int _audioStreamID;
    BOOL _connected;
    BOOL _decodeError;
	UInt16 *_decodeBuffer;
    
}

- (void)handlePlayCallback:(AudioQueueRef)inAudioQueue buffer:(AudioQueueBufferRef) inBuffer;
- (void)onReachabilityChanged:(NSNotification *)notification;
- (void)connect;
- (void)startDecoding;
- (void)setupQueue;
- (void)dismissQueue;
- (void)primeQueueBuffers;
- (void)startQueue;
- (void)setState:(RadioState) state;
- (void)cleanup;
- (void)startBufferTimerWithTimeout:(NSInteger)timeout;
- (void)startReconnectTimerWithTimeout:(NSInteger)timeout;
- (void)stopBufferTimer;
- (void)stopReconnectTimer;
- (void)onBufferTimerFired:(NSTimer *)timer;
- (void)onReconnectTimerFired:(NSTimer *)timer;
- (void)onBackground:(NSNotification *)notification;
- (void)onForeground:(NSNotification *)notification;
@end

int QuitDecoding = 0;

static void MMSPlayCallback(void *inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer) {
    MMSRadio *radio = (MMSRadio *)inUserData;
    [radio handlePlayCallback:inAudioQueue buffer:inBuffer];
}

static int DecodeInterruptCallback(void *data) {
    return QuitDecoding;
}

static const AVIOInterruptCB int_cb = {DecodeInterruptCallback, NULL };

@implementation MMSRadio

- (id)initWithURL:(NSURL *)url {
    if(![[url scheme] isEqualToString:@"mms"] &&
       ![[url scheme] isEqualToString:@"mmsh"]) {
        return nil;
    }
    
    NSURL *newURL;
    if([[url scheme] isEqualToString:@"mmsh"]) {
        newURL = url;
    } else {
        NSString *urlString = [url description];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"mms://" withString:@"mmst://"];
        newURL = [NSURL URLWithString:urlString];
    }
    
    self = [super initWithURL:newURL];
    if(self) {
        _decodeQueue = dispatch_queue_create("decodeQueue", NULL);
        
        _formatCtx = NULL;
        _codecCtx = NULL;
        _audioStreamID = -1;
        _connected = NO;
        _decodeError = NO;
		
		_decodeBuffer = malloc(AVCODEC_MAX_AUDIO_FRAME_SIZE);
		memset(_decodeBuffer, 0, AVCODEC_MAX_AUDIO_FRAME_SIZE);
		
        static BOOL ffmpegInitialized = NO;
        if(!ffmpegInitialized) {
            ffmpegInitialized = YES;
            avformat_network_init();
            av_register_all();
        }
        
        _playerState.audioFormat.mFormatID = kAudioFormatLinearPCM;
        _playerState.audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        AudioSessionSetActive(true);
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    dispatch_release(_decodeQueue);
    
    
    if(_codecCtx) {
        avcodec_close(_codecCtx);
    }
    if(_formatCtx) {
        avformat_close_input(&_formatCtx);
    }
    
    free(_decodeBuffer);
    
    [super dealloc];
}

- (void)shutdown {
    _shutdown = YES;
    if(!_playerState.paused) {
        [self pause];
    }
    
    [self retain];
    dispatch_async(_decodeQueue, ^{
        [self cleanup];
    });
}

- (void)play {
    if(_playerState.playing) {
        return;
    }
    
    QuitDecoding = 0;
    _decodeError = NO;
    _connectionError = NO;
    _waitingForReconnection = NO;
    _buffersInUse = 0;
    
    if(!_connected) {
        [self setState:kRadioStateConnecting];
        [self connect];
    } else {
        if(_shutdown) {
            DLog(@"we're shutting down");
            return;
        }
        
        [self setState:kRadioStateBuffering];
        _playerState.paused = NO;
        _playerState.playing = YES;
        
        _playerState.audioFormat.mSampleRate = _codecCtx->sample_rate;
        _playerState.audioFormat.mChannelsPerFrame = _codecCtx->channels;
        _playerState.audioFormat.mBitsPerChannel = 16;
        //_playerState.audioFormat.mFramesPerPacket = _codecCtx->frame_size;
        _playerState.audioFormat.mFramesPerPacket = 1;
        _playerState.audioFormat.mBytesPerFrame = _playerState.audioFormat.mChannelsPerFrame * _playerState.audioFormat.mBitsPerChannel/8; 
        _playerState.audioFormat.mBytesPerPacket = _playerState.audioFormat.mBytesPerFrame * _playerState.audioFormat.mFramesPerPacket;
        // calculate buffer size so that there is 0.5 seconds of data in one buffer
        int packetsForTime = (_playerState.audioFormat.mSampleRate / _playerState.audioFormat.mFramesPerPacket) * 0.5;
        _playerState.bufferSize = packetsForTime * _playerState.audioFormat.mBytesPerPacket;

        if(_reachability == nil) {
            _reachability = [[Reachability reachabilityForInternetConnection] retain];
            [_reachability startNotifier];
        }
        
        NetworkStatus status = [_reachability currentReachabilityStatus];
        if(status == ReachableViaWWAN) {
            _connectionType = kRadioConnectionTypeWWAN;
        } else if(status == ReachableViaWiFi) {
            _connectionType = kRadioConnectionTypeWiFi;
        }

        
        [self setupQueue];
        [self startDecoding];
    }
}

- (void)pause {
    if(_playerState.paused) {
        return;
    }
    
    _playerState.playing = NO;
    _playerState.paused = YES;
    
    QuitDecoding = 1;
    _connected = NO;
    
    if(_playerState.started) {
        [self dismissQueue];
        _playerState.started = NO;
        _playerState.totalBytes = 0.0;
        
        dispatch_sync(_playerState.lockQueue, ^(void) {
            [_playerState.audioQueue removeAllPackets];
        });
    }
    
    [self stopBufferTimer];
    [self stopReconnectTimer];
    
    if(_reachability) {
        [_reachability stopNotifier];
        [_reachability release];
        _reachability = nil;
    }
    
    if(_decodeError) {
        _radioError = kRadioErrorDecoding;
        [self setState:kRadioStateError];
    } else if(_connectionError) {
        if(!_waitingForReconnection) {
            // start reconnect timer and wait 60 seconds for new connection notification from reachability
            // if we can't establish a new connection within 60 seconds we'll enter the error state
            // and inform the UI about the network connection error.
            _waitingForReconnection = YES;
            [self setState:kRadioStateBuffering];
            
            [self startReconnectTimerWithTimeout:60];
            if(_reachability == nil) {
                _reachability = [[Reachability reachabilityForInternetConnection] retain];
                [_reachability startNotifier];
            }
            
            NetworkStatus status = [_reachability currentReachabilityStatus];
            if(status == ReachableViaWiFi || status == ReachableViaWWAN) {
                [self stopReconnectTimer];
                DLog(@"Reconnecting to radio stream");
                // allow FFmpeg to clean up and start playing again after 1 second
                [self performSelector:@selector(play) withObject:nil afterDelay:1.0];
            }
        } else {
            _radioError = kRadioErrorNetworkError;
            [self setState:kRadioStateError];
        }
    } else {
        [self setState:kRadioStateStopped];
    }
}


#pragma mark -
#pragma mark Private Methods
- (void)handlePlayCallback:(AudioQueueRef) inAudioQueue buffer:(AudioQueueBufferRef) inBuffer {
    if(_playerState.paused) {
        return;
    }
    
    __block int maxBytes = inBuffer->mAudioDataBytesCapacity;
    __block int dataWritten = 0;
    inBuffer->mAudioDataByteSize = 0;
    
    dispatch_sync(_playerState.lockQueue, ^(void) {
        @autoreleasepool {
            AudioPacket *audioPacket = [_playerState.audioQueue peak];
            while(audioPacket) {
                if((dataWritten + [audioPacket remainingLength]) > maxBytes) {
                    int dataNeeded = (maxBytes - dataWritten);
                    [audioPacket copyToBuffer:(inBuffer->mAudioData+dataWritten) size:dataNeeded];
                    dataWritten += dataNeeded;
                    break;
                } else {
                    int dataNeeded = [audioPacket remainingLength];
                    [audioPacket copyToBuffer:(inBuffer->mAudioData+dataWritten) size:dataNeeded];
                    
                    audioPacket = [_playerState.audioQueue pop];
                    [audioPacket release];
                    dataWritten += dataNeeded;
                    audioPacket = [_playerState.audioQueue peak];
                }
            }
            
            // buffer was used previously
            _buffersInUse--;
            
            inBuffer->mAudioDataByteSize = dataWritten;
            if(inBuffer->mAudioDataByteSize > 0) {
                OSStatus result = AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, 0, NULL);
                if(result != noErr) {
                    DLog(@"could not enqueue buffer");
                    
                    _radioError = kRadioErrorAudioQueueEnqueue;
                    [self setState:kRadioStateError];
                } else {
                    _buffersInUse++;
                    if(_playerState.buffering && (_buffersInUse >= (NUM_AQ_BUFS - 1))) {
                        DLog(@"start playback again, buffers filled up again and ready to go");
                        _playerState.buffering = NO;
                        
                        [self stopBufferTimer];
                        [self primeQueueBuffers];
                        [self startQueue];
                    }
                }
            }
            
            
            if(_buffersInUse == 0 && !_playerState.buffering) {
                DLog(@"all buffers empty, buffering");
                AudioQueuePause(inAudioQueue);
                
                _playerState.totalBytes = 0.0;
                _playerState.buffering = YES;
                [self setState:kRadioStateBuffering];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startBufferTimerWithTimeout:10];
                });                
            }
        }
    });
}

- (void)onReachabilityChanged:(NSNotification *)notification {
    if(_reachability) {
        if(_playerState.started && ![_reachability isReachable]) {
            UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
            if(appState == UIApplicationStateBackground || appState == UIApplicationStateInactive) {
                DLog(@"connection dropped while radio is in background");
                if(_bgTask == UIBackgroundTaskInvalid) {
                    _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(_bgTask != UIBackgroundTaskInvalid) {
                                [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                                _bgTask = UIBackgroundTaskInvalid;
                            }
                        });
                    }];
                }
            }
        }
        
        if([_reachability isReachable]) {
            if(_waitingForReconnection) {
                [self stopReconnectTimer];
                DLog(@"Reconnecting to radio stream");
                [self play];
            } else if(_playerState.playing && _connectionType == kRadioConnectionTypeWWAN) {
                // Check if we are now connected via WiFi and change to WiFi if so
                NetworkStatus status = [_reachability currentReachabilityStatus];
                if(status == ReachableViaWiFi) {
                    DLog(@"Switching back to WiFi");
                    _connectionError = YES;
                    [self pause];
                }
            }
        }
    }
}

- (void)connect {
    if(_connected) {
        return;
    }
    
    dispatch_async(_decodeQueue, ^(void) {
        @autoreleasepool {
            const char *url = [[_url description] cStringUsingEncoding:NSUTF8StringEncoding];
            
            if(avformat_open_input(&_formatCtx, url, NULL, NULL) != 0) {
                // if current scheme is mmst then try again with scheme mmsh (will use port 80)
                if([[_url scheme] isEqualToString:@"mmst"]) {
                    DLog(@"Trying again with scheme mmsh (por 80)");
                    NSString *urlString = [_url description];
                    urlString = [urlString stringByReplacingOccurrencesOfString:@"mmst://" withString:@"mmsh://"];
                    NSURL *newURL = [NSURL URLWithString:urlString];
                    
                    url = [[newURL description] cStringUsingEncoding:NSUTF8StringEncoding];
                    if(avformat_open_input(&_formatCtx, url, NULL, NULL) != 0) {
                        DLog(@"FFMPEG cannot open stream");
                        _radioError = kRadioErrorFileStreamOpen;
                        [self setState:kRadioStateError];
                        return;
                    }
                } else {
                    DLog(@"FFMPEG cannot open stream");
                    _radioError = kRadioErrorFileStreamOpen;
                    [self setState:kRadioStateError];
                    return;
                }
            }
            
            DLog(@"FFMPEG connected to stream: %@", [_url scheme]);
            if(avformat_find_stream_info(_formatCtx, NULL) < 0) {
                DLog(@"Cannot find stream info");
                _radioError = kRadioErrorFileStreamOpen;
                [self setState:kRadioStateError];
                return;
            }
            
            for(int i = 0; i < _formatCtx->nb_streams; i++ ) {
                if(_formatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO) {
                    _audioStreamID = i;
                    break;
                }
            }
            
            if(_audioStreamID == -1) {
                DLog(@"Audio stream not found");
                _radioError = kRadioErrorFileStreamOpen;
                [self setState:kRadioStateError];
                return;
            }
            
            _codecCtx = _formatCtx->streams[_audioStreamID]->codec;
            AVCodec *codec = avcodec_find_decoder(_codecCtx->codec_id);
            if(!codec) {
                DLog(@"Cannot find codec");
                _radioError = kRadioErrorFileStreamOpen;
                [self setState:kRadioStateError];
                return;
            }
            
            int s = avcodec_open2(_codecCtx, codec, NULL);
            if(s < 0) {
                NSLog(@"Cannot open codec");
                _radioError = kRadioErrorFileStreamOpen;
                [self setState:kRadioStateError];
                return;
            }
            
            _connected = YES;
            
            DLog(@"Codec opened: %@ - %@", [NSString stringWithUTF8String:codec->name], [NSString stringWithUTF8String:codec->long_name]);
            DLog(@"sample rate: %d", _codecCtx->sample_rate);
            DLog(@"channels: %d", _codecCtx->channels);
            DLog(@"frames per packet: %d", _codecCtx->frame_size);
            
            _formatCtx->interrupt_callback = int_cb;
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self play];
            });
        }
    });
}

- (void)startDecoding {
    dispatch_async(_decodeQueue, ^(void) {
        @autoreleasepool {
            AVPacket packet;
            int last_packet = 0;
            int decodeErrorCount = 0;
            
            if(_shutdown) {
                DLog(@"we're shutting down");
                return;
            }
            
            do {
                do {
                    if(av_read_frame(_formatCtx, &packet) < 0) {
                        last_packet = 1;
                    }
                    
                    if(packet.stream_index != _audioStreamID) {
                        av_free_packet(&packet);
                    }
                } while (packet.stream_index != _audioStreamID && !last_packet);
                
                // do not try to decode the last packet if it's not from this stream
                if(last_packet && (packet.stream_index != _audioStreamID)) {
                    break;
                }
                
                UInt8 *packetPtr = packet.data;
                int bytes_remaining = packet.size;
                int dataSize;
                int decodedSize;
                
                while(bytes_remaining > 0 && !_playerState.paused) {
                    int got_frame = 0;
                    AVFrame decoded_frame;

                    decodedSize = avcodec_decode_audio4(_codecCtx, &decoded_frame, &got_frame, &packet);
                    
                    if(decodedSize < 0) {
                        packet.size = 0;
                        decodeErrorCount++;
                        if(decodeErrorCount > 4) {
                            _decodeError = YES;
                            [self pause];
                        }
                        
                        break;
                    }
                    
                    bytes_remaining -= decodedSize;
                    packetPtr += decodedSize;
                    
                    if(got_frame == 0) {
                        continue;
                    }
                    
                    int ch, plane_size;
                    int planar = av_sample_fmt_is_planar(_codecCtx->sample_fmt);
                    dataSize = av_samples_get_buffer_size(&plane_size, _codecCtx->channels, decoded_frame.nb_samples, _codecCtx->sample_fmt, 1);
                    
                    memcpy(_decodeBuffer, decoded_frame.extended_data[0], plane_size);
                    if(planar && _codecCtx->channels > 1) {
                        uint8_t *out = ((uint8_t *)_decodeBuffer) + plane_size;
                        for(ch = 1; ch < _codecCtx->channels; ch++) {
                            memcpy(out, decoded_frame.extended_data[ch], plane_size);
                            out += plane_size;
                        }
                    }
                    
                    _playerState.totalBytes += dataSize;
                    
                    dispatch_sync(_playerState.lockQueue, ^(void) {
                        NSData *data = [[NSData alloc] initWithBytes:_decodeBuffer length:dataSize];
                        AudioPacket *audioPacket = [[AudioPacket alloc] initWithData:data];
                        [_playerState.audioQueue addPacket:audioPacket];
                        [data release];
                        [audioPacket release];
                    });
                    
                    if(!_playerState.started && 
                       !_playerState.paused &&
                       !_shutdown &&
                       _playerState.totalBytes > (_playerState.bufferInSeconds * _playerState.bufferSize)) {
                        DLog(@"starting playback");
                        _playerState.buffering = NO;
                        
                        [self primeQueueBuffers];
                        [self startQueue];
                    }
                    
                    // enqueue audio buffers again after buffering
                    if(_playerState.started &&
                       !_playerState.paused &&
                       _playerState.buffering &&
                       !_shutdown &&
                       _playerState.totalBytes > (_playerState.bufferInSeconds * _playerState.bufferSize)) {
                        DLog(@"starting playback again");
                        _playerState.buffering = NO;
                        
                        [self stopBufferTimer];
                        [self primeQueueBuffers];
                        [self startQueue];
                    }
                }
                
                if(packet.data) {
                    av_free_packet(&packet);
                }
            } while (!last_packet && !_playerState.paused);
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                DLog(@"connection dropped");
                _connected = NO;
                
                if(_codecCtx) {
                    avcodec_close(_codecCtx);
                    _codecCtx = NULL;
                }
                
                if(_formatCtx) {
                    avformat_close_input(&_formatCtx);
                    _formatCtx = NULL;
                }
            });
        }
    });
}

- (void)setupQueue {
    if(_playerState.queue == NULL) {
        AudioSessionSetActive(true);
        
        // create audio queue
        OSStatus err = AudioQueueNewOutput(&_playerState.audioFormat, MMSPlayCallback, self, NULL, kCFRunLoopCommonModes, 0, &_playerState.queue);
        if(err != noErr) {
            DLog(@"audio queue could not be created");
            _radioError = kRadioErrorAudioQueueCreate;
            [self setState:kRadioStateError];
            return;
        }
        
        // create audio buffers
        for(int t = 0; t < NUM_AQ_BUFS; ++t) {
            err = AudioQueueAllocateBuffer(_playerState.queue, _playerState.bufferSize, &_playerState.queueBuffers[t]);
            if(err) {
                DLog(@"Error: AudioQueueAllocateBuffer %ld", err);
                _radioError = kRadioErrorAudioQueueBufferCreate;
                [self setState:kRadioStateError];
                return;
            }
        }
    }
}

- (void)dismissQueue {
    if(_playerState.queue) {
        if(_playerState.playing) {
            AudioQueueStop(_playerState.queue, YES);
            _playerState.playing = NO;
        }
        
        AudioQueueDispose(_playerState.queue, YES);
        _playerState.queue = NULL;
        
        AudioSessionSetActive(false);
    }
}

- (void)primeQueueBuffers {
    _buffersInUse = NUM_AQ_BUFS;
    for(int t = 0; t < NUM_AQ_BUFS; ++t) {
        MMSPlayCallback(self, _playerState.queue, _playerState.queueBuffers[t]);
	}
}

- (void)startQueue {
    AudioQueueSetParameter(_playerState.queue, kAudioQueueParam_Volume, _playerState.gain);
    OSStatus result = AudioQueueStart(_playerState.queue, NULL);
    if(result == noErr) {
        _playerState.started = YES;
        _playerState.playing = YES;
        
        [self setState:kRadioStatePlaying];
    } else {
        _radioError = kRadioErrorAudioQueueStart;
        [self setState:kRadioStateError];
    }
}
         
 - (void)setState:(RadioState)state {
     if(state == _radioState) {
         return;
     }
     
     _radioState = state;
     if(_radioState == kRadioStateError) {
         _playerState.playing = NO;
         _playerState.paused = NO;
         _playerState.buffering = NO;
         _playerState.started = NO;
         _playerState.totalBytes = 0.0;
         
         if(_playerState.queue) {
             if(_playerState.playing) {
                 AudioQueueStop(_playerState.queue, YES);
                 _playerState.playing = NO;
             }
             
             AudioQueueDispose(_playerState.queue, YES);
             _playerState.queue = NULL;
             
             AudioSessionSetActive(false);
         }
     }
     
     dispatch_async(dispatch_get_main_queue(), ^(void) {
         if(_delegate && [_delegate respondsToSelector:@selector(radioStateChanged:)]) {
             [_delegate radioStateChanged:self];
         }
     });
     
     if(_radioState == kRadioStatePlaying || _radioState == kRadioStateError) {
         if(_bgTask) {
             DLog(@"Ending background task");
             [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
             _bgTask = UIBackgroundTaskInvalid;
         }
     }
 }

- (void)cleanup {
    [self release];
}

- (void)startBufferTimerWithTimeout:(NSInteger)timeout {
    [self stopBufferTimer];
    
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    if(appState == UIApplicationStateBackground || appState == UIApplicationStateInactive) {
        DLog(@"Starting buffer timer in background");
        if(_bgTask == UIBackgroundTaskInvalid) {
            _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_bgTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                        _bgTask = UIBackgroundTaskInvalid;
                    }
                });
            }];
        }
    }
    
    DLog(@"Starting buffer timer with timeout: %d", timeout);
    _bufferTimer = [[NSTimer scheduledTimerWithTimeInterval:timeout 
                                                     target:self 
                                                   selector:@selector(onBufferTimerFired:) 
                                                   userInfo:nil 
                                                    repeats:NO] retain];
}

- (void)startReconnectTimerWithTimeout:(NSInteger)timeout {
    [self stopReconnectTimer];
    
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    if(appState == UIApplicationStateBackground || appState == UIApplicationStateInactive) {
        DLog(@"Starting reconnect timer in background");
        if(_bgTask == UIBackgroundTaskInvalid) {
            _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_bgTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                        _bgTask = UIBackgroundTaskInvalid;
                    }
                });
            }];
        }
    }
    
    DLog(@"Starting reconnect timer with timeout: %d", timeout);
    _reconnectTimer = [[NSTimer scheduledTimerWithTimeInterval:timeout
                                                        target:self
                                                      selector:@selector(onReconnectTimerFired:)
                                                      userInfo:nil
                                                       repeats:NO] retain];
}

- (void)stopBufferTimer {
    if(_bufferTimer) {
        DLog(@"Stopping buffer timer");
        [_bufferTimer invalidate];
        [_bufferTimer release];
        _bufferTimer = nil;
    }
}

- (void)stopReconnectTimer {
    if(_reconnectTimer) {
        DLog(@"Stopping reconnect timer");
        [_reconnectTimer invalidate];
        [_reconnectTimer release];
        _reconnectTimer = nil;
    }
}

- (void)onBufferTimerFired:(NSTimer *)timer {
    [_bufferTimer release];
    _bufferTimer = nil;
    
    if(_reachability == nil) {
        _reachability = [[Reachability reachabilityForInternetConnection] retain];
        [_reachability startNotifier];
    }
    
    _connectionError = YES;
    [self pause];
}

- (void)onReconnectTimerFired:(NSTimer *)timer {
    [_reconnectTimer release];
    _reconnectTimer = nil;
    
    _connectionError = YES;
    [self pause];
}


- (void)onBackground:(NSNotification *)notification {
    if(_radioState == kRadioStateConnecting || _radioState == kRadioStateBuffering) {
        DLog(@"radio is buffering while entering background");
        if(_bgTask == UIBackgroundTaskInvalid) {
            _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_bgTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                        _bgTask = UIBackgroundTaskInvalid;
                    }
                });
            }];
        }
    }
}

- (void)onForeground:(NSNotification *)notification {
    if(_bgTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:_bgTask];
		_bgTask = UIBackgroundTaskInvalid;
	}
}

@end
