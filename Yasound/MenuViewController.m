//
//  MenuViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MenuViewController.h"
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



@implementation MenuViewController

#define SECTION_MYRADIO 0
#define ROW_MYRADIO 0

#define SECTION_RADIOS 1
#define ROW_RADIOS_FRIENDS 0
#define ROW_RADIOS_FAVORITES 1
#define ROW_RADIOS_SELECTION 2
#define ROW_RADIOS_SEARCH 3

#define SECTION_ME 2
#define ROW_ME_STATS 0
#define ROW_ME_PLAYLISTS 1
#define ROW_ME_CONFIG 2

#define SECTION_MISC 3
#define ROW_MISC_LEGAL 0
#define ROW_MISC_LOGOUT 1


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
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
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_MYRADIO)
        return NSLocalizedString(@"MenuView_section_myradio", nil);
    
    if (section == SECTION_RADIOS)
        return NSLocalizedString(@"MenuView_section_radios", nil);
    
    if (section == SECTION_ME)
        return NSLocalizedString(@"MenuView_section_me", nil);
    
    if (section == SECTION_MISC)
        return NSLocalizedString(@"MenuView_section_misc", nil);

    return nil;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECTION_MYRADIO)
        return 1;
    
    if (section == SECTION_RADIOS)
        return 4;
    
    if (section == SECTION_ME)
        return 3;
    
    if (section == SECTION_MISC)
        return 2;
  
  return 0;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIView* view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1];
    cell.backgroundView = view;
    [view release];    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 55;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.textColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if ((indexPath.section == SECTION_MYRADIO) && (indexPath.row == ROW_MYRADIO))
    {
        cell.textLabel.text = NSLocalizedString(@"MenuView_myradio_myradio", nil);
        [cell.imageView setImage:[UIImage imageNamed:@"iconMyRadio.png"]];
    }
    
    else if (indexPath.section == SECTION_RADIOS)
    {
        if (indexPath.row == ROW_RADIOS_FAVORITES)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_radios_favorites", nil);            
            [cell.imageView setImage:[UIImage imageNamed:@"tabIconTop.png"]];
        }
        else if (indexPath.row == ROW_RADIOS_FRIENDS)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_radios_friends", nil);            
            [cell.imageView setImage:[UIImage imageNamed:@"tabIconFavorites.png"]];
        }
        else if (indexPath.row == ROW_RADIOS_SELECTION)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_radios_selection", nil);            
            [cell.imageView setImage:[UIImage imageNamed:@"tabIconNew.png"]];
        }
        else if (indexPath.row == ROW_RADIOS_SEARCH)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_radios_search", nil);            
            [cell.imageView setImage:[UIImage imageNamed:@"tabIconSearch.png"]];
        }
    }
    
    else if (indexPath.section == SECTION_ME)
    {
        if (indexPath.row == ROW_ME_STATS)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_me_stats", nil);            
            [cell.imageView setImage:[UIImage imageNamed:@"iconStats.png"]];
        }
        else if (indexPath.row == ROW_ME_PLAYLISTS)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_me_playlists", nil);            
            [cell.imageView setImage:[UIImage imageNamed:@"iconPlaylists.png"]];
        }
        else if (indexPath.row == ROW_ME_CONFIG)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_me_config", nil);            
            [cell.imageView setImage:[UIImage imageNamed:@"iconSettings.png"]];
        }
    }
    
    else if (indexPath.section == SECTION_MISC)
    {
        if (indexPath.row == ROW_MISC_LEGAL)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_misc_legal", nil);            
            [cell.imageView setImage:[UIImage imageNamed:@"iconLegal.png"]];
        }
        else if (indexPath.row == ROW_MISC_LOGOUT)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_misc_logout", nil);            
            [cell.imageView setImage:[UIImage imageNamed:@"iconLogout.png"]];
        }    
    }

    
    return cell;   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_MYRADIO) && (indexPath.row == ROW_MYRADIO))
    {
        RadioViewController* view = [[RadioViewController alloc] initWithRadio:[YasoundDataProvider main].radio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
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
            RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:NSLocalizedString(@"selection_tab_selection", nil) tabIcon:@"tabIconNew.png"];
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
        if (indexPath.row == ROW_ME_STATS)
        {
            StatsViewController* view = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil];
            
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else if (indexPath.row == ROW_ME_PLAYLISTS)
        {
            PlaylistsViewController* view = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil wizard:NO];
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





@end
