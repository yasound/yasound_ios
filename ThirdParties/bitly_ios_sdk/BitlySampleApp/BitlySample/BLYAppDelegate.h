//
//  BLYAppDelegate.h
//  BitlySample
//
//  Created by tracy pesin on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLYViewController;

@interface BLYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BLYViewController *viewController;

@property (strong, nonatomic) UINavigationController *navController;

@end
