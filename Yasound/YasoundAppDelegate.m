//
//  UIScrollViewTestAppDelegate.m
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/24/11.
//  Copyright 2011 Yasound. All rights reserved.
//

#import "YasoundAppDelegate.h"
#import "EasyTracker.h"
#import "RootViewController.h"
#import "FacebookSessionManager.h"
#import "AudioStreamManager.h"

@implementation YasoundAppDelegate


@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;


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
    
  return YES;
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


@end
