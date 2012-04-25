//
//  MenuDynamicViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MenuDynamicViewController.h"
#import "RadioViewController.h"
#import "YasoundDataProvider.h"
#import "RadioSelectionViewController.h"
#import "RadioSearchViewController.h"
#import "FriendsViewController.h"
#import "FavoritesViewController.h"
#import "StatsViewController.h"
#import "PlaylistsViewController.h"
#import "SettingsViewController.h"
#import "LegalViewController.h"
#import "AudioStreamManager.h"
#import "YasoundSessionManager.h"
#import "RootViewController.h"
#import "BundleStylesheet.h"
#import "Theme.h"
#import "YasoundAppDelegate.h"
#import "ProgrammingViewController.h"

#import "NotificationCenterViewController.h"
#import "YasoundNotifCenter.h"
#import "MenuTableViewCell.h"



@implementation MenuDynamicViewController


@synthesize sections;


#define TYPE_MY_RADIO @"my_radio"
#define TYPE_RADIO @"radio"
#define TYPE_RADIO_LIST @"radioList"
#define TYPE_USER @"user"
#define TYPE_USER_LIST @"user_list"
#define TYPE_WEB_PAGE @"web_page"
#define TYPE_RADIO_SEARCH @"radio_search"
#define TYPE_FRIENDS @"friends"
#define TYPE_NOTIFICATIONS @"notifications"
#define TYPE_STATS @"stats"
#define TYPE_SETTINGS @"settings"
#define TYPE_PROGRAMMING @"programming"
#define TYPE_LOGOUT @"logout"


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSections:(NSArray*)sections
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _notificationsCell = nil;
        self.sections = sections;
    }
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
    
    _tableView.backgroundColor =  [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1];

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _tableView.sectionHeaderHeight = sheet.frame.size.height;

    sheet = [[Theme theme] stylesheetForKey:@"MenuRowSingle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _tableView.rowHeight = sheet.frame.size.height;
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuBackground" error:nil];    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    [[YasoundNotifCenter main] addTarget:self action:@selector(unreadNotifCountChanged) forEvent:eAPNsUnreadNotifCountChanged];
}



- (void)viewWillAppear:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
}



- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if ([AudioStreamManager main].currentRadio == nil)
    [_nowPlayingButton setEnabled:NO];
  else
    [_nowPlayingButton setEnabled:YES];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
  
  [[YasoundNotifCenter main] removeTarget:self];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)unreadNotifCountChanged
{
  if (!_notificationsCell)
    return;
  
  NSInteger unread = [[YasoundNotifCenter main] unreadNotifCount];
  [_notificationsCell setUnreadCount:unread];
}


#pragma mark - TableView Source and Delegate



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSDictionary* dicoSection = [self.sections objectAtIndex:section];
    NSArray* rows = [dicoSection objectForKey:@"entries"];
    
    if (rows == nil)
    {
        NSLog(@"DynamicMenu parsing error");
        NSLog(@"%@", self.sections);
        return 0;
    }    
    
    return rows.count;
}




- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary* dicoSection = [self.sections objectAtIndex:section];
    
    NSString* title = [dicoSection objectForKey:@"name"];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];

    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 44);
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString* style = nil;
    NSString* selectedStyle = nil;
    
    NSDictionary* dicoSection = [self.sections objectAtIndex:indexPath.section];
    NSArray* rows = [dicoSection objectForKey:@"entries"];

    
    if (indexPath.row == 0)
    {
        style = @"MenuRowFirst";
        selectedStyle = @"MenuRowFirstSelected";
    }
    
    else if ( (indexPath.section == (self.sections.count -1)) && (indexPath.row == (rows.count -1)))
    {
        style = @"MenuRowInter";        
        selectedStyle = @"MenuRowFirstSelected";
    }
    
    else if (indexPath.row == (rows.count -1))
    {
        style = @"MenuRowLast";    
        selectedStyle = @"MenuRowFirstSelected";
    }
    else
    {
        style = @"MenuRowInter";        
        selectedStyle = @"MenuRowFirstSelected";
    }

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:style retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
    view.frame = sheet.frame;
    cell.backgroundView = view;
    [view release];

    sheet = [[Theme theme] stylesheetForKey:selectedStyle retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* selectedView = [[UIImageView alloc] initWithImage:[sheet image]];
    selectedView.frame = sheet.frame;
    cell.selectedBackgroundView = selectedView;
    [selectedView release];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary* dicoSection = [self.sections objectAtIndex:indexPath.section];
    NSArray* rows = [dicoSection objectForKey:@"entries"];
    NSDictionary* row = [rows objectAtIndex:indexPath.row];
    
    NSString* type = [row objectForKey:@"type"];
    
    
    if ([type isEqualToString:TYPE_NOTIFICATIONS])
    {
        NSInteger unread = [[YasoundNotifCenter main] unreadNotifCount];
        if (!_notificationsCell)
            _notificationsCell = [[NotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil unreadCount:unread];

        [_notificationsCell setUnreadCount:unread];

        _notificationsCell.name.text = [row objectForKey:@"name"];
        [_notificationsCell.icon setUrl:[NSURL URLWithString:[row objectForKey:@"image"]]];

        return _notificationsCell;
        
    }
    else
    {
        static NSString* CellIdentifier = @"Cell";

        MenuTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) 
            cell = [[[MenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];    

        cell.name.text = [row objectForKey:@"name"];
        [cell.icon setUrl:[NSURL URLWithString:[row objectForKey:@"image"]]];
    }
}

         
         

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dicoSection = [self.sections objectAtIndex:indexPath.section];
    NSArray* rows = [dicoSection objectForKey:@"entries"];
    NSDictionary* row = [rows objectAtIndex:indexPath.row];
    
    NSString* type = [row objectForKey:@"type"];

    
#define  @"radio"
#define TYPE_RADIO_LIST @"radioList"
#define TYPE_USER @"user"
#define TYPE_USER_LIST @"user_list"
#define TYPE_WEB_PAGE @"web_page"
#define TYPE_RADIO_SEARCH @"radio_search"
#define TYPE_FRIENDS @"friends"
#define TYPE_NOTIFICATIONS @"notifications"
#define TYPE_STATS @"stats"
#define TYPE_SETTINGS @"settings"
#define TYPE_PROGRAMMING @"programming"
#define TYPE_LOGOUT @"logout"

    
    if ([type isEqualToString:TYPE_RADIO])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MY_RADIO object:nil];
        return;
    }
    
    else if (indexPath.section == SECTION_RADIOS)
    {
        if (indexPath.row == ROW_RADIOS_FAVORITES)
        {
            FavoritesViewController* view = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil title:NSLocalizedString(@"selection_tab_favorites", nil) tabIcon:@"tabIconTop.png"];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else if (indexPath.row == ROW_RADIOS_FRIENDS)
        {
            FriendsViewController* view = [[FriendsViewController alloc] initWithNibName:@"FriendsViewController" bundle:nil title:NSLocalizedString(@"selection_tab_friends", nil) tabIcon:@"tabIconFavorites.png"];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else if (indexPath.row == ROW_RADIOS_SELECTION)
        {
            RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil type:RSTSelection];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else if (indexPath.row == ROW_RADIOS_TOP)
        {
            RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil type:RSTTop];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else if (indexPath.row == ROW_RADIOS_SEARCH)
        {
            RadioSearchViewController* view = [[RadioSearchViewController alloc] initWithNibName:@"RadioSearchViewController" bundle:nil title:NSLocalizedString(@"selection_tab_search", nil) tabItem:UITabBarSystemItemSearch];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
    }
    
    else if (indexPath.section == SECTION_ME)
    {
      if (indexPath.row == ROW_ME_NOTIFS)
      {
        NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
      }
        else if (indexPath.row == ROW_ME_STATS)
        {
//            StatsViewController* view = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil];
//            
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
          YasoundAppDelegate* appDelegate = (YasoundAppDelegate*)[[UIApplication sharedApplication] delegate];
          [appDelegate goToMyRadioStatsFromViewController:self];
        }
        else if (indexPath.row == ROW_ME_PROGRAMMING)
        {
//            PlaylistsViewController* view = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil wizard:NO];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];

//            YasoundAppDelegate* appDelegate = (YasoundAppDelegate*)[[UIApplication sharedApplication] delegate];
//          [appDelegate goToMyRadioPlaylistsFromViewController:self];
            
            ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else if (indexPath.row == ROW_ME_CONFIG)
        {
            SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:NO radio:[YasoundDataProvider main].radio];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
    }
    
    
    
    
    else if (indexPath.section == SECTION_MISC)
    {
        if (indexPath.row == ROW_MISC_LEGAL)
        {
            LegalViewController* view = [[LegalViewController alloc] initWithNibName:@"LegalViewController" bundle:nil wizard:NO];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else if (indexPath.row == ROW_MISC_LOGOUT)
        {
            [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
            
            UIActionSheet* popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_logout_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SettingsView_logout_logout", nil), nil];
            
            popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//            [popupQuery showFromTabBar:self.view];
            [popupQuery showFromRect:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height, popupQuery.frame.size.width, popupQuery.frame.size.height) inView:self.view animated:YES];
            [popupQuery release];
        }    
    }    
}


#pragma mark - ActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{    
    if (buttonIndex == 0)
    {
        [[AudioStreamManager main] stopRadio];
        [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutDidReturned)];
    }
}






- (void)logoutDidReturned
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_SCREEN object:nil];
}







#pragma mark - IBActions

- (IBAction)nowPlayingClicked:(id)sender
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}






@end
