//
//  RadioSelectionViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioSelectionViewController.h"
#import "StyleSelectorViewController.h"
#import "YasoundDataCache.h"
#import "AudioStreamManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "TimeProfile.h"
#import "YasoundSessionManager.h"
#import "BigMessageView.h"
#import "RootViewController.h"

@implementation RadioSelectionViewController

@synthesize nbFriends;
@synthesize friendsRadios;
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
    
    NSString* urlstr = URL_RADIOS_SELECTION;
    [tabBar setTabSelected:TabIndexSelection];
    NSURL* url = [NSURL URLWithString:urlstr];
    [[YasoundDataCache main] requestRadiosWithUrl:self.url withGenre:nil target:self action:@selector(receiveRadios:info:)];

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

//- (BOOL)topBarItemClicked:(TopBarItemId)itemId
//{
//}






#pragma mark - WheelSelectorDelegate

- (NSInteger)numberOfItemsInWheelSelector:(WheelSelector*)wheel
{
    return WheelRadiosNbItems;
}

- (NSString*)wheelSelector:(WheelSelector*)wheel titleForItem:(NSInteger)itemIndex
{
    if (itemIndex == WheelIdSelection)
        return WheelIdSelectionTitle;
    if (itemIndex == WheelIdTop)
        return WheelIdTopTitle;
    if (itemIndex == WheelIdFavorites)
        return WheelIdFavoritesTitle;
    if (itemIndex == WheelIdFriends)
        return WheelIdFriendsTitle;
    return nil;
}

- (NSInteger)initIndexForWheelSelector:(WheelSelector*)wheel
{
    if (_tabIndex == TabIndexSelection)
        return WheelIdSelection;
    if (_tabIndex == TabIndexFavorites)
        return WheelIdFavorites;
    return 0;
}

- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex
{
    if (self.tableview != nil)
        [self.tableview.tableView removeFromSuperview];
    [self.tableview release];
    self.tableview = nil;
    
    NSString* url = nil;
    NSString* genre = nil;
    
    
    
    RadioListTableViewController* newTableview = [[RadioListTableViewController alloc] initWithStyle:UITableViewStylePlain radios:nil];
    newTableview.listDelegate = self;
    newTableview.tableView.frame = CGRectMake(0, 0, self.listContainer.frame.size.width, self.listContainer.frame.size.height);
    [self.listContainer addSubview:newTableview.view];
    
    self.tableview = newTableview;

    
    
    
    if (itemIndex == WheelIdFriends)
    {
        [tabBar setTabSelected:TabIndexSelection];

        if (![YasoundSessionManager main].registered)
            [self inviteToLogin:@"friends"];
        else
            [[YasoundDataProvider main] friendsForUser:[YasoundDataProvider main].user withTarget:self action:@selector(friendsReceived:success:)];
        return;
    }

    // request favorites radios
    if (itemIndex == WheelIdFavorites)
    {
        if (![YasoundSessionManager main].registered)
        {
            [self inviteToLogin:@"favorites"];
            return;
        }
        
        url = URL_RADIOS_FAVORITES;
        [tabBar setTabSelected:TabIndexFavorites];
    }

    // request selection radios
    else if (itemIndex == WheelIdSelection)
    {
        url = URL_RADIOS_SELECTION;
        [tabBar setTabSelected:TabIndexSelection];
    }

    // request top radios
    else if (itemIndex == WheelIdTop)
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


- (void)friendsReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        //LBDEBUG TODO : error screen
        assert(0);
        return;
    }
    
    self.friendsRadios = nil;
    self.friendsRadios = [[NSMutableArray alloc] init];
    
    Container* container = [req responseObjectsWithClass:[User class]];
    NSArray* friends = container.objects;
    self.nbFriends = friends.count;
    
    DLog(@"received %d friends", self.nbFriends);

    for (User* friend in friends)
    {
        DLog(@"my friend : %@", friend.username);
        
        [[YasoundDataProvider main] radiosForUser:friend withTarget:self action:@selector(receivedFriendsRadios:success:)];
    }
}


// LBDEBUG TODO : FIX BUG
- (void)receivedFriendsRadios:(ASIHTTPRequest*)req success:(BOOL)success
{
    if (!success)
    {
        DLog(@"RadioSelectionViewController::receivedFriendsRadios failed");
        assert(0);
        return;
    }
    
    Container* container = [req responseObjectsWithClass:[Radio class]];
    NSArray* radios = container.objects;
    
    [self.friendsRadios addObjectsFromArray:radios];
    
    self.nbFriends--;
    
    if (self.nbFriends == 0)
        [self.tableview setRadios:self.friendsRadios];
    
    
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
    
    [self.tableview setRadios:radios];
    
//    RadioListTableViewController* newTableview = [[RadioListTableViewController alloc] initWithStyle:UITableViewStylePlain radios:radios];
//    newTableview.listDelegate = self;
//    newTableview.tableView.frame = CGRectMake(0, 0, self.listContainer.frame.size.width, self.listContainer.frame.size.height);
//    [self.listContainer addSubview:newTableview.view];
//    
//    self.tableview = newTableview;
}




#pragma mark - RadioListDelegate

- (void)radioListDidSelect:(Radio*)radio
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
}


#pragma mark - TabBarDelegate

- (void)tabBarDidSelect:(NSInteger)tabIndex
{
    if (tabIndex == TabIndexSelection)
    {
        [self.wheelSelector stickToItem:WheelIdSelection silent:NO];
    }
    else if (tabIndex == TabIndexFavorites)
    {
        if (![YasoundSessionManager main].registered)
            [self inviteToLogin:@"favorites"];
        else
            [self.wheelSelector stickToItem:WheelIdFavorites silent:NO];
    }
    
    
    else if ((tabIndex == TabIndexMyRadios) && ![YasoundSessionManager main].registered)
    {
        [self inviteToLogin:@"myRadios"];
    }
    else if ((tabIndex == TabIndexGifts) && ![YasoundSessionManager main].registered)
    {
        [self inviteToLogin:@"gifts"];
    }
    else if ((tabIndex == TabIndexProfil) && ![YasoundSessionManager main].registered)
    {
        [self inviteToLogin:@"profil"];
    }
    
}


- (void)inviteToLogin:(NSString*)messageId
{
    if (self.tableview != nil)
        [self.tableview.tableView removeFromSuperview];
    [self.tableview release];
    self.tableview = nil;

    BigMessageView* view = [[BigMessageView alloc] initWithFrame:self.listContainer.frame messageId:messageId target:self action:@selector(onLoginRequested:)];
    [self.listContainer addSubview:view];
    [view release];
}


- (void)onLoginRequested:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_LOGIN object:nil];
}







@end
