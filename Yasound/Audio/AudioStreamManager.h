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
#import "Radio.h"

#define NOTIF_AUDIOSTREAM_PLAY @"NOTIF_AudioStream_play"
#define NOTIF_AUDIOSTREAM_STOP @"NOTIF_AudioStream_stop"

@interface AudioStreamManager : NSObject

@property (retain) Radio* currentRadio;


+ (AudioStreamManager*) main;

- (void)startRadio:(Radio*)radio;
- (void)stopRadio;

//- (void)pauseRadio;
- (void)playRadio;
- (void)togglePlayPauseRadio;


@end






