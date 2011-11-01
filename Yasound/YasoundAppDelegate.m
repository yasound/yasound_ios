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
#import "SlidingMenu.h"
#import "AudioStreamer.h"
#import "ASIFormDataRequest.h"

@implementation YasoundAppDelegate

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
  const int H = 128;
  const int interline = 22;
  const int HH = H + interline;
  
  mpScrollView = [[UIScrollView alloc] initWithFrame:self.window.frame];
  [self.window addSubview:mpScrollView];
  [mpScrollView setScrollEnabled:TRUE];
  [mpScrollView setContentSize:CGSizeMake(320, H * K)];

  srand(time(NULL));
  
  for (int i = 0; i < K; i ++)
  {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    int count = 5 + rand() % 5;
    
    for (int img = 0; img < count; img++)
    {
      NSString* url = [[NSString alloc] initWithFormat:@"http://meeloo.net/~meeloo/squares/img_%03d.jpg", rand() % 500];
      [array addObject:url];
    }
    
    SlidingMenu* menu = [[SlidingMenu alloc] initWithFrame:CGRectMake(0, i * HH, mpScrollView.frame.size.width, HH) name:@"MENU NAME" andDestinations:array];
    [menu addTarget:self action:@selector(TileActivated:) forControlEvents:UIControlEventTouchUpInside];
    [mpScrollView addSubview:menu];
  }

  self.window.frame = [UIScreen mainScreen].applicationFrame;

  return YES;
}

- (IBAction)TileActivated:(id)sender
{
  Tile* pTile = (Tile*)sender;
  NSLog(@"Button pressed: %@", [pTile description]);

  {
    // Needed to init cookies
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/all/"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startSynchronous];
  }
  
  NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/sendpost/"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addPostValue:@"meeloo" forKey:@"username"];
	[request addPostValue:@"pipo" forKey:@"password"];
  [request addPostValue:@"Some shit I want to say" forKey:@"posttext"];
	[request setDelegate:self];
	[request startSynchronous];

  NSLog(@"Request sent, response we got: %@\n\n", request.responseString);
  NSLog(@"status message: %@\n\n", request.responseStatusMessage);
  NSLog(@"cookies: %@\n\n", request.responseCookies);
  //[request release];
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
