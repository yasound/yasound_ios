//
//  MainViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "MainViewController.h"

#import "Tile.h"
#import "MenuHeader.h"
#import "SlidingMenu.h"
//#import "AudioStreamer.h"
#import "ASIFormDataRequest.h"
#import "RadioViewController.h"

@implementation MainViewController



- (id)init
{
  self = [super init];

  _radioCreated = FALSE;  
  _myRadioButton = nil;
  _headerView = nil;
  
  return self;
}


- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self createRadioList];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self updateHeader];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}









- (void)updateHeader
{
  if (_myRadioButton)
  {
    [_myRadioButton removeFromSuperview];
    _myRadioButton = nil;
  }
  
  _myRadioButton = [UIButton buttonWithType:UIButtonTypeCustom];

  UIImage* myradioimg = nil;
  if (_radioCreated)
  {
    myradioimg = [UIImage imageNamed:@"radiocree.png"];
    [_myRadioButton addTarget:self action:@selector(onAccessRadio:) forControlEvents:UIControlEventTouchUpInside];
    [_myRadioButton setImage:myradioimg forState:UIControlStateNormal];
  }
  else 
  {
    myradioimg = [UIImage imageNamed:@"CreateMyRadio.png"];
    [_myRadioButton setImage:myradioimg forState:UIControlStateNormal];
    myradioimg = [UIImage imageNamed:@"CreateMyRadio_Down.png"];
    [_myRadioButton setImage:myradioimg forState:UIControlStateHighlighted];
    [_myRadioButton addTarget:self action:@selector(onCreateRadio:) forControlEvents:UIControlEventTouchUpInside];
  }

  
  [_headerView addSubview:_myRadioButton];
  
  CGSize size = myradioimg.size;
  CGRect frame = CGRectMake(0, 0, size.width, size.height);
  _myRadioButton.frame = frame;
}




#define HEADER_HEIGHT 88


- (void)createRadioList
{
  const int H = 128;
  const int interline = 22;
  const int HH = H + interline;
  
  UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:scrollView];
  [scrollView setScrollEnabled:TRUE];
  
  int y = 0;
  
  UIImage* logo = [UIImage imageNamed:@"logo.png"];
  UIImageView* logoview = [[UIImageView alloc] initWithImage: logo];
  [scrollView addSubview:logoview];
  logoview.frame = CGRectMake(160 - logo.size.width / 2, 0, logo.size.width, logo.size.height);
  
  y += logo.size.height;
  
  CGRect headerFrame = CGRectMake(0, y, self.view.frame.size.width, HEADER_HEIGHT);
  _headerView = [[UIView alloc] initWithFrame:headerFrame];
  y += HEADER_HEIGHT;
  
  [scrollView addSubview:_headerView];
  
  int ndx = 0;
  
  const char* menuName[] = 
  {
    "Selection",
    "Favorites",
    "Friends",
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
    
    SlidingMenu* menu = [[SlidingMenu alloc] initWithFrame:CGRectMake(0, y, scrollView.frame.size.width, HH) menuName:[NSString stringWithCString:menuName[i] encoding:NSUTF8StringEncoding] names:radioNames captions:captions andDestinations:array];
    y += HH;
    [menu addTarget:self action:@selector(TileActivated:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:menu];
  }
  
  [scrollView setContentSize:CGSizeMake(320, y)];
}

- (IBAction)TileActivated:(id)sender
{
  Tile* pTile = (Tile*)sender;
  NSLog(@"Button pressed: %@", [pTile description]);

  [self onAccessRadio:sender];
}


 - (IBAction)onCreateRadio:(id)sender
{
  RadioCreatorViewController* view = [[RadioCreatorViewController alloc] initWithNibName:@"RadioCreatorViewController" bundle:nil];
  view.delegate = self;
  
  _radioCreated = TRUE;
  
  [self.navigationController presentModalViewController:view animated:YES];
  [view release];
}
 
 
 - (IBAction)onAccessRadio:(id)sender
{
  RadioViewController* view = [[RadioViewController alloc] init];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}



#pragma mark - RadioCreatorDelegate

- (void)radioDidCreate:(UIViewController*)modalViewController
{
  [modalViewController dismissModalViewControllerAnimated:YES];
}











@end
