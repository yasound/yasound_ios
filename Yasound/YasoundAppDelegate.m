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
#import "RadioCreator.h"
#import "RadioViewController.h"

@implementation YasoundAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  [self.window makeKeyAndVisible];

  mpCreator = nil;
  mpScrollView = nil;
  mpRadio = nil;
  
  [self createRadioList];
  
  self.window.frame = [UIScreen mainScreen].applicationFrame;

  radioCreated = FALSE;
  
  return YES;
}

- (void) createRadioList
{
  const int H = 128;
  const int interline = 22;
  const int HH = H + interline;
  
  mpScrollView = [[UIScrollView alloc] initWithFrame:self.window.frame];
  [self.window addSubview:mpScrollView];
  [mpScrollView setScrollEnabled:TRUE];

  int y = 0;

  UIImage* logo = [UIImage imageNamed:@"logo.png"];
  UIImageView* logoview = [[UIImageView alloc] initWithImage: logo];
  [mpScrollView addSubview:logoview];
  logoview.frame = CGRectMake(160 - logo.size.width / 2, 20, logo.size.width, logo.size.height);
  
  y += 40 + logo.size.height;

  UIButton* myradio = [UIButton buttonWithType:UIButtonTypeCustom];
  UIImage* myradioimg = nil;
  if (radioCreated)
    myradioimg = [UIImage imageNamed:@"radiocree.png"];
  else 
    myradioimg = [UIImage imageNamed:@"CreateMyRadio.png"];
  
  myradio.frame = CGRectMake(0, y, myradioimg.size.width, myradioimg.size.height);
  y += myradioimg.size.height;
  [myradio setImage:myradioimg forState:UIControlStateNormal];
  if (radioCreated)
    [myradio addTarget:self action:@selector(onAccessRadio:) forControlEvents:UIControlEventTouchUpInside];
  else
    [myradio addTarget:self action:@selector(onCreateRadio:) forControlEvents:UIControlEventTouchUpInside];
  [mpScrollView addSubview:myradio];
  
  int ndx = 0;
  
  const char* menuName[] = 
  {
    "Selection",
    "Favoris",
    "Amis",
    "Top",
    NULL
  };

  const char* imgs[] =
  {
    "_0000_!cid_9B60C937-509D-43B7-BB48-1DC93D7A775C@Home.png",
    "_0001_oeuf.png",
    "_0002_bars.png",
    "_0003_DJ-Emir-Santana-03med.png",
    "_0004_dj_tiesto-club-life-054.png",
    "_0005_david-guetta-4.png",
    "_0006_black-eyed-peas-2.png",
    "_0007_beatbox-felix-zenger_imagenGrande.png",
    "_0008_iStock_000011183454Small.png",
    "_0009_iStock_000010132117Medium.png",
    "_0010_iStock_000002712770XSmall.png",
    "_0011_iStock_000002129524Small.png",
    "_0012_EVE201008181316578569.png",
    "_0013_PachaIbiza.png",
    "_0014_NewsRadio.png",
    "_0015_LibreAntenne.png",
    "_0016_Kurt.png",
    "_0017_lionel-messi.png",
    "_0018_Lady-Gaga.png|",
    "_0019_jay-z1.png"
  };
  
  const char* styleNames[] =
  {
    "Lounge",
    "Techno",
    "Rock",
    "Folk",
    "House",
    "Trance",
    "Dynam'hit",
    "Nouvelle scène",
    "Pop",
    "Hard",
    "Reggae",
    "Films",
    "Pubs",
    "Soul",
    "Funk",
    "Classique",
    "Années 80",
    "Nouveautés",
    "Ibiza",
    "Francofolies"
  };
  
  const char* songNames[] =
  {
    "Islands",
    "Still Sound",
    "Plique (Original Mix)",
    "Love Is All",
    "Casimir Pulaski Day",
    "Drying Oasis (Matt Star Remix)",
    "Dutchie Courage",
    "Where I belong",
    "Me and You",
    "Tempo de amor",
    "Fyah Fyah",
    "Lacrimosa",
    "Over You",
    "Fattie Boom Boom",
    "15 Step",
    "Till There Was You",
    "Slippin",
    "What Yo Gonna Do",
    "Wonton",
    "No Other Way"
  };
  
  const char* artistsNames[] =
  {
    "The xx",
    "Toro Y Moi",
    "TDR",
    "Tallest Man on Earth, the",
    "Sufjan Stevens",
    "Stella",
    "Star Slinger",
    "Sia",
    "She & Him",
    "Seu Jorge & Almaz",
    "Selah Sue",
    "Regina Spektor",
    "Raphael Saadiq",
    "Rankin Dread",
    "Radiohead",
    "Rachael Starr",
    "Quadron",
    "Plan B",
    "The Phoenix Foundation",
    "Paolo Nutini"
  };
  
  for (int i = 0; menuName[i]; i ++)
  {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSMutableArray* radioNames = [[NSMutableArray alloc] init];
    NSMutableArray* captions = [[NSMutableArray alloc] init];
    int count = 5 + rand() % 5;
    
    for (int img = 0; img < count; img++)
    {

      NSString* url = [[NSString alloc] initWithFormat:@"http://meeloo.net/~meeloo/squares/%s", imgs[ndx] ];
      [array addObject:url];
      [radioNames addObject:[NSString stringWithCString:styleNames[ndx] encoding:NSUTF8StringEncoding]];
      [captions addObject:[NSString stringWithCString:songNames[ndx] encoding:NSUTF8StringEncoding]];
      ndx++;
      ndx %= 20;
    }
    
    SlidingMenu* menu = [[SlidingMenu alloc] initWithFrame:CGRectMake(0, y, mpScrollView.frame.size.width, HH) menuName:[NSString stringWithCString:menuName[i] encoding:NSUTF8StringEncoding] names:radioNames captions:captions andDestinations:array];
    y += HH;
    [menu addTarget:self action:@selector(TileActivated:) forControlEvents:UIControlEventTouchUpInside];

    [mpScrollView addSubview:menu];
  }

  [mpScrollView setContentSize:CGSizeMake(320, y)];

  self.window.frame = [UIScreen mainScreen].applicationFrame;

}

