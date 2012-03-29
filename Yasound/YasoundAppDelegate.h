//
//  YasoundAppDelegate.y
//
//  Copyright 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef TESTFLIGHT_SDK
#import "TestFlight.h"
#endif


#define APPDELEGATE ((YasoundAppDelegate*)[UIApplication sharedApplication].delegate)



@class RootViewController;

@interface YasoundAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain)  IBOutlet UIWindow *window;
@property (nonatomic, retain)  UINavigationController *navigationController;
@property (nonatomic, retain) RootViewController* rootViewController;
@property (nonatomic, retain) NSString* serverURL;


- (NSString*)getServerUrlWith:(NSString*)target;

- (UIViewController*)myRadioSetupViewController;
- (void)goToMyRadioFromViewController:(UIViewController*)sourceController;
- (void)goToMyRadioStatsFromViewController:(UIViewController*)sourceController;
- (void)goToMyRadioPlaylistsFromViewController:(UIViewController*)sourceController;

@end
