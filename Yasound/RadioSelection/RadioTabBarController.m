//
//  RadioTabBarController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioTabBarController.h"
#import "RadioSelectionViewController.h"
#import "RadioSearchViewController.h"
#import "MyYasoundViewController.h"
#import "BundleFileManager.h"

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
  
  BundleStylesheet* stylesheet = [[BundleFileManager main] stylesheetForKey:@"GuiTintColor" error:nil];
  self.tabBar.tintColor = stylesheet.color;

  // Mon Yasound
  MyYasoundViewController* view1 = [[MyYasoundViewController alloc] initWithNibName:@"MyYasoundViewController" bundle:nil title:NSLocalizedString(@"selection_tab_myyasound", nil) tabIcon:@"tabIcon_MyYasound"];
  
  // Selection
  RadioSelectionViewController* view2 = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil type:RSTSelection title:NSLocalizedString(@"selection_tab_selection", nil) tabIcon:@"tabIcon_Selection"];
  
  // Top
  RadioSelectionViewController* view3 = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil type:RSTTop title:NSLocalizedString(@"selection_tab_top", nil) tabIcon:@"tabIcon_Top"];
  
  // Nouveautés
  RadioSelectionViewController* view4 = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil type:RSTNew title:NSLocalizedString(@"selection_tab_new", nil) tabIcon:@"tabIcon_New"];
  
  // Rechercher
  RadioSearchViewController* view5 = [[RadioSearchViewController alloc] initWithNibName:@"RadioSearchViewController" bundle:nil title:NSLocalizedString(@"selection_tab_search", nil) tabItem:UITabBarSystemItemSearch];

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











@end
