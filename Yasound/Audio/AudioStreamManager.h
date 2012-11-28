//
//  AudioStreamManager.h
//  yasound
//
//  Created by LOIC BERTHELOT on 01/2012
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

// a simple front-end to handle the calls to AudioStream and server notifications

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YasoundRadio.h"

#define NOTIF_AUDIOSTREAM_PLAY @"NOTIF_AudioStream_play"
#define NOTIF_AUDIOSTREAM_STOP @"NOTIF_AudioStream_stop"

@interface AudioStreamManager : NSObject
{
    NSInteger _streamErrorCount;
    NSTimer* _streamErrorTimer;
    BOOL _reseting;
}

@property (retain) YasoundRadio* currentRadio;
@property (nonatomic, readonly) BOOL isPaused;

+ (AudioStreamManager*) main;

- (void)startRadio:(YasoundRadio*)radio;
- (void)stopRadio;

- (void)tryAndRestartOnError;

- (void)playRadio;
- (void)togglePlayPauseRadio;


@end






