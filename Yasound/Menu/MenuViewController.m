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
#import "AudioStreamManager.h"
#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "MyAccountViewController.h"
#import "NotificationViewController.h"
#import "AccountFacebookViewController.h"
#import "AccountTwitterViewController.h"
#import "AccountYasoundViewController.h"
#import "WebPageViewController.h"
#import "YasoundDataCache.h"
#import "YasoundSessionManager.h"
#import "ActivityAlertView.h"
#import "YasoundAppDelegate.h"
#import "Version.h"



@implementation MenuViewController


enum MenuDescription
{
    ROW_RADIOS,
    ROW_ACCOUNT,
    ROW_NOTIFS,
    ROW_FACEBOOK,
    ROW_TWITTER,
    ROW_YASOUND,
    ROW_LEGAL,
    ROW_LOGIN,
    NB_ROWS
};


- (void)dealloc
{
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        [APPDELEGATE.slideController setAnchorRightRevealAmount:264.0f];
        [APPDELEGATE.slideController setUnderLeftWidthLayout:ECFullWidth];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        {
            [self.view addGestureRecognizer:[APPDELEGATE.slideController panGesture]];
        }
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
    
//    // set background
//    if ([self.searchbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)])
//        [self.searchbar setBackgroundImage:[UIImage imageNamed:@"topBarBkg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
//    else
//        [self.searchbar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topBarBkg.png"]] autorelease] atIndex:0];

}

//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
//    
//}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
    [_tableView reloadData];
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
#ifdef DEBUG
    return 2;
#endif
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
        return 1;
    
    NSInteger nb = NB_ROWS;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        nb--;
    
    return nb;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        row++;

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


- (void)setCell:(UITableViewCell*)cell refText:(NSString*)refText icon:(NSString*)icon authenticated:(BOOL)authenticated
{
    cell.textLabel.textColor = [UIColor colorWithRed:195.f/255.f green:205.f/255.f blue:212.f/255.f alpha:1];
    cell.textLabel.text = NSLocalizedString(refText, nil);
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:icon retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [cell.imageView setImage:[sheet image]];
//    [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", icon]]];
    
    if ((authenticated && [YasoundSessionManager main].registered) || !authenticated)
    {
        //cell.textLabel.textColor = [UIColor colorWithRed:195.f/255.f green:205.f/255.f blue:212.f/255.f alpha:1];
        cell.textLabel.alpha = 1;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.imageView.alpha = 1;
    }
    else
    {
        //cell.textLabel.textColor = [UIColor colorWithRed:164.f/255.f green:170.f/255.f blue:173.f/255.f alpha:1];
        //[cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Disabled.png", icon]]];
        cell.textLabel.alpha = 0.5;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.alpha = 0.5;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    NSInteger row = indexPath.row;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        row++;

    UITableViewCell *cell = nil;
  
    cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
  

    if (indexPath.section == 1)
    {
        [self setCell:cell refText:@"Menu.clearCache" icon:@"Menu.iconClearCache" authenticated:NO];
        return cell;
    }
    

    if (row == ROW_RADIOS)
        [self setCell:cell refText:@"Menu.radios" icon:@"Menu.iconRadios" authenticated:NO];

    else
        
    if (row == ROW_LOGIN)
    {
        if ([YasoundSessionManager main].registered)
            [self setCell:cell refText:@"Menu.logout" icon:@"Menu.iconLogin" authenticated:NO];
        else
            [self setCell:cell refText:@"Menu.login" icon:@"Menu.iconLogin" authenticated:NO];
    }

    else if (row == ROW_ACCOUNT)
        [self setCell:cell refText:@"Menu.account" icon:@"Menu.iconAccount" authenticated:YES];

    else if (row == ROW_NOTIFS)
        [self setCell:cell refText:@"Menu.notifs" icon:@"Menu.iconNotifs" authenticated:YES];

    else if (row == ROW_FACEBOOK)
        [self setCell:cell refText:@"Menu.facebook" icon:@"Menu.iconFacebook" authenticated:YES];

    else if (row == ROW_TWITTER)
        [self setCell:cell refText:@"Menu.twitter" icon:@"Menu.iconTwitter" authenticated:YES];

    else if (row == ROW_YASOUND)
        [self setCell:cell refText:@"Menu.yasound" icon:@"Menu.iconYasound" authenticated:YES];

    else if (row == ROW_LEGAL)
        [self setCell:cell refText:@"Menu.legal" icon:@"Menu.iconLegal" authenticated:NO];

    
    return cell;   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        row++;

    if (indexPath.section == 1)
    {
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
        [[YasoundDataCache main] clearRadiosAll];
        return;
    }
    
    
    if (![YasoundSessionManager main].registered &&
        ((row == ROW_ACCOUNT)
        || (row == ROW_NOTIFS)
        || (row == ROW_FACEBOOK)
        || (row == ROW_TWITTER)
        || (row == ROW_YASOUND)
        ))
        return;

    
    if ((row == ROW_LOGIN) && ([YasoundSessionManager main].registered))
        {
            [ActivityAlertView showWithTitle:nil closeAfterTimeInterval:2];
            [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
            
            // :)
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onLogoutTick:) userInfo:nil repeats:NO];
            return;
        }

    else if (row == ROW_RADIOS)
    {
        [APPDELEGATE.slideController resetTopView];
    }
    
    
    else
    {
        
        self.programmedCommand = indexPath;
        [self runProgrammedCommand];
        
//        if (row == ROW_LOGIN)
//            [APPDELEGATE.slideController resetTopView];
    }
    
}

