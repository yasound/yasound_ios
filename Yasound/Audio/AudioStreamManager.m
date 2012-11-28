//
//  AudioStreamManager.m
//  yasound
//
//  Created by LOIC BERTHELOT on 01/2012
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioStreamManager.h"
#import "AudioStreamer.h"
#import "YasoundDataProvider.h"
#import "YasoundSessionManager.h"
#import "Radio.h"
#import "HTTPRadio.h"
#import "MMSRadio.h"

//#define USE_FAKE_RADIO_URL 1

@implementation AudioStreamManager

@synthesize currentRadio;
@synthesize isPaused = _isPaused;



#ifdef USE_DEV_SERVER
#define ASLog( s, ... )
#else
#define ASLog( s, ... ) DLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#endif



static AudioStreamManager* _main = nil;

static Radio *_gRadio = nil;

+ (AudioStreamManager*) main
{
    if (_main == nil)
    {
        _main = [[AudioStreamManager alloc] init];
    }
    
    return _main;
}




- (id)init
{
    if (self = [super init])
    {
        self.currentRadio = nil;
        _isPaused = NO;
        _reseting = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_ERROR object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamMyReset:) name:NOTIF_AUDIOSTREAM_RESET object:nil];
    }
    
    return self;
}


- (void)startRadio:(YasoundRadio*)radio
{
    if (radio == nil)
        return;

    if ((_streamErrorTimer != nil) && [_streamErrorTimer isValid])
    {
        [_streamErrorTimer invalidate];
        _streamErrorTimer = nil;
    }
    
    [self _startRadio:radio];
}


- (void)_startRadio:(YasoundRadio*)radio
{
#if MUTE_RADIO
    return;
#endif
    
//#ifdef USE_DEV_SERVER
//    return;
//#endif
    
    if (radio == nil)
        return;

    if (!_reseting && (_gRadio && ([radio.id intValue]  == [self.currentRadio.id intValue])))
        return;
    
    _isPaused = NO;
    _reseting = NO;
    
    if (_gRadio != nil)
    {
        [_gRadio shutdown];
        [_gRadio release];
        _gRadio = nil;
    }

    self.currentRadio = radio;
    
    // save the current radio reference in the user defaults
    // to retrieve it when the app starts
    [[UserSettings main] setObject:self.currentRadio.id forKey:USKEYnowPlaying];

    NSString* url = radio.stream_url;
    
    // add HD param if it's requested
    NSURL* radiourl = [NSURL URLWithString:url];
  
    if ([YasoundSessionManager main].registered)
    {
        [[YasoundDataProvider main] streamingAuthenticationTokenWithTarget:self action:@selector(receivedStreamingAuthToken:success:) userData:radiourl];
    }
    else
    {
        DLog(@"radio url: %@\n", radiourl);
        [self startStreamerWithURL:radiourl];
    }
}

- (void)startStreamerWithURL:(NSURL*)radioUrl
{
    NSString *radioUrlString = [radioUrl absoluteString];
    if([radioUrlString hasPrefix:@"mms"])
    {
        _gRadio = [[MMSRadio alloc] initWithURL:radioUrl];
    }
    else
    {
        _gRadio = [[HTTPRadio alloc] initWithURL:radioUrl];
    }
    
    if(_gRadio)
    {
        [_gRadio setDelegate:self];
        [_gRadio play];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_PLAY object:nil];
}

- (void)receivedStreamingAuthToken:(ASIHTTPRequest*)req success:(BOOL)success
{
    NSURL* radioUrl = (NSURL*)req.userData;
    NSDictionary* responseDict = [req responseDict];

    NSString* paramStr = radioUrl.parameterString;
    NSString* urlStr = radioUrl.absoluteString;
    NSString* finalUrlStr = urlStr;

    NSLog(@"radio origin '%@'", self.currentRadio.origin);
    
    if ([self.currentRadio.origin integerValue] == eRadioOriginYasound) {
        
        NSString* token = [responseDict valueForKey:@"token"];
        if (!token)
            return;
        
        if (paramStr)
        {
            finalUrlStr = [finalUrlStr stringByAppendingFormat:@"&token=%@", token];
        }
        else
        {
            finalUrlStr = [finalUrlStr stringByAppendingFormat:@"/?token=%@", token];
        }
        
        BOOL hdPermission = [[YasoundDataProvider main].user permission:PERM_HD];
        BOOL hdRequest = [[UserSettings main] boolForKey:USKEYuserWantsHd error:nil];

        if (hdPermission && hdRequest)
        {
            finalUrlStr = [finalUrlStr stringByAppendingString:@"&hd=1"];
        }
    }
    
    NSURL* finalRadioUrl = [NSURL URLWithString:finalUrlStr];
    
    DLog(@"radio authenticated url: %@\n", finalRadioUrl);

    [self startStreamerWithURL:finalRadioUrl];
}