- (IBAction)TileActivated:(id)sender
{
  Tile* pTile = (Tile*)sender;
  NSLog(@"Button pressed: %@", [pTile description]);

  [mpScrollView removeFromSuperview];
  mpScrollView = nil;
  
  mpRadio = [[RadioViewController alloc] initWithNibName:@"RadioViewController" bundle:nil];
  [self.window addSubview: mpRadio.view];

  NSURL* radiourl = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net:8000/cedric.mp3"];
  mpStreamer = [[AudioStreamer alloc] initWithURL: radiourl];
  [mpStreamer retain];
  [mpStreamer start];
}

- (IBAction)onCreateRadio:(id)sender
{
  [mpScrollView removeFromSuperview];
  mpScrollView = nil;
  
  mpCreator = [[RadioCreator alloc] initWithNibName:@"RadioCreator" bundle:nil];
  [self.window addSubview: mpCreator.view];
  
  radioCreated = TRUE;
}

- (IBAction)onAccessRadio:(id)sender
{
  [mpScrollView removeFromSuperview];
  [mpScrollView release];
  mpScrollView = nil;
  [mpCreator.view removeFromSuperview];
  [mpCreator release];
  mpCreator = nil;
  
  mpRadio = [[RadioViewController alloc] initWithNibName:@"RadioViewController" bundle:nil];
  [self.window addSubview: mpRadio.view];
  
  NSURL* radiourl = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net:8000/cedric.mp3"];
  mpStreamer = [[AudioStreamer alloc] initWithURL: radiourl];
  [mpStreamer retain];
  [mpStreamer start];
}

- (IBAction)onQuitRadio:(id)sender
{
  [mpStreamer stop];
  [mpStreamer release];
  mpStreamer = nil;
  [mpRadio.view removeFromSuperview];
  [mpRadio release];
  mpRadio = nil;
  
  [self createRadioList];
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
