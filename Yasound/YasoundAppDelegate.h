//
//  UIScrollViewTestAppDelegate.h
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/24/11.
//  Copyright 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef TESTFLIGHT_SDK
#import "TestFlight.h"
#endif

@class RootViewController;

@interface YasoundAppDelegate : NSObject <UIApplicationDelegate>
{
  NSString* _APNsTokenString;
  NSDictionary* _receivedAPNsInfo;
}

@property (nonatomic, retain)  IBOutlet UIWindow *window;
@property (nonatomic, retain)  UINavigationController *navigationController;

@property (nonatomic, retain) RootViewController* rootViewController;

@property (nonatomic, readonly) NSString* APNsTokenString;

- (void)sendAPNsTokenString;
- (void)handlePushNotification:(NSDictionary*)notifDesc;

- (UIViewController*)myRadioSetupViewController;
- (void)goToMyRadioFromViewController:(UIViewController*)sourceController;
- (void)goToMyRadioStatsFromViewController:(UIViewController*)sourceController;
- (void)goToMyRadioPlaylistsFromViewController:(UIViewController*)sourceController;

@end
