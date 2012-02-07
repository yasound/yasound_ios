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
#import "BundleStylesheet.h"
#import "Theme.h"


@implementation MenuViewController

#define SECTION_MYRADIO 0
#define SECTION_MYRADIO_NB_ROWS 1
#define ROW_MYRADIO 0

#define SECTION_RADIOS 1
#define SECTION_RADIOS_NB_ROWS 4
#define ROW_RADIOS_FRIENDS 0
#define ROW_RADIOS_FAVORITES 1
#define ROW_RADIOS_SELECTION 2
#define ROW_RADIOS_SEARCH 3

#define SECTION_ME 2
#define SECTION_ME_NB_ROWS 3
#define ROW_ME_STATS 0
#define ROW_ME_PLAYLISTS 1
#define ROW_ME_CONFIG 2

#define SECTION_MISC 3
#define SECTION_MISC_NB_ROWS 2
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

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _tableView.sectionHeaderHeight = sheet.frame.size.height;

    sheet = [[Theme theme] stylesheetForKey:@"MenuRowSingle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _tableView.rowHeight = sheet.frame.size.height;
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuBackground" error:nil];    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    

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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == SECTION_MYRADIO)
//        return NSLocalizedString(@"MenuView_section_myradio", nil);
//    
//    if (section == SECTION_RADIOS)
//        return NSLocalizedString(@"MenuView_section_radios", nil);
//    
//    if (section == SECTION_ME)
//        return NSLocalizedString(@"MenuView_section_me", nil);
//    
//    if (section == SECTION_MISC)
//        return NSLocalizedString(@"MenuView_section_misc", nil);
//
//    return nil;
//}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECTION_MYRADIO)
        return SECTION_MYRADIO_NB_ROWS;
    
    if (section == SECTION_RADIOS)
        return SECTION_RADIOS_NB_ROWS;
    
    if (section == SECTION_ME)
        return SECTION_ME_NB_ROWS;
    
    if (section == SECTION_MISC)
        return SECTION_MISC_NB_ROWS;
  
  return 0;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    
    if (section == SECTION_MYRADIO)
        title = NSLocalizedString(@"MenuView_section_myradio", nil);
    
    else if (section == SECTION_RADIOS)
        title = NSLocalizedString(@"MenuView_section_radios", nil);
    
    else if (section == SECTION_ME)
        title = NSLocalizedString(@"MenuView_section_me", nil);
    
    else if (section == SECTION_MISC)
        title = NSLocalizedString(@"MenuView_section_misc", nil);

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];

    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 44);
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
    
    
//	NSString *title = nil;
//    // Return a title or nil as appropriate for the section.
//    
//	switch (section) 
//    {
//        case 0:
//            title = @"iPhone Apps Development";
//            break;
//        case SPENDING_LIST:
//            title = @"Android Apps Development";
//            break;
//        default:
//            break;
//    }
//    
//	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
//	[v setBackgroundColor:[UIColor blackColor]];
//    
//	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10,3, tableView.bounds.size.width - 10,40)] autorelease];
//	label.text = title;
//	label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.60];
//	label.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
//	label.backgroundColor = [UIColor clearColor];
//	[v addSubview:label];
//    
//	return v;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString* style = nil;
    
    if ((indexPath.section == SECTION_MYRADIO) && (indexPath.row == ROW_MYRADIO))
    {
        style = @"MenuRowSingle";
    }
    
    else if (indexPath.row == 0)
    {
        style = @"MenuRowFirst";
    }
    
    else if (
             ((indexPath.section == SECTION_RADIOS) && (indexPath.row == SECTION_RADIOS_NB_ROWS-1)) || 
             ((indexPath.section == SECTION_ME) && (indexPath.row == SECTION_ME_NB_ROWS-1)) )
    {
        style = @"MenuRowLast";    
    }
    else if ((indexPath.section == SECTION_MISC) && (indexPath.row == SECTION_MISC_NB_ROWS-1))
    {
        style = @"MenuRowInter";        
    }
    else
    {
        style = @"MenuRowInter";        
    }

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:style retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
    view.frame = sheet.frame;
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
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconMyRadio" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [cell.imageView setImage:[sheet image]];
    }
    
    else if (indexPath.section == SECTION_RADIOS)
    {
        if (indexPath.row == ROW_RADIOS_FAVORITES)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_radios_favorites", nil);            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconRadiosFavorites" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            [cell.imageView setImage:[sheet image]];
        }
        else if (indexPath.row == ROW_RADIOS_FRIENDS)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_radios_friends", nil);            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconRadiosFriends" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            [cell.imageView setImage:[sheet image]];
        }
        else if (indexPath.row == ROW_RADIOS_SELECTION)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_radios_selection", nil);            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconRadiosSelection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            [cell.imageView setImage:[sheet image]];
        }
        else if (indexPath.row == ROW_RADIOS_SEARCH)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_radios_search", nil);            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconRadiosSearch" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            [cell.imageView setImage:[sheet image]];
        }
    }
    
    else if (indexPath.section == SECTION_ME)
    {
        if (indexPath.row == ROW_ME_STATS)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_me_stats", nil);            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconMeStats" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            [cell.imageView setImage:[sheet image]];
        }
        else if (indexPath.row == ROW_ME_PLAYLISTS)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_me_playlists", nil);            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconMePlaylists" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            [cell.imageView setImage:[sheet image]];
        }
        else if (indexPath.row == ROW_ME_CONFIG)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_me_config", nil);            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconMeSettings" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            [cell.imageView setImage:[sheet image]];
        }
    }
    
    else if (indexPath.section == SECTION_MISC)
    {
        if (indexPath.row == ROW_MISC_LEGAL)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_misc_legal", nil);            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconMiscLegal" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            [cell.imageView setImage:[sheet image]];
        }
        else if (indexPath.row == ROW_MISC_LOGOUT)
        {
            cell.textLabel.text = NSLocalizedString(@"MenuView_misc_logout", nil);            
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"IconMiscLogout" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            [cell.imageView setImage:[sheet image]];
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
