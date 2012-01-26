//
//  TestflightViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 26/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

// inherits from TrackedUIViewController, that inherits from UIViewController
// - allows to automatically track the user's running session in Testflight
// - it inherits from TrackedUIViewController : also tracks for the google analytics service

#import <UIKit/UIKit.h>
#import "EasyTracker.h"

@interface TestflightViewController : TrackedUIViewController

@property (nonatomic, retain) NSString* didLoadCheckpoint;
@property (nonatomic, retain) NSString* didAppearCheckpoint;

@end
