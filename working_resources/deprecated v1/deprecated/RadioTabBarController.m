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
#import "RadioViewController.h"
#import "CreateMyRadio.h"
#import "YasoundDataProvider.h"
#import "FriendsViewController.h"
#import "FavoritesViewController.h"


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
    
    UIViewController* view1 = nil;
    
    NSNumber* radioCreatedNb = [[NSUserDefaults standardUserDefaults] objectForKey:@"radioCreated"];
    if ((radioCreatedNb != nil) && ([radioCreatedNb boolValue] == NO))
    {
        // Mon Yasound
        view1 = [[CreateMyRadio alloc] initWithNibName:@"CreateMyRadio" bundle:nil wizard:NO radio:[YasoundDataProvider main].radio];
    }
    else
    {
    
  // Mon Yasound
        view1 = [[MyYasoundViewController alloc] initWithNibName:@"MyYasoundViewController" bundle:nil title:NSLocalizedString(@"selection_tab_myyasound", nil) tabIcon:@"tabIconMyYasound.png"];
    }

    // Friends
    FriendsViewController* view2 = [[FriendsViewController alloc] initWithNibName:@"FriendsViewController" bundle:nil title:NSLocalizedString(@"selection_tab_friends", nil) tabIcon:@"tabIconFavorites.png"];
    
  // Favorites
  FavoritesViewController* view3 = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil title:NSLocalizedString(@"selection_tab_favorites", nil) tabIcon:@"tabIconTop.png"];
  
  // Nouveautés
  RadioSelectionViewController* view4 = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:NSLocalizedString(@"selection_tab_selection", nil) tabIcon:@"tabIconNew.png"];
  
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


- (void)viewDidAppear:(BOOL)animated
{
    NSNumber* forceTabIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"forceTabIndex"];
    if (forceTabIndex != nil)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"forceTabIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
         
        NSInteger index = [forceTabIndex integerValue];
        self.selectedIndex = index;
        return;
    }
    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}











@end
