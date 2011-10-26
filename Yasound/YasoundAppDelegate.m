//
//  UIScrollViewTestAppDelegate.m
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/24/11.
//  Copyright 2011 Yasound. All rights reserved.
//

#import "YasoundAppDelegate.h"
#import "Tile.h"
#import "MenuHeader.h"
#import "AudioStreamer.h"

@implementation UIScrollViewTestAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  [self.window makeKeyAndVisible];

  NSURL* radiourl = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net:8000/ubik.mp3"];
  mpStreamer = [[AudioStreamer alloc] initWithURL: radiourl];
  [mpStreamer retain];
  [mpStreamer start];
  
  
  const int K = 10;
  const int W = 128;
  const int H = 128;
  const int N = 10;
  const int WW = W * N;
  const int interline = 22;
  const int HH = H + interline;
  
  mpScrollView = [[UIScrollView alloc] initWithFrame:self.window.frame];
  [self.window addSubview:mpScrollView];
  [mpScrollView setScrollEnabled:TRUE];
  [mpScrollView setContentSize:CGSizeMake(320, H * K)];


  int img_index = 1;
  
  for (int i = 0; i < K; i ++)
  {
    // Title:
    MenuHeader* pLabel = [[MenuHeader alloc] initWithFrame:CGRectMake(0, i * HH, 320, interline) andText:@"WHAT'S NEW"];
    [mpScrollView addSubview:pLabel];
    
    // Scroll view with images as buttons:
    UIScrollView* pScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, interline + i * HH, mpScrollView.frame.size.width, H)];
    [mpScrollView addSubview:pScroll];
    [pScroll setScrollEnabled:TRUE];
    [pScroll setContentSize:CGSizeMake(WW, H)];
    [pScroll setZoomScale:.5];
    
    for (int k = 0; k < N; k++)
    {
      NSString* str = [[NSString alloc] initWithFormat:@"http://meeloo.net/~meeloo/squares/img_%03d.jpg", img_index++];
      NSURL* url = [NSURL URLWithString:str];

      //Tile* pButton = [[[NSBundle mainBundle] loadNibNamed:@"TileView" owner:self options:nil] objectAtIndex:0];
      Tile* pButton = [[Tile alloc] initWithFrame:CGRectMake((k * (4 + W)), 0, W, H) andImageURL: url];
      [pScroll addSubview:pButton];
    }
  }

  self.window.frame = [UIScreen mainScreen].applicationFrame;

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
  [_window release];
    [super dealloc];
}

@end
