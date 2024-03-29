//
//  YasoundAppDelegate.m
//
//  Copyright 2011 Yasound. All rights reserved.
//

#import "YasoundAppDelegate.h"
#import "EasyTracker.h"
#import "RootViewController.h"
#import "FacebookSessionManager.h"
#import "AudioStreamManager.h"
#import "YasoundSessionManager.h"
#import "YasoundDataProvider.h"
#import "PlaylistsViewController.h"
#import "StatsViewController.h"
#import "NotificationCenterViewController.h"

#import <Crashlytics/Crashlytics.h>
#import "UserSettings.h"
#import "FakeSlidingController.h"
#import "DeviceVersion.h"
#import "YasoundAppURLHandler.h"


@implementation YasoundAppDelegate


@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;
@synthesize menuViewController;
@synthesize APNsTokenString = _APNsTokenString;
@synthesize serverURL = _serverURL;

#define GOOGLE_ANALYTICS_LOG NO


#ifdef TESTFLIGHT_SDK
/*
 My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void HandleExceptions(NSException *exception) {
    DLog(@"HandleExceptions");
    // Save application data on crash
}
/*
 My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void SignalHandler(int sig) {
    DLog(@"SignalHandler");
    // Save application data on crash
}
#endif



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef TESTFLIGHT_SDK
    
    // installs HandleExceptions as the Uncaught Exception Handler
    NSSetUncaughtExceptionHandler(&HandleExceptions);
    
    // create the signal action structure 
    struct sigaction newSignalAction;
    
    // initialize the signal action structure
    memset(&newSignalAction, 0, sizeof(newSignalAction));
    
    // set SignalHandler as the handler in the signal action structure
    newSignalAction.sa_handler = &SignalHandler;
    
    // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
    sigaction(SIGABRT, &newSignalAction, NULL);
    sigaction(SIGILL, &newSignalAction, NULL);
    sigaction(SIGBUS, &newSignalAction, NULL);
    
    [TestFlight takeOff:@"997d8f9a93194760139ff86ee63b16a7_MzU2NTkyMDExLTEwLTIwIDAxOjU0OjMyLjQzNTk1Nw"];
    
#ifdef TESTFLIGHT_SDK_BETATEST
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif    
    
#endif
  
  [Crashlytics startWithAPIKey:@"10c9dc901cf76d05c62fc2f52d0c2642f888fc4f"];
  
  _APNsTokenString = nil;
#ifdef USE_YASOUND_LOCAL_SERVER
  _APNsTokenString = @"09a95beae4592774dd36843b9573dd8066a7b59cb135fd3e7e5326606a82c417";
#endif
  
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];

    // google analytics launcher
    NSMutableDictionary *trackerParameters =
    [NSMutableDictionary dictionaryWithCapacity:0];
    
    [trackerParameters setValue:[NSNumber numberWithBool:GOOGLE_ANALYTICS_LOG]
                         forKey:kGANDebugEnabledKey];
    
    [EasyTracker launchWithOptions:launchOptions
                    withParameters:trackerParameters
                         withError:nil];
    
    DLog(@"SYSTEM VERSION '%@'", [[UIDevice currentDevice] systemVersion]);
    
    
    // iOS  < 5 : can't use a real slide controller, make it point to a common navigationController, overriding the expected methods
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        self.slideController = [[FakeSlidingController alloc] init];
        self.navigationController = self.slideController;
        
    }
    
    // iOS >= 5 : use the special slide controller
    else
    {
        self.slideController = [[ECSlidingViewController alloc] init];
        self.navigationController = [[UINavigationController alloc] init];
    }

    
    [self.window makeKeyAndVisible];
    self.window.rootViewController = self.slideController;
    
    
    self.menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];

    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    self.navigationController.navigationBarHidden = YES;

    self.rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        [self.slideController setTopViewController:self.navigationController];
        [self.navigationController pushViewController:self.rootViewController animated:NO];
    }
    else
    {
        [self.slideController pushViewController:self.rootViewController animated:NO];
        [self.slideController pushViewController:self.menuViewController animated:NO];
    }
    
    
    
    [self.rootViewController start];
    
        
    
  // Push Notifications:
  DLog(@"Ask for push notification\n");
  [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
  
  _mustGoToNotificationCenter = NO;
  id remoteNotifInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
  if (remoteNotifInfo)
  {
    YasoundAppDelegate* appDelegate = application.delegate;
    [appDelegate handlePushNotification:remoteNotifInfo];
    _mustGoToNotificationCenter = YES;
  }
    
    
    [self rateApp];
  
  return YES;
}





#pragma mark - Rate My App

- (void)rateApp 
{
    BOOL error;
    BOOL neverRate = [[UserSettings main] boolForKey:USKEYratingNever error:&error];
                       
    int launchCount = 0;
    if (neverRate != YES)
    {
        launchCount = [[UserSettings main] integerForKey:USKEYratingLaunchCount error:&error];
        if (error)
            launchCount = 0;
        launchCount++;
        
        [[UserSettings main] setInteger:launchCount forKey:USKEYratingLaunchCount];
    }
    else return;
    
    if (launchCount > 2) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RateApp_title", nil)
                                                        message:NSLocalizedString(@"RateApp_message", nil) 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:NSLocalizedString(@"RateApp_button_rate", nil), NSLocalizedString(@"RateApp_button_later", nil), NSLocalizedString(@"RateApp_button_no", nil), nil];
        alert.delegate = self;
        [alert show];
        [alert release];
    }
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 0) 
    {
        [[UserSettings main] setBool:YES forKey:USKEYratingNever];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"RateApp_url", nil)]];
    }
    
    else if (buttonIndex == 1) 
    {
    }
    
    else if (buttonIndex == 2) 
    {
        [[UserSettings main] setBool:YES forKey:USKEYratingNever];
    }
}    






- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  DLog(@"applicationDidFinishLaunchingWithOptions dev token test");
  NSString* deviceTokenStr = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""] 
                               stringByReplacingOccurrencesOfString: @">" withString: @""] 
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
  
  DLog(@"Device Token: %@", deviceTokenStr);
  
  _APNsTokenString = deviceTokenStr;
  [_APNsTokenString retain];
  [self sendAPNsTokenString];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DLog(@"didFailToRegisterForRemoteNotificationsWithError:\n%@", [error localizedDescription]);
}

- (void)goToNotificationCenter
{
  DLog(@"go to notification center");
  NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  DLog(@"didReceiveRemoteNotification:\n");
  [self handlePushNotification:userInfo];
  
  BOOL appInactive = [UIApplication sharedApplication].applicationState == UIApplicationStateInactive;
  BOOL notifCenterVisible = [self.navigationController.visibleViewController isKindOfClass:[NotificationCenterViewController class]];  
  if (appInactive && !notifCenterVisible)
    [self goToNotificationCenter];
    
}

- (BOOL)mustGoToNotificationCenter
{
  return _mustGoToNotificationCenter;
}

- (void)setMustGoToNotificationCenter:(BOOL)go
{
  _mustGoToNotificationCenter = go;
}

- (void)handlePushNotification:(NSDictionary*)notifDesc
{     
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HANDLE_IOS_NOTIFICATION object:nil]; 
}

- (void)sendAPNsTokenString
{
  if (!_APNsTokenString)
    return;
  
  BOOL sandbox = YES; // #FIXME
#ifdef APNS_PRODUCTION_TARGET
  sandbox = false;
#endif
  BOOL canSend = [[YasoundDataProvider main] sendAPNsDeviceToken:_APNsTokenString isSandbox:sandbox];
  if (canSend)
  {
    [_APNsTokenString release];
    _APNsTokenString = nil;
  }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */

}

