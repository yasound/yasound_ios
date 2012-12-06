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
#import "DeviceVersion.h"
#import "MyRadiosViewController.h"
#import "UIDevice+Resolutions.h"



@implementation RadioSelectionViewController

@synthesize locked;
@synthesize friends;
@synthesize url;
@synthesize wheelSelector;
@synthesize listContainer;
@synthesize menu;
@synthesize contentsController;
@synthesize contentsView;


#define TIMEPROFILE_CELL_BUILD @"TimeProfileCellBuild"



- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withWheelIndex:(NSInteger)wheelIndex
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.locked = NO;
        self.url = nil;
        _wheelIndex = wheelIndex;
        
        _waitingView = nil;
        self.nextPageUrl = nil;
        
        self.currentGenre = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSlidingOut:) name:ECSlidingViewUnderLeftWillAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSlidingIn:) name:ECSlidingViewTopDidReset object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifDidLogout:) name:NOTIF_DID_LOGOUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifDidLogin:) name:NOTIF_DID_LOGIN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifRefreshGui:) name:NOTIF_REFRESH_GUI object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGenreSelected:) name:NOTIF_GENRE_SELECTED object:nil];
        
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


-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    // optimized DB access
    [[YasoundDataCacheImageManager main] commit];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)showWaitingViewWithText:(NSString*)text
{
    if (_waitingView)
    {
        [_waitingView removeFromSuperview];
        [_waitingView release];
    }
    _waitingView = [[WaitingView alloc] initWithText:text];
    [self.view addSubview:_waitingView];
}

- (void)hideWaitingView
{
    if (_waitingView)
    {
        [_waitingView removeFromSuperview];
        [_waitingView release];
        _waitingView = nil;
    }
}





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
    if (itemIndex == WheelIdMyRadios)
        return WheelIdMyRadiosTitle;
    if (itemIndex == WheelIdFavorites)
        return WheelIdFavoritesTitle;
    if (itemIndex == WheelIdFriends)
        return WheelIdFriendsTitle;
    return nil;
}

- (NSInteger)initIndexForWheelSelector:(WheelSelector*)wheel
{
    return WheelIdSelection;
}




- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex
{
    [self hideWaitingView];
    
    // cancel all running requests before opening a new one
    [[YasoundDataProvider main] cancelRequestsForKey:@"radios"];
    [self refreshWheelClientForIndex:itemIndex];
}

- (void)refreshWheelClientForIndex:(NSInteger)itemIndex {
    
    if (self.contentsView != nil) {
        [self.contentsView removeFromSuperview];
        [self.contentsController release];
        self.contentsController = nil;
    }
    
    [self loadContentsForItem:itemIndex];
}


