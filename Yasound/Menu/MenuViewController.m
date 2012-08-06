//
//  MenuViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MenuViewController.h"
#import "Theme.h"
#import "TopBar.h"
#import "RadioViewController.h"
#import "AudioStreamManager.h"
#import <QuartzCore/QuartzCore.h>
//#import "RadioViewController.h"
//#import "YasoundDataProvider.h"
//#import "RadioSelectionViewController.h"
//#import "RadioSearchViewController.h"
//#import "FriendsViewController.h"
//#import "FavoritesViewController.h"
//#import "StatsViewController.h"
//#import "PlaylistsViewController.h"
//#import "SettingsViewController.h"
//#import "WebPageViewController.h"
//#import "AudioStreamManager.h"
//#import "YasoundSessionManager.h"
//#import "RootViewController.h"
//#import "BundleStylesheet.h"
//#import "Theme.h"
//#import "YasoundAppDelegate.h"
//#import "ProgrammingViewController.h"
//
//#import "NotificationCenterViewController.h"




@implementation MenuViewController



enum MenuDescription
{
    ROW_RADIOS,
    ROW_LOGIN,
    ROW_ACCOUNT,
    ROW_NOTIFS,
    ROW_FACEBOOK,
    ROW_TWITTER,
    ROW_YASOUND,
    ROW_LEGAL,
    NB_ROWS
};




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
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
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menuBkg.png"]];
}


