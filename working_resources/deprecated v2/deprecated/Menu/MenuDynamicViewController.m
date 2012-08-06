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
#import "WebPageViewController.h"
#import "AudioStreamManager.h"
#import "YasoundSessionManager.h"
#import "RootViewController.h"
#import "BundleStylesheet.h"
#import "Theme.h"
#import "YasoundAppDelegate.h"
#import "ProgrammingViewController.h"

#import "NotificationCenterViewController.h"
#import "MenuTableViewCell.h"
#import "YasoundDataCache.h"


@implementation MenuDynamicViewController


@synthesize sections;


#define TYPE_MYRADIO @"my_radio"
#define TYPE_RADIO @"radio"
#define TYPE_RADIO_LIST @"radio_list"
#define TYPE_USER @"user"
#define TYPE_USER_LIST @"user_list"
#define TYPE_WEB_PAGE @"web_page"
#define TYPE_RADIO_SEARCH @"search_radio"
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
        _unreadNotifications = 0;
        
        
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

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _tableView.sectionHeaderHeight = sheet.frame.size.height;

    sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuRowSingle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _tableView.rowHeight = sheet.frame.size.height;
    
    sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuBackground" error:nil];    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);
    
    

}






- (void)viewWillAppear:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iOsNotificationReceived:) name:NOTIF_HANDLE_IOS_NOTIFICATION object:nil];
}



- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
    
    // authenticated session : get the current notifications count
    if ([YasoundSessionManager main].registered)
        [[YasoundDataProvider main] userNotificationsWithTarget:self action:@selector(onNotificationsReceived:success:) limit:25 offset:0];

  
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
  
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)iOsNotificationReceived:(NSNotification*)notif
{
  if (!_notificationsCell)
    return;
    
    if ([YasoundSessionManager main].registered)
        [[YasoundDataProvider main] userNotificationsWithTarget:self action:@selector(onNotificationsReceived:success:) limit:25 offset:0];

}



- (void)onNotificationsReceived:(ASIHTTPRequest*)req success:(BOOL)success
{   
    if (!success)
    {
        DLog(@"get user notifications FAILED");
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[UserNotification class]];
    NSArray* notifications = container.objects;
    
    if (notifications == nil)
        DLog(@"error receiving notifications");
    
    _unreadNotifications = 0;
    
    for (UserNotification* notif in notifications)
        if (![notif isReadBool])
            _unreadNotifications++;
    
    DLog(@"unread notifications %d", _unreadNotifications);

    [_notificationsCell setUnreadCount:_unreadNotifications];
    
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
        DLog(@"DynamicMenu parsing error");
        DLog(@"%@", self.sections);
        assert(0);
        return 0;
    }    
    
    return rows.count;
}




- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary* dicoSection = [self.sections objectAtIndex:section];
    
    NSString* title = [dicoSection objectForKey:@"name"];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];

    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 44);
    
    sheet = [[Theme theme] stylesheetForKey:@"Menu.MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
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
    NSDictionary* row = [rows objectAtIndex:indexPath.row];

    NSString* type = [row objectForKey:@"type"];

    
    if (indexPath.row == 0)
    {
        style = @"Menu.MenuRowFirst";
        selectedStyle = @"Menu.MenuRowFirstSelected";
    }
    
    else if ( (indexPath.section == (self.sections.count -1)) && (indexPath.row == (rows.count -1)))
    {
        style = @"Menu.MenuRowInter";        
        selectedStyle = @"Menu.MenuRowFirstSelected";
    }
    
    else if (indexPath.row == (rows.count -1))
    {
        style = @"Menu.MenuRowLast";    
        selectedStyle = @"Menu.MenuRowFirstSelected";
    }
    else
    {
        style = @"Menu.MenuRowInter";        
        selectedStyle = @"Menu.MenuRowFirstSelected";
    }

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:style retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
    view.frame = sheet.frame;
    cell.backgroundView = view;
    [view release];
    
    BOOL enabled = YES;
    
    if ([type isEqualToString:TYPE_NOTIFICATIONS])
    {
        NotificationTableViewCell* notifCell = cell;
        enabled = notifCell.enabled;
    }
    else
    if ([cell isKindOfClass:[MenuTableViewCell class]])
    {
        MenuTableViewCell* menuCell = cell;
        enabled = menuCell.enabled;
    }

    if (enabled)
    {
        sheet = [[Theme theme] stylesheetForKey:selectedStyle retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* selectedView = [[UIImageView alloc] initWithImage:[sheet image]];
        selectedView.frame = sheet.frame;
        cell.selectedBackgroundView = selectedView;
        [selectedView release];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary* dicoSection = [self.sections objectAtIndex:indexPath.section];
    NSArray* rows = [dicoSection objectForKey:@"entries"];
    NSDictionary* row = [rows objectAtIndex:indexPath.row];
    
    NSString* type = [row objectForKey:@"type"];
    NSString* cellId = [row objectForKey:@"id"];
    
    NSString* imageRef = nil;
    NSError* error = nil;
    BundleStylesheet* sheet = nil;
    
    if ([type isEqualToString:TYPE_NOTIFICATIONS])
    {
        if (!_notificationsCell)
            _notificationsCell = [[NotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil unreadCount:_unreadNotifications];

        [_notificationsCell setUnreadCount:_unreadNotifications];

        _notificationsCell.name.text = [row objectForKey:@"name"];
        
        imageRef = [row objectForKey:@"image"];
        if ((imageRef == nil) || (imageRef.length == 0))
        {
            [_notificationsCell.icon setUrl:[NSURL URLWithString:@""]];
        }
        else
        {
            imageRef = [NSString stringWithFormat:@"Icons.%@", imageRef];
            sheet = [[Theme theme] stylesheetForKey:imageRef retainStylesheet:YES overwriteStylesheet:NO error:&error];
            
            if (error == nil)
                [_notificationsCell.icon setImage:[sheet image]];
            else
                [_notificationsCell.icon setUrl:[NSURL URLWithString:imageRef]];
        }
        
        _notificationsCell.enabled = ([YasoundSessionManager main].registered) ? YES : NO;

        return _notificationsCell;
        
    }
    else
    {
        static NSString* CellIdentifier = @"Cell";

        // get the cell automatically from the dynamic description
        MenuTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) 
            cell = [[[MenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];    

        cell.name.text = [row objectForKey:@"name"];

        // with icon
        imageRef = [row objectForKey:@"image"];
        if ((imageRef == nil) || (imageRef.length == 0))
        {
            [cell.icon setUrl:[NSURL URLWithString:@""]];
        }
        else
        {
            imageRef = [NSString stringWithFormat:@"Icons.%@", imageRef];
            sheet = [[Theme theme] stylesheetForKey:imageRef retainStylesheet:YES overwriteStylesheet:NO error:&error];
            
            if (error == nil)
                [cell.icon setImage:[sheet image]];
            else
                [cell.icon setUrl:[NSURL URLWithString:imageRef]];
        }
        
        // disable some cells if you're in anonymous session
        if ([type isEqualToString:TYPE_MYRADIO] || 
            [type isEqualToString:TYPE_FRIENDS] || 
            [type isEqualToString:TYPE_NOTIFICATIONS] || 
            [type isEqualToString:TYPE_STATS] || 
            [type isEqualToString:TYPE_SETTINGS] || 
            [type isEqualToString:TYPE_PROGRAMMING] ||
            [cellId isEqualToString:@"radioMyFavorites"])
        {
            cell.enabled = ([YasoundSessionManager main].registered) ? YES : NO;        
        }
        else
            cell.enabled = YES;        
        
        // special case for the login/logout cell
        if ([type isEqualToString:TYPE_LOGOUT])
        {
            if ([YasoundSessionManager main].registered) 
                cell.name.text = NSLocalizedString(@"MenuView_session_logout", nil);
            else
                cell.name.text = NSLocalizedString(@"MenuView_session_login", nil);
        }
            

        return cell;
    }
}

         
         

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dicoSection = [self.sections objectAtIndex:indexPath.section];
    NSArray* rows = [dicoSection objectForKey:@"entries"];
    NSDictionary* row = [rows objectAtIndex:indexPath.row];
    
    NSString* name = [row objectForKey:@"name"];
    NSString* type = [row objectForKey:@"type"];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MenuTableViewCell class]])
    {
        MenuTableViewCell* menuCell = cell;
        if (!menuCell.enabled)
            return;
    }

    
    if ([type isEqualToString:TYPE_MYRADIO])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MYRADIO object:nil];
        return;
    }
    
    if ([type isEqualToString:TYPE_RADIO])
    {
        NSNumber* radio_id_nb = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_RADIO_ID forEntry:row];
        assert(radio_id_nb != nil);
        //NSInteger radio_id = [radio_id_nb integerValue];

        [[YasoundDataProvider main] radioWithId:radio_id_nb target:self action:@selector(onGetRadio:info:)];
        
        return;
    }

    if ([type isEqualToString:TYPE_RADIO_LIST])
    {
        NSString* url = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_URL forEntry:row];
         NSNumber* genre_selection = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_GENRE_SELECTION forEntry:row];

        BOOL displayGenreSelector = YES;
        if (genre_selection != nil)
            displayGenreSelector = [genre_selection boolValue];
        
        if (!displayGenreSelector)
        {
            FavoritesViewController* view = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil withUrl:[NSURL URLWithString:url] andTitle:name];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else
        {
            RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }

        return;
    }
    
    if ([type isEqualToString:TYPE_USER])
    {
        DLog(@"TODO");
        assert(0);
        return;
    }
    
    if ([type isEqualToString:TYPE_USER_LIST])
    {
        DLog(@"TODO");
        assert(0);
        return;
    }

    if ([type isEqualToString:TYPE_FRIENDS])
    {
        FriendsViewController* view = [[FriendsViewController alloc] initWithNibName:@"FriendsViewController" bundle:nil title:NSLocalizedString(@"selection_tab_friends", nil) tabIcon:@"tabIconFavorites.png"];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }


    if ([type isEqualToString:TYPE_WEB_PAGE])
    {
        NSString* url = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_URL forEntry:row];

        WebPageViewController* view = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil withUrl:[NSURL URLWithString:url] andTitle:name];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    if ([type isEqualToString:TYPE_RADIO_SEARCH])
    {
        RadioSearchViewController* view = [[RadioSearchViewController alloc] initWithNibName:@"RadioSearchViewController" bundle:nil title:NSLocalizedString(@"selection_tab_search", nil) tabItem:UITabBarSystemItemSearch];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    if ([type isEqualToString:TYPE_NOTIFICATIONS])
    {
        NotificationTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell.enabled)
            return;
            
            
        NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    if ([type isEqualToString:TYPE_STATS])
    {
        YasoundAppDelegate* appDelegate = (YasoundAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate goToMyRadioStatsFromViewController:self];
        return;
    }
    
    if ([type isEqualToString:TYPE_SETTINGS])
    {
        SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:NO radio:[YasoundDataProvider main].radio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }

    if ([type isEqualToString:TYPE_PROGRAMMING])
    {
        ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }

    if ([type isEqualToString:TYPE_LOGOUT])
    {
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
        
        // we're in anonymous session. user wants to log in.
        if (![YasoundSessionManager main].registered)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_LOGIN object:nil];
            return;
        }
        
        // we're in authenticated session. user wants to log out.
        UIActionSheet* popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_logout_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SettingsView_logout_logout", nil), nil];
        
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [popupQuery showFromRect:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height, popupQuery.frame.size.width, popupQuery.frame.size.height) inView:self.view animated:YES];
        [popupQuery release];
        return;
    }    
}
                                             
                                             
                                             
                                             
               

- (void)onGetRadio:(Radio*)radio info:(NSDictionary*)dico
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MENU object:nil];
    [_tableView reloadData];
    
}







#pragma mark - IBActions

- (IBAction)nowPlayingClicked:(id)sender
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}






@end