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
#import "YaRadio.h"
#import "Radio.h"

#define NOTIF_AUDIOSTREAM_PLAY @"NOTIF_AudioStream_play"
#define NOTIF_AUDIOSTREAM_STOP @"NOTIF_AudioStream_stop"
#define NOTIF_AUDIOSTREAM_RESET @"NOTIF_AudioStream_reset"
#define NOTIF_AUDIOSTREAM_ERROR @"NOTIF_AudioStream_error"
#define NOTIF_DISPLAY_AUDIOSTREAM_ERROR @"NOTIF_DISPLAY_AudioStream_error"

@interface AudioStreamManager : NSObject<RadioDelegate>
{
    NSInteger _streamErrorCount;
    NSTimer* _streamErrorTimer;
    BOOL _reseting;
}

@property (retain) YaRadio* currentRadio;
@property (nonatomic, readonly) BOOL isPaused;

+ (AudioStreamManager*) main;

- (void)startRadio:(YaRadio*)radio;
- (void)stopRadio;
- (void)pauseRadio;

- (void)playRadio;
- (void)togglePlayPauseRadio;


@end






