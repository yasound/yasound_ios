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

#define USE_FAKE_RADIO_URL 0
#define MUTE_RADIO 1

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
    }
    
    return self;
}


- (void)startRadio:(Radio*)radio
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

#if USE_FAKE_RADIO_URL || USE_YASOUND_LOCAL_SERVER
    NSURL* radiourl = [NSURL URLWithString:@"http://dev.yasound.com:8001/fakeid"];
#else
    NSString* uuid = radio.uuid;
    NSString* url = [NSString stringWithFormat:@"http://dev.yasound.com:8001/%@", uuid];
    NSURL* radiourl = [NSURL URLWithString:url];
    NSLog(@"radio url: %@\n", url);
#endif
    
    
    
  User* u = [YasoundDataProvider main].user;
  NSString* cookie = [NSString stringWithFormat:@"username=%@; api_key=%@", u.username, u.api_key];
    _gAudioStreamer = [[AudioStreamer alloc] initWithURL:radiourl andCookie:cookie];
    [_gAudioStreamer start];

}

- (void)stopRadio
{
#if MUTE_RADIO
    return;
#endif
    
    if (_gAudioStreamer == nil)
        return;
    [_gAudioStreamer stop];
    [_gAudioStreamer release];
    _gAudioStreamer = nil;
    
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


    //LBDEBUG DEBUG TODO : UNMUTE RADIO
    [_gAudioStreamer start];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUDIOSTREAM_PLAY object:nil];
}

- (void)togglePlayPauseRadio
{
  if (_gAudioStreamer == nil)
    return;
  
  
  //LBDEBUG DEBUG TODO : UNMUTE RADIO
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






@end