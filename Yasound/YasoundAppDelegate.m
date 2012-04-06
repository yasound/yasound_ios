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
#import "RadioViewController.h"
#import "CreateMyRadio.h"
#import "PlaylistsViewController.h"
#import "StatsViewController.h"
#import "APNsNotifInfo.h"
#import "YasoundNotifCenter.h"
#import "NotificationCenterViewController.h"



@implementation YasoundAppDelegate


@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;
@synthesize APNsTokenString = _APNsTokenString;
@synthesize serverURL = _serverURL;

#define GOOGLE_ANALYTICS_LOG NO


#ifdef TESTFLIGHT_SDK
/*
 My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void HandleExceptions(NSException *exception) {
    NSLog(@"HandleExceptions");
    // Save application data on crash
}
/*
 My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void SignalHandler(int sig) {
    NSLog(@"SignalHandler");
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
    
#endif
  
  _APNsTokenString = nil;
#ifdef USE_YASOUND_LOCAL_SERVER
  _APNsTokenString = @"09a95beae4592774dd36843b9573dd8066a7b59cb135fd3e7e5326606a82c417";
#endif
  
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    // google analytics launcher
    NSMutableDictionary *trackerParameters =
    [NSMutableDictionary dictionaryWithCapacity:0];
    
    [trackerParameters setValue:[NSNumber numberWithBool:GOOGLE_ANALYTICS_LOG]
                         forKey:kGANDebugEnabledKey];
    
    [EasyTracker launchWithOptions:launchOptions
                    withParameters:trackerParameters
                         withError:nil];
    
    navigationController = [[UINavigationController alloc] init];
//    [navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    navigationController.navigationBarHidden = YES;

  [self.window makeKeyAndVisible];

  // add it as the window's root widget
  self.window.rootViewController = navigationController;
    
    rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    [self.navigationController pushViewController:rootViewController animated:NO];
    
  // Push Notifications:
  NSLog(@"Ask for push notification\n");
  [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
  
  _mustGoToNotificationCenter = NO;
  id remoteNotifInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
  if (remoteNotifInfo)
  {
    YasoundAppDelegate* appDelegate = application.delegate;
    [appDelegate handlePushNotification:remoteNotifInfo];
    _mustGoToNotificationCenter = YES;
  }
  
  return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  NSLog(@"applicationDidFinishLaunchingWithOptions dev token test");
  NSString* deviceTokenStr = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""] 
                               stringByReplacingOccurrencesOfString: @">" withString: @""] 
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
  
  NSLog(@"Device Token: %@", deviceTokenStr);
  
  _APNsTokenString = deviceTokenStr;
  [_APNsTokenString retain];
  [self sendAPNsTokenString];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:\n%@", [error localizedDescription]);
}

- (void)goToNotificationCenter
{
  NSLog(@"go to notification center");
  NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  NSLog(@"didReceiveRemoteNotification:\n");
  [self handlePushNotification:userInfo];
  
  if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive)
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
  APNsNotifInfo* notifInfo = [[YasoundNotifCenter main] addNotifInfoWithDescription:notifDesc];
}

- (void)sendAPNsTokenString
{
  if (!_APNsTokenString)
    return;
  
  BOOL sandbox = YES; // #FIXME
#ifdef APP_STORE_TARGET
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
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  [rootViewController becomeFirstResponder];

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


- (void)remoteControlReceivedWithEvent:(UIEvent *)event 
{
  //if it is a remote control event handle it correctly
  if (event.type == UIEventTypeRemoteControl) 
  {
    if (event.subtype == UIEventSubtypeRemoteControlPlay) 
      [[AudioStreamManager main] startRadio:[AudioStreamManager main].currentRadio];
    
    else if (event.subtype == UIEventSubtypeRemoteControlPause) 
      [[AudioStreamManager main] stopRadio];
    
    else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) 
      [[AudioStreamManager main] togglePlayPauseRadio];
    
  }
}





#pragma mark - FBConnect

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [[FacebookSessionManager facebook] handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    return [[FacebookSessionManager facebook]  handleOpenURL:url]; 
}











- (NSString*)serverURL
{
    if (_serverURL == nil)
    {
        NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
        self.serverURL = [resources objectForKey:@"serverURL"];
        
        NSLog(@"Application Server URL : %@", _serverURL);
    }

    NSLog(@"Application Server URL : %@", _serverURL);
    return _serverURL;    
}


- (NSString*)getServerUrlWith:(NSString*)target
{
    NSString* str = self.serverURL;
    
    str = [str stringByAppendingString:target];

    return str;
}







#pragma mark - MyRadio

- (UIViewController*)myRadioSetupViewController
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"skipRadioCreationSendToSelection"];
  [[NSUserDefaults standardUserDefaults] synchronize]; 
  UIViewController* controller = [[CreateMyRadio alloc] initWithNibName:@"CreateMyRadio" bundle:nil wizard:NO radio:[YasoundDataProvider main].radio];
  return controller;
}

- (void)goToMyRadioFromViewController:(UIViewController*)sourceController
{
  Radio* r = [YasoundDataProvider main].radio;
  NSLog(@"go to my radio '%@' (%@)", r.name, r.ready);
  
  UIViewController* controller = nil;
  if ([r.ready boolValue])
  {
    controller = [[RadioViewController alloc] initWithRadio:r];
  }
  else
  {
//      controller = [[RadioViewController alloc] initWithRadio:r];
      //LBDEBUG FAKE
    controller = [self myRadioSetupViewController];
  }
  [sourceController.navigationController pushViewController:controller animated:YES];
  [controller release];
}

- (void)goToMyRadioStatsFromViewController:(UIViewController*)sourceController
{
  Radio* r = [YasoundDataProvider main].radio;
  
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
  Radio* r = [YasoundDataProvider main].radio;
  
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