- (void)applicationWillTerminate:(UIApplication *)application
{
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
    
    [[AudioStreamManager main] stopRadio];

}

- (void)dealloc
{
  [super dealloc];
}




#pragma mark - FBConnect

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    if ([url.scheme isEqualToString:@"yasound"])
    {
        BOOL res = [[YasoundAppURLHandler main] handleOpenURL:url];
        if (res)
            return YES;
    }
    return [[FacebookSessionManager facebook] handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    if ([url.scheme isEqualToString:@"yasound"])
    {
        BOOL res = [[YasoundAppURLHandler main] handleOpenURL:url];
        if (res)
            return YES;
    }
    
    return [[FacebookSessionManager facebook]  handleOpenURL:url]; 
}










- (NSString*)serverURL
{
    if (_serverURL == nil)
    {
        NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
        self.serverURL = [resources objectForKey:@"serverURL"];
        
        DLog(@"Application Server URL : %@", _serverURL);
    }

    DLog(@"Application Server URL : %@", _serverURL);
    return _serverURL;    
}


- (NSString*)getServerUrlWith:(NSString*)target
{
    NSString* str = self.serverURL;
    
    str = [str stringByAppendingString:target];

    return str;
}







#pragma mark - MyRadio





- (void)goToMyRadioStatsFromViewController:(UIViewController*)sourceController
{
  YaRadio* r = [YasoundDataProvider main].radio;
  
  UIViewController* controller = nil;
  if ([r.ready boolValue])
  {
    controller = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil];
  }
  else
  {
    controller = [self myRadioSetupViewController];
  }
  [sourceController.navigationController pushViewController:controller animated:YES];
  [controller release];
}

- (void)goToMyRadioPlaylistsFromViewController:(UIViewController*)sourceController
{
  YaRadio* r = [YasoundDataProvider main].radio;
  
  UIViewController* controller = nil;
  if ([r.ready boolValue])
  {
    controller = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil wizard:NO];
  }
  else
  {
    controller = [self myRadioSetupViewController];
  }
  [sourceController.navigationController pushViewController:controller animated:YES];
  [controller release];
}


@end
