//
//  AppDelegate.h
//  testSliding
//
//  Created by neywen on 21/08/12.
//  Copyright (c) 2012 neywen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"


#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) ECSlidingViewController* slidingController;
@property (strong, nonatomic) ViewController *viewController;

@end