- (void)stopRadio
{
    if ((_streamErrorTimer != nil) && [_streamErrorTimer isValid])
    {
        [_streamErrorTimer invalidate];
        _streamErrorTimer = nil;
    }
    
    [self _stopRadioWithNotification:YES];
}


- (void)_stopRadioWithNotification:(BOOL)withNotif
{
#if MUTE_RADIO
    return;
#endif
    
    if (_gRadio == nil)
        return;

    _isPaused = YES;
    
    [_gRadio shutdown];
    [_gRadio release];
    _gRadio = nil;
    
    if (withNotif)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_STOP object:nil];
    }
}



- (void)pauseRadio
{
    if (_gRadio == nil)
        return;
    
    _isPaused = YES;

    [_gRadio pause];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_STOP object:nil];
}



- (void)playRadio
{
#if MUTE_RADIO
    return;
#endif
    
    if (_gRadio == nil)
        return;

    _isPaused = NO;
    [_gRadio play];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_PLAY object:nil];
}

- (void)togglePlayPauseRadio
{
    if (_gRadio == nil)
    {
      [self startRadio:self.currentRadio];
      return;
    }

    RadioState state = [_gRadio radioState];
    if(state == kRadioStatePlaying)
    {
        [self pauseRadio];
    }
    else
    {
        [self playRadio];
    }
}


#pragma mark - AVAudioSession Delegate

- (void)beginInterruption
{
  [self stopRadio];
}

- (void) endInterruptionWithFlags: (NSUInteger) flags
{
  if (flags & AVAudioSessionInterruptionFlags_ShouldResume)
  {
    [self playAudio];    
  }
}











#define STREAM_ERROR_TIMER_PERIOD 5

- (void)onAudioStreamNotif:(NSNotification*)notif
{
    
    if ((_streamErrorTimer != nil) && [_streamErrorTimer isValid])
        return;

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DISPLAY_AUDIOSTREAM_ERROR object:nil];

    
    _streamErrorCount++;

    _streamErrorTimer = [NSTimer scheduledTimerWithTimeInterval:STREAM_ERROR_TIMER_PERIOD target:self selector:@selector(onStreamErrorHandling:) userInfo:nil repeats:NO];
    
}



- (void)onAudioStreamMyReset:(NSNotification*)notif
{
    DLog(@"onAudioStreamMyReset");
    
    YasoundRadio* radio = self.currentRadio;
    if (radio == nil)
        return;
    
    _reseting = YES;
    
    [self _startRadio:radio];
}






- (void)onStreamErrorHandling:(NSTimer*)timer
{
    [[AudioStreamManager main] _stopRadioWithNotification:NO];
    [[AudioStreamManager main] _startRadio:self.currentRadio];
    
    _streamErrorTimer = nil;
}

#pragma mark -
#pragma mark RadioDelegate Methods
- (void)radioStateChanged:(Radio *)radio
{
    RadioState state = [_gRadio radioState];
    if(state == kRadioStateConnecting) {
    } else if(state == kRadioStateBuffering) {
    } else if(state == kRadioStatePlaying) {
    } else if(state == kRadioStateStopped) {
    } else if(state == kRadioStateError) {
        RadioError error = [_gRadio radioError];
        if(error == kRadioErrorAudioQueueBufferCreate) {
            NSLog(@"Audio buffers could not be created.");
        } else if(error == kRadioErrorAudioQueueCreate) {
            NSLog(@"Audio queue could not be created.");
        } else if(error == kRadioErrorAudioQueueEnqueue) {
            NSLog(@"Audio queue enqueue failed.");
        } else if(error == kRadioErrorAudioQueueStart) {
            NSLog(@"Audio queue could not be started.");
        } else if(error == kRadioErrorFileStreamGetProperty) {
            NSLog(@"File stream get property failed.");
        } else if(error == kRadioErrorFileStreamOpen) {
            NSLog(@"File stream could not be opened.");
        } else if(error == kRadioErrorPlaylistParsing) {
            NSLog(@"Playlist could not be parsed.");
        } else if(error == kRadioErrorDecoding) {
            NSLog(@"Audio decoding error.");
        } else if(error == kRadioErrorHostNotReachable) {
            NSLog(@"Radio host not reachable.");
        } else if(error == kRadioErrorNetworkError) {
            NSLog(@"Network connection error.");
        }
    }
}

- (void)radioMetadataReady:(Radio *)radio
{
    NSString *radioName = [radio radioName];
    NSString *radioGenre = [radio radioGenre];
    NSString *radioUrl = [radio radioUrl];
    
    if(radioName) {
        NSLog(@"Radio name: %@", radioName);
    }
    
    if(radioGenre) {
        NSLog(@"Radio genre: %@", radioGenre);
    }
    
    if(radioUrl) {
        NSLog(@"Radio url: %@", radioUrl);
    }
}

- (void)radioTitleChanged:(Radio *)radio
{
}




@end