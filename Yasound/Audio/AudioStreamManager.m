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
    if ([radio.id intValue]  == [self.currentRadio.id intValue])
        return;
    
    
    if (_gAudioStreamer != nil)
    {
        [[YasoundDataProvider main] stopListeningRadio:self.currentRadio];
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
    
    
    
    _gAudioStreamer = [[AudioStreamer alloc] initWithURL:radiourl];
    //LBDEBUG DEBUG TODO : UNMUTE RADIO
    [_gAudioStreamer start];
    [[YasoundDataProvider main] startListeningRadio:self.currentRadio];

}

- (void)stopRadio
{
    if (_gAudioStreamer == nil)
        return;

    [[YasoundDataProvider main] stopListeningRadio:self.currentRadio];
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
//    [[YasoundDataProvider main] stopListeningRadio:self.currentRadio];
//}


- (void)playRadio
{
    if (_gAudioStreamer == nil)
        return;


    //LBDEBUG DEBUG TODO : UNMUTE RADIO
    [_gAudioStreamer start];
    [[YasoundDataProvider main] startListeningRadio:self.currentRadio];
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
  [self pauseAudio];
}

- (void) endInterruptionWithFlags: (NSUInteger) flags
{
  if (flags & AVAudioSessionInterruptionFlags_ShouldResume)
  {
    [self playAudio];    
  }
}






@end