- (void)loadContentsForItem:(NSInteger)itemIndex {
    
    BOOL showRefreshIndicator = NO;
    BOOL showGenreSelector = NO;
    BOOL showRank = NO;
    
    // request my radios radios
    if (itemIndex == WheelIdMyRadios)
    {
        if (![YasoundSessionManager main].registered)
        {
            [self inviteToLogin:@"myRadios"];
            return;
        }
        
        MyRadiosViewController* view = [[MyRadiosViewController alloc] initWithNibName:@"MyRadiosViewController" bundle:nil];
        view.view.autoresizesSubviews = YES;
        CGRect frame = CGRectMake(0, 0, self.listContainer.frame.size.width, self.listContainer.frame.size.height);
        view.view.frame = frame;

        [self.listContainer addSubview:view.view];
        self.contentsController = view;
        self.contentsView = view.view;
        
        return;
    }
    
    if (itemIndex == WheelIdTop)
        showRank = YES;
    
    // infinite scroll for Selection and Top
    if ((itemIndex == WheelIdSelection) || (itemIndex == WheelIdTop)) {
        showRefreshIndicator = YES;
        showGenreSelector = YES;
    }

    
    // optimized DB access
    [[YasoundDataCacheImageManager main] commit];
    // optimized DB access
    [[YasoundDataCacheImageManager main] beginTransaction];

    
    CGRect frame = CGRectMake(0, 0, self.listContainer.frame.size.width, self.listContainer.frame.size.height);
    RadioListTableViewController* newTableview = [[RadioListTableViewController alloc] initWithFrame:frame url:self.url radios:nil withContentsHeight:self.listContainer.frame.size.height showRefreshIndicator:showRefreshIndicator showGenreSelector:showGenreSelector showRank:showRank];
    newTableview.listDelegate = self;
    [self.listContainer addSubview:newTableview.view];
    
    self.contentsController = newTableview;
    self.contentsView = newTableview.view;
    
    // we want the genre selector goes behind the wheel selector : make sure the views are stacked in the right way to do that
    [self.view sendSubviewToBack:self.listContainer];


    
    
    if (itemIndex == WheelIdFriends)
    {
        if (![YasoundSessionManager main].registered)
            [self inviteToLogin:@"friends"];
        else
        {
            [self showWaitingViewWithText:NSLocalizedString(@"FriendsWaitingText", nil)];
            
            [[YasoundDataProvider main] friendsForUser:[YasoundDataProvider main].user withCompletionBlock:^(int status, NSString* response, NSError* error){
                [self friendsReceivedWithStatus:status response:response error:error];
            }];
        }
        return;
    }
    
    // request selection radios
    if (itemIndex == WheelIdSelection)
    {
        [self showWaitingViewWithText:NSLocalizedString(@"SelectionWaitingText", nil)];
        self.url = [NSURL URLWithString:URL_RADIOS_SELECTION];
        [[YasoundDataCache main] requestRadioRecommendationFirstPageWithUrl:self.url genre:[[UserSettings main] selectedGenreForUrl:self.url] target:self action:@selector(receiveRadiosSelectionFirstPage:success:)];
        return;
    }

    // request favorites radios
    else if (itemIndex == WheelIdFavorites)
    {
        if (![YasoundSessionManager main].registered)
        {
            [self inviteToLogin:@"favorites"];
            return;
        }
        
        [self showWaitingViewWithText:NSLocalizedString(@"FavoritesWaitingText", nil)];
        self.url = [NSURL URLWithString:URL_RADIOS_FAVORITES];
        [[YasoundDataCache main] requestRadiosWithUrl:self.url withGenre:[[UserSettings main] selectedGenreForUrl:self.url] target:self action:@selector(receiveRadiosFavoritesFirstPage:success:)];
        return;
    }


    // request top radios
    else if (itemIndex == WheelIdTop)
    {
        [self showWaitingViewWithText:NSLocalizedString(@"TopWaitingText", nil)];
        self.url = [NSURL URLWithString:URL_RADIOS_TOP];
        [[YasoundDataCache main] requestRadiosWithUrl:self.url withGenre:[[UserSettings main] selectedGenreForUrl:self.url] target:self action:@selector(receiveRadiosTopFirstPage:success:)];
        return;
    }

    

}







- (void)updateContentsForItem:(NSInteger)itemIndex {
    
   // [[YasoundDataProvider main] cancelRequestsForKey:@"radios"];
    
    BOOL showRefreshIndicator = NO;
    BOOL showGenreSelector = NO;
    
    // infinite scroll for Selection and Top
    if ((itemIndex == WheelIdSelection) || (itemIndex == WheelIdTop)) {
        showRefreshIndicator = YES;
        showGenreSelector = YES;
    }
    
    
    // optimized DB access
    [[YasoundDataCacheImageManager main] commit];
    // optimized DB access
    [[YasoundDataCacheImageManager main] beginTransaction];
    
    
    // request selection radios
    if (itemIndex == WheelIdSelection)
    {
        [self showWaitingViewWithText:NSLocalizedString(@"SelectionWaitingText", nil)];
        self.url = [NSURL URLWithString:URL_RADIOS_SELECTION];
        [[YasoundDataCache main] requestRadioRecommendationFirstPageWithUrl:self.url genre:[[UserSettings main] selectedGenreForUrl:self.url] target:self action:@selector(receiveRadiosSelectionFirstPage:success:)];
        return;
    }
    
    
    // request top radios
    else if (itemIndex == WheelIdTop)
    {
        self.url = [NSURL URLWithString:URL_RADIOS_TOP];
        [self showWaitingViewWithText:NSLocalizedString(@"TopWaitingText", nil)];
        [[YasoundDataCache main] requestRadiosWithUrl:self.url withGenre:[[UserSettings main] selectedGenreForUrl:self.url] target:self action:@selector(receiveRadiosTopFirstPage:success:)];
        return;
    }
    

    
}



- (void)friendsReceivedWithStatus:(int)status response:(NSString*)response error:(NSError*)error
{
    BOOL success = YES;
    Container* friendsContainer = nil;
    if (error)
    {
        DLog(@"friends error: %d - %@", error.code, error. domain);
        success = NO;
    }
    else if (status != 200)
    {
        DLog(@"friends error: response status %d", status);
        success = NO;
    }
    else
    {
        friendsContainer = [response jsonToContainer:[User class]];
        if (!friendsContainer || !friendsContainer.objects)
        {
            DLog(@"friends error: cannot parse response %@", response);
            success = NO;
        }
    }
    
    [self hideWaitingView];
    
    if (!success)
    {
        //LBDEBUG TODO : error screen
        assert(0);
        return;
    }
    
    self.friends = friendsContainer.objects;
    DLog(@"received %d friends", self.friends.count);
    
    if (![self.contentsController respondsToSelector:@selector(setFriends:)])
        return;
    
    [self.contentsController setFriends:self.friends];
}



