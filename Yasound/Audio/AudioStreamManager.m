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

static AudioStreamer* _gAudioStreamer = nil;


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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_ERROR object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamReset:) name:NOTIF_AUDIOSTREAM_RESET object:nil];
    }
    
    return self;
}


- (void)startRadio:(Radio*)radio
{
    if ((_streamErrorTimer != nil) && [_streamErrorTimer isValid])
    {
        [_streamErrorTimer invalidate];
        _streamErrorTimer = nil;
    }
    
    [self _startRadio:radio];
}


- (void)_startRadio:(Radio*)radio
{
#if MUTE_RADIO
    return;
#endif
    
#ifdef USE_DEV_SERVER
    return;
#endif
    
    if (_gAudioStreamer && [radio.id intValue]  == [self.currentRadio.id intValue])
        return;
    
    _isPaused = NO;
    
    if (_gAudioStreamer != nil)
    {
        [_gAudioStreamer stop];
        [_gAudioStreamer release];
    }

    self.currentRadio = radio;
    
    // save the current radio reference in the user defaults
    // to retrieve it when the app starts
    [[UserSettings main] setObject:self.currentRadio.id forKey:USKEYnowPlaying];

#if USE_FAKE_RADIO_URL || USE_YASOUND_LOCAL_SERVER
//    NSURL* radiourl = [NSURL URLWithString:@"http://api.yasound.com:8001/fakeid"];
    NSURL* radiourl = [NSURL URLWithString:@"http://localhost:8888/test.mp3"];
#else
  NSString* url = radio.stream_url;
    
    // add HD param if it's requested
    BOOL hdPermission = [[YasoundDataProvider main].user permission:PERM_HD];
    BOOL hdRequest = [[UserSettings main] boolForKey:USKEYuserWantsHd error:nil];

    
    NSURL* radiourl = [NSURL URLWithString:url];
#endif
    
    if ([YasoundSessionManager main].registered)
    {
        [[YasoundDataProvider main] streamingAuthenticationTokenWithTarget:self action:@selector(receivedStreamingAuthToken:success:) userData:radiourl];
    }
    else
    {
        DLog(@"radio url: %@\n", url);
        [self startStreamerWithURL:radiourl];
    }
}

- (void)startStreamerWithURL:(NSURL*)radioUrl
{
    NSString* cookie = [NSString stringWithFormat:@"username=%@; api_key=%@", [YasoundDataProvider username], [YasoundDataProvider user_apikey]];
    _gAudioStreamer = [[AudioStreamer alloc] initWithURL:radioUrl andCookie:cookie];
    [_gAudioStreamer start];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_PLAY object:nil];
}

- (void)receivedStreamingAuthToken:(ASIHTTPRequest*)req success:(BOOL)success
{
    NSURL* radioUrl = (NSURL*)req.userData;
    NSDictionary* responseDict = [req responseDict];
    NSString* token = [responseDict valueForKey:@"token"];
    if (!token)
        return;
    
    NSString* paramStr = radioUrl.parameterString;
    NSString* urlStr = radioUrl.absoluteString;
    NSString* finalUrlStr;
    if (paramStr)
    {
        finalUrlStr = [urlStr stringByAppendingFormat:@"&token=%@", token];
    }
    else
    {
        finalUrlStr = [urlStr stringByAppendingFormat:@"/?token=%@", token];
    }
    
    BOOL hdPermission = [[YasoundDataProvider main].user permission:PERM_HD];
    BOOL hdRequest = [[UserSettings main] boolForKey:USKEYuserWantsHd error:nil];

    if (hdPermission && hdRequest)
    {
        finalUrlStr = [finalUrlStr stringByAppendingString:@"&hd=1"];
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
    
    if (_gAudioStreamer == nil)
        return;

    _isPaused = YES;
    [_gAudioStreamer stop];
    [_gAudioStreamer release];
    _gAudioStreamer = nil;
    
    if (withNotif)
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_STOP object:nil];

}



- (void)pauseRadio
{
    if (_gAudioStreamer == nil)
        return;
    
    _isPaused = YES;

    //    [_gAudioStreamer pause];
    [_gAudioStreamer stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_STOP object:nil];
}



- (void)playRadio
{
#if MUTE_RADIO
    return;
#endif
    
    if (_gAudioStreamer == nil)
        return;

    _isPaused = NO;
    [_gAudioStreamer start];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_PLAY object:nil];
}

- (void)togglePlayPauseRadio
{
//  if (_gAudioStreamer == nil)
//    return;
  if (_gAudioStreamer == nil)
      [self startRadio:self.currentRadio];
       
  else
  
  if (_gAudioStreamer.state != AS_PLAYING)
      [self playRadio];
  else
    [self pauseRadio];
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



- (void)onAudioStreamReset:(NSNotification*)notif
{
    Radio* radio = self.currentRadio;
    self.currentRadio = nil;
    [self _startRadio:radio];
    
}






- (void)onStreamErrorHandling:(NSTimer*)timer
{
    [[AudioStreamManager main] _stopRadioWithNotification:NO];
    [[AudioStreamManager main] _startRadio:self.currentRadio];
    
    _streamErrorTimer = nil;
}



@end