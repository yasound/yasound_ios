//
//  RadioSelectionViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSelectionViewController.h"
#import "StyleSelectorViewController.h"
#import "RadioViewController.h"
#import "YasoundDataCache.h"
#import "AudioStreamManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "TimeProfile.h"
#import "YasoundSessionManager.h"
#import "BigMessageView.h"
#import "RootViewController.h"

@implementation RadioSelectionViewController

@synthesize url;
@synthesize wheelSelector;
@synthesize listContainer;
@synthesize tableview;
@synthesize tabBar;

#define TIMEPROFILE_CELL_BUILD @"TimeProfileCellBuild"



- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTabIndex:(TabIndex)tabIndex
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.url = nil;
        _tabIndex = tabIndex;
    }
    return self;
}

- (void)dealloc
{
  [super dealloc];
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
    listContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];

    if (_tabIndex == TabIndexSelection)
        [wheelSelector initWithItem:WheelIdSelection];
    else  if (_tabIndex == TabIndexFavorites)
        [wheelSelector initWithItem:WheelIdFavorites];

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}











//#pragma  mark - Update
//
//- (void)updateRadios:(NSString*)genre
//{
//    NSString* g = genre;
//    if ([genre isEqualToString:@"style_all"])
//        g = nil;
//    
//    [[YasoundDataCache main] requestRadiosWithUrl:self.url withGenre:g target:self action:@selector(receiveRadios:info:)];
//}











#pragma mark - TopBarDelegate

- (void)topBarBackItemClicked:(TopBarItemId)itemId
{
    if (itemId == TopBarItemBack)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    else if (itemId == TopBarItemNotif)
    {
        
    }

    else if (itemId == TopBarItemNowPlaying)
    {
        RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}






#pragma mark - WheelSelectorDelegate

// item has been selected from the wheel selector
- (void)wheelSelectorDidSelect:(NSInteger)index
{
    if (self.tableview != nil)
        [self.tableview.tableView removeFromSuperview];
    [self.tableview release];
    self.tableview = nil;
    
    NSString* url = nil;
    NSString* genre = nil;

    // request favorites radios
    if (index == WheelIdFavorites)
    {
        url = URL_RADIOS_FAVORITES;
        [tabBar setTabSelected:TabIndexFavorites];
    }

    // request selection radios
    else if (index == WheelIdSelection)
    {
        url = URL_RADIOS_SELECTION;
        [tabBar setTabSelected:TabIndexSelection];
    }

    // request top radios
    else if (index == WheelIdTop)
    {
        url = URL_RADIOS_TOP;
        [tabBar setTabSelected:TabIndexSelection];
    }
    
    else
    {
        [tabBar setTabSelected:TabIndexSelection];
    }

    self.url = [NSURL URLWithString:url];
    
    [[YasoundDataCache main] requestRadiosWithUrl:self.url withGenre:genre target:self action:@selector(receiveRadios:info:)];
        
}



- (void)receiveRadios:(NSArray*)radios info:(NSDictionary*)info
{
#ifdef TEST_FAKE
    return;
#endif
    NSError* error = [info valueForKey:@"error"];
    if (error)
    {
        DLog(@"can't get radios: %@", error.domain);
        return;
    }
    
    RadioListTableViewController* newTableview = [[RadioListTableViewController alloc] initWithStyle:UITableViewStylePlain radios:radios];
    newTableview.listDelegate = self;
    newTableview.tableView.frame = CGRectMake(0, 0, self.listContainer.frame.size.width, self.listContainer.frame.size.height);
    [self.listContainer addSubview:newTableview.view];
    
    self.tableview = newTableview;
}




#pragma mark - RadioListDelegate

- (void)radioListDidSelect:(Radio*)radio
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


#pragma mark - TabBarDelegate

- (void)tabBarDidSelect:(NSInteger)tabIndex
{
    if (tabIndex == TabIndexSelection)
    {
        [wheelSelector stickToItem:WheelIdSelection];
    }
    else if (tabIndex == TabIndexFavorites)
    {
        [wheelSelector stickToItem:WheelIdFavorites];
    }
    
    
    else if ((tabIndex == TabIndexMyRadios) || (tabIndex == TabIndexGifts) || (tabIndex == TabIndexProfil))
    {
        // if the user is not connected, display an invitation message
        if (![YasoundSessionManager main].registered)
        {
            [self inviteToLogin];
        }
    }
    
}


- (void)inviteToLogin
{
    if (self.tableview != nil)
        [self.tableview.tableView removeFromSuperview];
    [self.tableview release];
    self.tableview = nil;

    BigMessageView* view = [[BigMessageView alloc] initWithFrame:self.listContainer.frame message:NSLocalizedString(@"BigMessage.inviteLogin", nil) actionTitle:NSLocalizedString(@"BigMessage.inviteLogin.button", nil) target:self action:@selector(onLoginRequested:)];
    [self.listContainer addSubview:view];
    [view release];
}


- (void)onLoginRequested:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_LOGIN object:nil];
}







@end