- (BOOL)loadNextRadioPage
{
    DLog(@"loadNextRadioPage '%@'", self.nextPageUrl);
    
    if (self.nextPageUrl == nil)
        return NO;
    
    
    self.nextPageTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(onRequestRadiosWithUrlTimeout:) userInfo:nil repeats:NO];
    
    
    // pass nil as genre. If needed, the genre is alredy in the next page url
    NSURL* nextUrl = [NSURL URLWithString:self.nextPageUrl];
    [[YasoundDataCache main] requestRadiosWithUrl:nextUrl withGenre:nil target:self action:@selector(receiveRadiosNextPage:success:)];
    return YES;
}



- (void)onRequestRadiosWithUrlTimeout:(NSTimer*)timer {
    
    self.nextPageTimer = nil;

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEXTPAGE_CANCEL object:nil];
}





- (void)receiveRadiosSelectionFirstPage:(Container*)radioContainer success:(BOOL)success {
    
    if (self.wheelSelector.currentIndex != WheelIdSelection)
        return;
    [self processRadiosFirstPage:radioContainer success:success];
}

- (void)receiveRadiosFavoritesFirstPage:(Container*)radioContainer success:(BOOL)success {
    
    if (self.wheelSelector.currentIndex != WheelIdFavorites)
        return;
    [self processRadiosFirstPage:radioContainer success:success];
}

- (void)receiveRadiosTopFirstPage:(Container*)radioContainer success:(BOOL)success {
    
    if (self.wheelSelector.currentIndex != WheelIdTop)
        return;
    [self processRadiosFirstPage:radioContainer success:success];
}

- (void)processRadiosFirstPage:(Container*)radioContainer success:(BOOL)success
{
    [self hideWaitingView];
#ifdef TEST_FAKE
    return;
#endif
    if (!success)
    {
        DLog(@"can't get radios");
        return;
    }
    
    
    
    NSArray* radios = radioContainer.objects;
    
    if (![self.contentsController respondsToSelector:@selector(setRadios:)])
        return;
    
    [self.contentsController setRadios:radios forUrl:self.url];

    // store next page url
    self.nextPageUrl = radioContainer.meta.next;
    DLog(@"self.nextPageUrl '%@'", self.nextPageUrl);
}



- (void)receiveRadiosNextPage:(Container*)radioContainer success:(BOOL)success
{
#ifdef TEST_FAKE
    return;
#endif
    
    [self.nextPageTimer invalidate];
    self.nextPageTimer = nil;
    
    if (self.locked) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEXTPAGE_CANCEL object:nil];
        return;
    }
    
    if (![self.contentsController respondsToSelector:@selector(appendRadios:)])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEXTPAGE_CANCEL object:nil];
        return;
    }
    
    
    if (!success)
    {
        DLog(@"can't get radios next page");
        
        [self.contentsController appendRadios:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEXTPAGE_CANCEL object:nil];
        return;
    }
    
    NSArray* radios = radioContainer.objects;
    
    DLog(@"receiveRadiosNextPage  %d radios", radios.count);

    
    [self.contentsController appendRadios:radios];
    
    // store next page url
    self.nextPageUrl = radioContainer.meta.next;
    DLog(@"self.nextPageUrl '%@'", self.nextPageUrl);
}




#pragma mark - RadioListDelegate

- (void)radioListDidSelect:(YaRadio*)radio
{
    if (self.locked)
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:radio];
}

- (void)friendListDidSelect:(User*)user
{
    ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:user];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (BOOL)listRequestNextPage {
    
    return [self loadNextRadioPage];
}











- (void)inviteToLogin:(NSString*)messageId
{
    if (self.contentsController != nil)
        [self.contentsView removeFromSuperview];
    [self.contentsController release];
    self.contentsController = nil;

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



- (void)onNotifDidLogout:(NSNotification*)notif {

    // refresh GUI
    [self refreshWheelClientForIndex:self.wheelSelector.currentIndex];
}


- (void)onNotifDidLogin:(NSNotification*)notif {
    // refresh GUI
    [self refreshWheelClientForIndex:self.wheelSelector.currentIndex];
    
}


- (void)onNotifRefreshGui:(NSNotification*)notif {
    // refresh GUI
    [self refreshWheelClientForIndex:self.wheelSelector.currentIndex];
}


- (void)onNotifGenreSelected:(NSNotification*)notif {
    
    NSString* genre = notif.object;
    DLog(@"onNotifGenreSelected '%@'", genre);
    
    [[YasoundDataProvider main] cancelRequestsForKey:@"radios"];

    [[UserSettings main] setGenre:genre forUrl:self.url];
    
    // reload
    [self updateContentsForItem:self.wheelSelector.currentIndex];
}



@end