- (void)runProgrammedCommand
{
    if (self.programmedCommand == nil)
        return;

    NSInteger row = self.programmedCommand.row;
    
    self.programmedCommand = nil;
    

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        row++;

    
    if ((row == ROW_LOGIN) && !([YasoundSessionManager main].registered))
    {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_LOGIN object:nil];
    }
    
    else if (row == ROW_ACCOUNT)
    {
        MyAccountViewController* view = [[MyAccountViewController alloc] initWithNibName:@"MyAccountViewController" bundle:nil];
        [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
//        [APPDELEGATE.menuNavigationController pushViewController:view animated:YES];
        [view release];
    }
    
    else if (row == ROW_NOTIFS)
    {
        NotificationViewController* view = [[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:nil];
        [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
//        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
    else if (row == ROW_FACEBOOK)
    {
        AccountFacebookViewController* view = [[AccountFacebookViewController alloc] initWithNibName:@"AccountFacebookViewController" bundle:nil];
        [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
//        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (row == ROW_TWITTER)
    {
        AccountTwitterViewController* view = [[AccountTwitterViewController alloc] initWithNibName:@"AccountTwitterViewController" bundle:nil];
        [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
//        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (row == ROW_YASOUND)
    {
        AccountYasoundViewController* view = [[AccountYasoundViewController alloc] initWithNibName:@"AccountYasoundViewController" bundle:nil];
        [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
//        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
    else if (row == ROW_LEGAL)
    {
        NSString* title = NSLocalizedString(@"Menu.legal", nil);
        NSURL* url = [NSURL URLWithString:[APPDELEGATE getServerUrlWith:URL_LEGAL]];
        
        WebPageViewController* view = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil withUrl:url andTitle:title];
        [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
//        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
}




- (void)logoutReturned
{
    [_tableView reloadData];
    [ActivityAlertView close];
}

- (void)onLogoutTick:(NSTimer*)timer
{
    if ([APPDELEGATE.slideController underLeftShowing])
        [APPDELEGATE.slideController resetTopView];
}



#pragma mark - TopBarDelegate

//- (BOOL)topBarItemClicked:(TopBarItemId)itemId
//{
//}





@end
