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

@interface AudioStreamManager : NSObject

@property (retain) Radio* currentRadio;


+ (AudioStreamManager*) main;

- (void)startRadio:(Radio*)radio;
- (void)stopRadio;

//- (void)pauseRadio;
- (void)playRadio;
- (void)togglePlayPauseRadio;


@end






