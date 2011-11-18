//
//  AppDelegate.m
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "Entry.h"
#import "Communicator.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
  [_window release];
  [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{  
  Communicator* communicator = [[Communicator alloc] initWithBaseURL:@"http://127.0.0.1:8000/api/v1"];
  
  [communicator mapResourcePath:@"entry" toObject:[Entry class]];
  [communicator mapResourcePath:@"user" toObject:[User class]];
  


//  [communicator getObjectWithClass:[Entry class] andID:[NSNumber numberWithInt:1] notifyTarget:self byCalling:@selector(resultGET:withError:)];
  
  
  Entry* e = [communicator getObjectWithClass:[Entry class] andID:[NSNumber numberWithInt:5]];
  [communicator deleteObject:e notifyTarget:self byCalling:@selector(resultDELETE:withError:)];


  
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
  } else {
      self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
  }
  self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)resultGET:(Model*)obj withError:(NSError*)error
{
  Entry* e = (Entry*)obj;
  NSLog(@"GET result");
  
  
  NSLog(@"entry id = '%@' title = '%@' slug = '%@' body = '%@' \n\tuser: first name = '%@' last name = '%@' username = '%@' user id = '%@'", e.id, e.title, e.slug, e.body, e.user.first_name, e.user.last_name, e.user.username, e.user.id);
}

- (void)resultDELETE:(Model*)obj withError:(NSError*)error
{
  Entry* e = (Entry*)obj;
  NSLog(@"DELETE result");
  
  
  NSLog(@"entry id = '%@' title = '%@' slug = '%@' body = '%@' \n\tuser: first name = '%@' last name = '%@' username = '%@' user id = '%@'", e.id, e.title, e.slug, e.body, e.user.first_name, e.user.last_name, e.user.username, e.user.id);
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
