//
//  RadioTabBarController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioTabBarController.h"
#import "RadioSelectionViewController.h"


@implementation RadioTabBarController



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
  
  //      UITabBarSystemItemMore,
  //      UITabBarSystemItemFavorites,
  //      UITabBarSystemItemFeatured,
  //      UITabBarSystemItemTopRated,
  //      UITabBarSystemItemRecents,
  //      UITabBarSystemItemContacts,
  //      UITabBarSystemItemHistory,
  //      UITabBarSystemItemBookmarks,
  //      UITabBarSystemItemSearch,
  //      UITabBarSystemItemDownloads,
  //      UITabBarSystemItemMostRecent,
  //      UITabBarSystemItemMostViewed,


  // Mon Yasound
  RadioSelectionViewController* view1 = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:@"Mon Yasound" tabIcon:@"tabIcon_MyYasound"];
  
  // Selection
  RadioSelectionViewController* view2 = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:@"Selection" tabIcon:@"tabIcon_Selection"];
  
  // Top
  RadioSelectionViewController* view3 = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:@"Top" tabItem:UITabBarSystemItemTopRated];
  
  // Nouveautés
  RadioSelectionViewController* view4 = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:@"Nouveautés" tabItem:UITabBarSystemItemRecents];
  
  // Rechercher
  RadioSelectionViewController* view5 = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:@"Rechercher" tabItem:UITabBarSystemItemSearch];

  self.viewControllers = [NSArray arrayWithObjects:view1, view2, view3, view4, view5, nil];
  
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










#pragma mark - TableView Source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  // Number of rows is the number of time zones in the region for the specified section.
  return 24;
}


@end
