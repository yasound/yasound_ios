//
//  YasoundAppDelegate.y
//
//  Copyright 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef TESTFLIGHT_SDK
#import "TestFlight.h"
#endif
#import "ECSlidingViewController.h"
#import "MenuViewController.h"


#define APPDELEGATE ((YasoundAppDelegate*)[UIApplication sharedApplication].delegate)



@class RootViewController;

@interface YasoundAppDelegate : NSObject <UIApplicationDelegate>
{
  NSString* _APNsTokenString;
  NSDictionary* _receivedAPNsInfo;
  
  BOOL _mustGoToNotificationCenter;
}

@property (nonatomic, retain)  IBOutlet UIWindow *window;

//@property (nonatomic, retain)  UINavigationController* menuNavigationController;
@property (nonatomic, retain)  UINavigationController* navigationController;


// slideController is ECSlidingViewController* with iOS >= 5
// slideController is FakeSlidingController with iOS < 5
@property (nonatomic, retain) id slideController;

@property (nonatomic, retain) RootViewController* rootViewController;
@property (nonatomic, retain) MenuViewController* menuViewController;

@property (nonatomic, retain) NSString* serverURL;

- (BOOL)mustGoToNotificationCenter;
- (void)setMustGoToNotificationCenter:(BOOL)go;


- (NSString*)getServerUrlWith:(NSString*)target;

@property (nonatomic, readonly) NSString* APNsTokenString;

- (void)sendAPNsTokenString;
- (void)handlePushNotification:(NSDictionary*)notifDesc;

- (void)goToMyRadioStatsFromViewController:(UIViewController*)sourceController;
- (void)goToMyRadioPlaylistsFromViewController:(UIViewController*)sourceController;

@end
