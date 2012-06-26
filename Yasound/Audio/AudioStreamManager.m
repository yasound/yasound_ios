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

//#define USE_FAKE_RADIO_URL 1

@implementation AudioStreamManager

@synthesize currentRadio;



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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_ERROR object:nil];
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
    
    if (_gAudioStreamer && [radio.id intValue]  == [self.currentRadio.id intValue])
        return;
    
    
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
    NSURL* radiourl = [NSURL URLWithString:url];
    DLog(@"radio url: %@\n", url);
#endif
    
    
    
  User* u = [YasoundDataProvider main].user;
  NSString* cookie = [NSString stringWithFormat:@"username=%@; api_key=%@", u.username, u.api_key];
    _gAudioStreamer = [[AudioStreamer alloc] initWithURL:radiourl andCookie:cookie];
    [_gAudioStreamer start];

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
    [_gAudioStreamer stop];
    [_gAudioStreamer release];
    _gAudioStreamer = nil;
    
    if (withNotif)
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_STOP object:nil];

}



//- (void)pauseRadio
//{
//    if (_gAudioStreamer == nil)
//        return;
//
//    [_gAudioStreamer pause];
//}


- (void)playRadio
{
#if MUTE_RADIO
    return;
#endif
    
    if (_gAudioStreamer == nil)
        return;

    [_gAudioStreamer start];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_PLAY object:nil];
}

- (void)togglePlayPauseRadio
{
  if (_gAudioStreamer == nil)
    return;
  
  
  if (_gAudioStreamer.state != AS_PLAYING)
    [self playRadio];
  else
    [self stopRadio];
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

    DLog(@"onAudioStreamNotif");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DISPLAY_AUDIOSTREAM_ERROR object:nil];

    
    _streamErrorCount++;

    _streamErrorTimer = [NSTimer scheduledTimerWithTimeInterval:STREAM_ERROR_TIMER_PERIOD target:self selector:@selector(onStreamErrorHandling:) userInfo:nil repeats:NO];
    
}



- (void)onStreamErrorHandling:(NSTimer*)timer
{
    [[AudioStreamManager main] _stopRadioWithNotification:NO];
    [[AudioStreamManager main] _startRadio:self.currentRadio];
    
    _streamErrorTimer = nil;
}



@end