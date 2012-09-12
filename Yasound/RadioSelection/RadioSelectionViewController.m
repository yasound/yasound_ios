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
#import "ProfilViewController.h"
#import "YasoundAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "Version.h"

@implementation RadioSelectionViewController

//@synthesize nbFriends;
//@synthesize friendsRadios;
@synthesize locked;
@synthesize friends;
@synthesize url;
@synthesize wheelSelector;
@synthesize listContainer;
@synthesize tableview;
@synthesize tabBar;
@synthesize menu;

#define TIMEPROFILE_CELL_BUILD @"TimeProfileCellBuild"



- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTabIndex:(TabIndex)tabIndex
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.locked = NO;
        self.url = nil;
        _tabIndex = tabIndex;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSlidingOut:) name:ECSlidingViewUnderLeftWillAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSlidingIn:) name:ECSlidingViewTopDidReset object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle




- (void)onSlidingOut:(NSNotification*)notif
{
    self.locked = YES;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        [self.view addGestureRecognizer:[APPDELEGATE.slideController panGesture]];
    }
    
    self.wheelSelector.locked = YES;
}


- (void)onSlidingIn:(NSNotification*)notif
{
    self.locked = NO;
//    [self.view setUserInteractionEnabled:YES];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        [self.view removeGestureRecognizer:[APPDELEGATE.slideController panGesture]];
    }
    
    if (APPDELEGATE.menuViewController.programmedCommand != nil)
        [APPDELEGATE.menuViewController runProgrammedCommand];


    self.wheelSelector.locked = NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    listContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
    
    [tabBar setTabSelected:TabIndexSelection];

    //LBDEBUG TEMPORARLY
    UISwipeGestureRecognizer* swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight)] autorelease];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer* swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft)] autorelease];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.topbar showMenuItem];    
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


    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        if (![[APPDELEGATE.slideController underLeftViewController] isKindOfClass:[MenuViewController class]])
        {
            [APPDELEGATE.slideController setUnderLeftViewController:APPDELEGATE.menuViewController];
        }
    }

    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        if (APPDELEGATE.menuViewController.programmedCommand != nil)
            [APPDELEGATE.menuViewController runProgrammedCommand];
    }

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
    if (itemIndex == WheelIdSearch)
        return WheelIdSearchTitle;
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
    
    if (self.searchview != nil)
    {
        [self.searchview.view removeFromSuperview];
        [self.searchview release];
        self.searchview = nil;
    }
    else
    {
        [self.tableview release];
        self.tableview = nil;
    }
    
    
    NSString* url = nil;
    NSString* genre = nil;
    
    
    if (itemIndex == WheelIdSearch)
    {
        self.searchview = [[RadioSearchViewController alloc] initWithNibName:@"RadioSearchViewController" bundle:nil];
        //viewC.view.frame = CGRectMake(0, 0, self.listContainer.frame.size.width, self.listContainer.frame.size.height);
        [self.listContainer addSubview:self.searchview.view];
//        [self.searchview release];
        return;
    }
    
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
    
    // request selection radios
    if (itemIndex == WheelIdSelection)
    {
        [tabBar setTabSelected:TabIndexSelection];
        [[YasoundDataCache main] requestRadioRecommendationWithTarget:self action:@selector(receiveRadios:info:)];
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
    
    //LBDEBUG
    //DLog(@"RadioSelection url '%@'", self.url);
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
    
//    self.friendsRadios = nil;
//    self.friendsRadios = [[NSMutableArray alloc] init];
    
    Container* container = [req responseObjectsWithClass:[User class]];
    self.friends = container.objects;
//    self.nbFriends = friends.count;
    
    DLog(@"received %d friends", self.friends.count);
    
    [self.tableview setFriends:self.friends];


//    for (User* friend in friends)
//    {
//        DLog(@"my friend : %@", friend.username);
//        
//        [[YasoundDataProvider main] radiosForUser:friend withTarget:self action:@selector(receivedFriendsRadios:success:)];
//    }
}


// LBDEBUG TODO : FIX BUG
//- (void)receivedFriendsRadios:(ASIHTTPRequest*)req success:(BOOL)success
//{
//    if (!success)
//    {
//        DLog(@"RadioSelectionViewController::receivedFriendsRadios failed");
//        assert(0);
//        return;
//    }
//    
//    Container* container = [req responseObjectsWithClass:[Radio class]];
//    NSArray* radios = container.objects;
//    
//    [self.friendsRadios addObjectsFromArray:radios];
//    
//    self.nbFriends--;
//    
//    if (self.nbFriends == 0)
//        [self.tableview setRadios:self.friendsRadios];
//    
//    
//}













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
    
    //LBDEBUG
//    DLog(@"received %d radios", radios.count);
//    for (Radio* r in radios)
//    {
//        DLog(@"radio '%@'", r.name);
//    }
//    DLog(@"end of list.");
    
    
    
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
    if (self.locked)
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
}

- (void)friendListDidSelect:(User*)user
{
    ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:user showTabs:NO];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


#pragma mark - TabBarDelegate

- (void)tabBarDidSelect:(NSInteger)tabIndex
{
    if (self.locked)
        return;
    
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





- (void)onSwipeLeft
{
    NSInteger currentIndex = self.wheelSelector.currentIndex;
    if (currentIndex == self.wheelSelector.items.count - 1)
        return;
    currentIndex++;
    [self.wheelSelector stickToItem:currentIndex silent:NO];
}

- (void)onSwipeRight
{
    NSInteger currentIndex = self.wheelSelector.currentIndex;
    if (currentIndex == 0)
        return;
    currentIndex--;
    [self.wheelSelector stickToItem:currentIndex silent:NO];
}






@end
