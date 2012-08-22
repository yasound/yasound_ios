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




@implementation MenuViewController



enum MenuDescription
{
//    ROW_RADIOS,
    ROW_LOGIN,
    ROW_ACCOUNT,
    ROW_NOTIFS,
    ROW_FACEBOOK,
    ROW_TWITTER,
    ROW_YASOUND,
    ROW_LEGAL,
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
        APPDELEGATE.slideController.underLeftWidthLayout = ECFullWidth;
        
        [self.view addGestureRecognizer:APPDELEGATE.slideController.panGesture];
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
    
    [self.topBar hideBackItem:YES];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menuBkg.png"]];
}


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
    
  UITableViewCell *cell = nil;
  
    cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.textLabel.layer.shadowOffset = CGSizeMake(1, 1);
//        cell.textLabel.layer.shadowOpacity = 0.75;
//        cell.textLabel.layer.shadowRadius = 0.5;
    }
  

    

//    if (indexPath.row == ROW_RADIOS)
//        [self setCell:cell refText:@"Menu.radios" icon:@"Menu.iconRadios" authenticated:NO];
//
//    else
        
    if (indexPath.row == ROW_LOGIN)
    {
        if ([YasoundSessionManager main].registered)
            [self setCell:cell refText:@"Menu.logout" icon:@"Menu.iconLogin" authenticated:NO];
        else
            [self setCell:cell refText:@"Menu.login" icon:@"Menu.iconLogin" authenticated:NO];
    }

    else if (indexPath.row == ROW_ACCOUNT)
        [self setCell:cell refText:@"Menu.account" icon:@"Menu.iconAccount" authenticated:YES];

    else if (indexPath.row == ROW_NOTIFS)
        [self setCell:cell refText:@"Menu.notifs" icon:@"Menu.iconNotifs" authenticated:YES];

    else if (indexPath.row == ROW_FACEBOOK)
        [self setCell:cell refText:@"Menu.facebook" icon:@"Menu.iconFacebook" authenticated:YES];

    else if (indexPath.row == ROW_TWITTER)
        [self setCell:cell refText:@"Menu.twitter" icon:@"Menu.iconTwitter" authenticated:YES];

    else if (indexPath.row == ROW_YASOUND)
        [self setCell:cell refText:@"Menu.yasound" icon:@"Menu.iconYasound" authenticated:YES];

    else if (indexPath.row == ROW_LEGAL)
        [self setCell:cell refText:@"Menu.legal" icon:@"Menu.iconLegal" authenticated:NO];

    
    return cell;   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![YasoundSessionManager main].registered &&
        ((indexPath.row == ROW_ACCOUNT)
        || (indexPath.row == ROW_NOTIFS)
        || (indexPath.row == ROW_FACEBOOK)
        || (indexPath.row == ROW_TWITTER)
        || (indexPath.row == ROW_YASOUND)
        ))
        return;

    
//    if (indexPath.row == ROW_RADIOS)
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_SELECTION object:nil];
//    }
//    
//    else
    
    [APPDELEGATE.slideController resetTopView];

    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(onTimerTick:) userInfo:indexPath repeats:NO];
}

- (void)onTimerTick:(NSTimer*)timer
{
    
    NSIndexPath* indexPath = timer.userInfo;
    
    if (indexPath.row == ROW_LOGIN)
    {
        if ([YasoundSessionManager main].registered)
        {
            [ActivityAlertView showWithTitle:nil closeAfterTimeInterval:2];
            [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
        }
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_LOGIN object:nil];
    }
    
    else if (indexPath.row == ROW_ACCOUNT)
    {
        MyAccountViewController* view = [[MyAccountViewController alloc] initWithNibName:@"MyAccountViewController" bundle:nil];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
    else if (indexPath.row == ROW_NOTIFS)
    {
        NotificationViewController* view = [[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:nil];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
    else if (indexPath.row == ROW_FACEBOOK)
    {
        AccountFacebookViewController* view = [[AccountFacebookViewController alloc] initWithNibName:@"AccountFacebookViewController" bundle:nil];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (indexPath.row == ROW_TWITTER)
    {
        AccountTwitterViewController* view = [[AccountTwitterViewController alloc] initWithNibName:@"AccountTwitterViewController" bundle:nil];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (indexPath.row == ROW_YASOUND)
    {
        AccountYasoundViewController* view = [[AccountYasoundViewController alloc] initWithNibName:@"AccountYasoundViewController" bundle:nil];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
    else if (indexPath.row == ROW_LEGAL)
    {
        NSURL* url = [NSURL URLWithString:URL_LEGAL];
        NSString* title = NSLocalizedString(@"Menu.legal", nil);
        
        WebPageViewController* view = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil withUrl:url andTitle:title];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
}




- (void)logoutReturned
{
    [_tableView reloadData];
    [ActivityAlertView close];
}



#pragma mark - TopBarDelegate

//- (BOOL)topBarItemClicked:(TopBarItemId)itemId
//{
//}





@end