- (void)viewWillAppear:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
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
    return NB_ROWS;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Menu.row" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    cell.backgroundView = view;
    [view release];

    sheet = [[Theme theme] stylesheetForKey:@"Menu.rowHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* selectedView = [sheet makeImage];
    cell.selectedBackgroundView = selectedView;
    [selectedView release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
  UITableViewCell *cell = nil;
  
    cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];    
  

    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.textColor = [UIColor colorWithRed:195.f/255.f green:205.f/255.f blue:212.f/255.f alpha:1];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.layer.shadowOffset = CGSizeMake(1, 1);
    cell.textLabel.layer.shadowOpacity = 0.75;
    cell.textLabel.layer.shadowRadius = 0.5;
    

    if (indexPath.row == ROW_RADIOS)
    {
        cell.textLabel.text = NSLocalizedString(@"Menu.radios", nil);
        [cell.imageView setImage:[UIImage imageNamed:@"menuIconRadios.png"]];
    }

    else if (indexPath.row == ROW_LOGIN)
    {
        cell.textLabel.text = NSLocalizedString(@"Menu.login", nil);
        [cell.imageView setImage:[UIImage imageNamed:@"menuIconLogin.png"]];
    }

    else if (indexPath.row == ROW_ACCOUNT)
    {
        cell.textLabel.text = NSLocalizedString(@"Menu.account", nil);
        [cell.imageView setImage:[UIImage imageNamed:@"menuIconAccount.png"]];
    }

    else if (indexPath.row == ROW_NOTIFS)
    {
        cell.textLabel.text = NSLocalizedString(@"Menu.notifs", nil);
        [cell.imageView setImage:[UIImage imageNamed:@"menuIconNotifs.png"]];
    }

    else if (indexPath.row == ROW_FACEBOOK)
    {
        cell.textLabel.text = NSLocalizedString(@"Menu.facebook", nil);
        [cell.imageView setImage:[UIImage imageNamed:@"menuIconFacebook.png"]];
    }

    else if (indexPath.row == ROW_TWITTER)
    {
        cell.textLabel.text = NSLocalizedString(@"Menu.twitter", nil);
        [cell.imageView setImage:[UIImage imageNamed:@"menuIconTwitter.png"]];
    }

    else if (indexPath.row == ROW_YASOUND)
    {
        cell.textLabel.text = NSLocalizedString(@"Menu.yasound", nil);
        [cell.imageView setImage:[UIImage imageNamed:@"menuIconYasound.png"]];
    }

    else if (indexPath.row == ROW_LEGAL)
    {
        cell.textLabel.text = NSLocalizedString(@"Menu.legal", nil);
        [cell.imageView setImage:[UIImage imageNamed:@"menuIconLegal.png"]];
    }

    
    return cell;   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath_deprecated:(NSIndexPath *)indexPath
{
//    if ((indexPath.section == SECTION_MYRADIO) && (indexPath.row == ROW_MYRADIO_MYRADIO))
//    {
////        RadioViewController* view = [[RadioViewController alloc] initWithRadio:[YasoundDataProvider main].radio];
////        [self.navigationController pushViewController:view animated:YES];
////        [view release];
//      YasoundAppDelegate* appDelegate =  (YasoundAppDelegate*)[[UIApplication sharedApplication] delegate];
//      [appDelegate goToMyRadioFromViewController:self];
//    }
//    
//    else if (indexPath.section == SECTION_RADIOS)
//    {
//        if (indexPath.row == ROW_RADIOS_FAVORITES)
//        {
//            FavoritesViewController* view = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil title:NSLocalizedString(@"selection_tab_favorites", nil) tabIcon:@"tabIconTop.png"];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//        }
//        else if (indexPath.row == ROW_RADIOS_FRIENDS)
//        {
//            FriendsViewController* view = [[FriendsViewController alloc] initWithNibName:@"FriendsViewController" bundle:nil title:NSLocalizedString(@"selection_tab_friends", nil) tabIcon:@"tabIconFavorites.png"];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//        }
//        else if (indexPath.row == ROW_RADIOS_SELECTION)
//        {
//            RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil type:RSTSelection];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//        }
//        else if (indexPath.row == ROW_RADIOS_TOP)
//        {
//            RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil type:RSTTop];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//        }
//        else if (indexPath.row == ROW_RADIOS_SEARCH)
//        {
//            RadioSearchViewController* view = [[RadioSearchViewController alloc] initWithNibName:@"RadioSearchViewController" bundle:nil title:NSLocalizedString(@"selection_tab_search", nil) tabItem:UITabBarSystemItemSearch];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//        }
//    }
//    
//    else if (indexPath.section == SECTION_ME)
//    {
//      if (indexPath.row == ROW_ME_NOTIFS)
//      {
//        NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//      }
//        else if (indexPath.row == ROW_ME_STATS)
//        {
////            StatsViewController* view = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil];
////            
////            [self.navigationController pushViewController:view animated:YES];
////            [view release];
//          YasoundAppDelegate* appDelegate = (YasoundAppDelegate*)[[UIApplication sharedApplication] delegate];
//          [appDelegate goToMyRadioStatsFromViewController:self];
//        }
//        else if (indexPath.row == ROW_ME_PROGRAMMING)
//        {
////            PlaylistsViewController* view = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil wizard:NO];
////            [self.navigationController pushViewController:view animated:YES];
////            [view release];
//
////            YasoundAppDelegate* appDelegate = (YasoundAppDelegate*)[[UIApplication sharedApplication] delegate];
////          [appDelegate goToMyRadioPlaylistsFromViewController:self];
//            
//            ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//        }
//        else if (indexPath.row == ROW_ME_CONFIG)
//        {
//            SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:NO radio:[YasoundDataProvider main].radio];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//        }
//    }
//    
//    
//    
//    
//    else if (indexPath.section == SECTION_MISC)
//    {
//        if (indexPath.row == ROW_MISC_LEGAL)
//        {
//            LegalViewController* view = [[LegalViewController alloc] initWithNibName:@"LegalViewController" bundle:nil wizard:NO];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//        }
//        else if (indexPath.row == ROW_MISC_LOGOUT)
//        {
//            [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
//            
//            UIActionSheet* popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_logout_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SettingsView_logout_logout", nil), nil];
//            
//            popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
////            [popupQuery showFromTabBar:self.view];
//            [popupQuery showFromRect:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height, popupQuery.frame.size.width, popupQuery.frame.size.height) inView:self.view animated:YES];
//            [popupQuery release];
//        }    
//    }    
}


//#pragma mark - ActionSheet Delegate
//
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
//{    
//    if (buttonIndex == 0)
//    {
//        [[AudioStreamManager main] stopRadio];
//        [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutDidReturned)];
//    }
//}






//- (void)logoutDidReturned
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_SCREEN object:nil];
//}





#pragma mark - TopBarDelegate

- (void)topBarBackItemClicked:(TopBarItemId)itemId
{
    if (itemId == TopBarItemNotif)
    {
        
    }
    
    else if (itemId == TopBarItemNowPlaying)
    {
        RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}





@end
