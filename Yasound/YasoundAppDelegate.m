//
//  UIScrollViewTestAppDelegate.m
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/24/11.
//  Copyright 2011 Yasound. All rights reserved.
//

#import "YasoundAppDelegate.h"
#import "RadioTabBarController.h"
#import "RadioViewController.h"

//#FIXME: MatTest
#import "Communicator.h"
#import "Radio.h"
#import "WallEvent.h"

@implementation YasoundAppDelegate


@synthesize window;
@synthesize navigationController;
@synthesize tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // create a mavigationControler without navigation bar
  navigationController = [[UINavigationController alloc] init];
  navigationController.navigationBarHidden = YES;

  [self.window makeKeyAndVisible];

  // add it as the window's root widget
  self.window.rootViewController = navigationController;
    
    //LBDEBUG temporarly call /////////////////////////////
//    RadioViewController* view = [[RadioViewController alloc] init];
//    [self.navigationController pushViewController:view animated:YES];
//    return YES;
    /////////////////////////////////////////////////////////////////////
  
  // push the main view controller into the mavigationControler
  tabBarController = [[RadioTabBarController alloc] init];
  [self.navigationController pushViewController:self.tabBarController animated:YES];
  
  
  
  //#FIXME: MatTest
  Communicator* communicator = [[Communicator alloc] initWithBaseURL:@"http://127.0.0.1:8000/api/v1"];
  
  [communicator mapResourcePath:@"radio" toObject:[Radio class]];
  
//  Radio* r = [communicator getObjectWithClass:[Radio class] andID:[NSNumber numberWithInt:1]];

//  Radio* r = [communicator getObjectWithClass:[Radio class] withURL:@"radio/1/" absolute:NO];
//  NSLog(@"%@", [r toString]);
  
  NSArray* wallevents = [communicator getObjectsWithClass:[WallEvent class] withURL:@"radio/1/wall" absolute:NO];
  if ([wallevents count] > 0)
  {
    WallEvent* w = [wallevents objectAtIndex:0];
    NSLog(@"%@", [w toString]);
  }

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

- (void)dealloc
{
  [super dealloc];
}

@end
