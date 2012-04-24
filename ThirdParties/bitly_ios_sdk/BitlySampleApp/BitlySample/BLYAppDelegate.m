//
//  BLYAppDelegate.m
//  BitlySample
//
//  Created by tracy pesin on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BLYAppDelegate.h"

#import "BLYViewController.h"

#import "BitlyConfig.h"

@implementation BLYAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize navController = _navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[BLYViewController alloc] initWithNibName:@"BLYViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[BLYViewController alloc] initWithNibName:@"BLYViewController_iPad" bundle:nil];
    }
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    /*** Uncomment code below and set your bitly api key information ***/
    
//    [[BitlyConfig sharedBitlyConfig] setBitlyLogin:@"<bitly login>" bitlyAPIKey:@"<bitlyAPIKey>"];
    
    /*** Twitter api keys are needed if you're supporting back to iOS 4.x, since 
     that uses OAuth. 5.0+ use the twitter accounts configured in Settings. ***/
    
//    [[BitlyConfig sharedBitlyConfig] setTwitterOAuthConsumerKey: @"<twitterOAuthConsumerKey>" 
//                 twitterOAuthConsumerSecret:@"<twitterOAuthConsumerSecret>" 
//             twitterOAuthSuccessCallbackURL: @"<twitterOAuthSuccessCallbackURL>"];
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
