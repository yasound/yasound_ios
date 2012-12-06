//
//  RadioListTableViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RadioListTableViewController.h"
#import "RadioListTableViewCell.h"
#import "UserListTableViewCell.h"
#import "InviteFriendsTableViewCell.h"
#import "Theme.h"
#import "RootViewController.h"



@interface RadioListTableViewController ()

@end


@implementation RadioListTableViewController

@synthesize listDelegate;
@synthesize tableView;

@synthesize radios = _radios;
@synthesize friends = _friends;
@synthesize friendsMode;
@synthesize delayTokens;
@synthesize delay;





#define REFRESH_INDICATOR_HEIGHT 62.f

#define NB_SECTIONS_FRIENDS 2

#define SECTION_FRIENDS_INDEX 0
#define SECTION_INVITE_FRIENDS_INDEX 1

#define NB_ROWS_SECTION_INVITE_FRIENDS 1


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil listeners:(NSArray*)listeners {
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        self.dragging = NO;
        _showRank = NO;
        
        self.showRefreshIndicator = NO;
        self.showGenreSelector = NO;
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
        
        self.loadingNextPage = NO;
        _contentsHeight = self.view.frame.size.height;
        
        self.delayTokens = 2;
        self.delay = 0.15;
        
        self.url = nil;
        self.radios = nil;
        self.radiosPreviousCount = 0;
        self.friendsMode = YES;
        self.listenersMode = YES;
        
//        [self commonInit];
        
        [self.listenersTopbar hideNowPlaying];
        self.tableView = nil;
        
        
    }
    
    return self;
}





- (id)initWithFrame:(CGRect)frame url:(NSURL*)url radios:(NSArray*)radios withContentsHeight:(CGFloat)contentsHeight showRefreshIndicator:(BOOL)showRefreshIndicator showGenreSelector:(BOOL)showGenreSelector showRank:(BOOL)showRank
{
    self = [super init];
    if (self)
    {
        self.dragging = NO;
        _showRank = showRank;
        
        self.showRefreshIndicator = showRefreshIndicator;
        self.showGenreSelector = showGenreSelector;
        
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
        
        self.loadingNextPage = NO;
        _contentsHeight = contentsHeight;
        
        self.delayTokens = 2;
        self.delay = 0.15;
        
        self.url = url;
        self.radios = [NSMutableArray arrayWithArray:radios];
        self.radiosPreviousCount = radios.count;
        self.friendsMode = NO;
        self.listenersMode = NO;


        [self commonInit];
    }
    return self;
}


- (void)commonInit {
    
    
    if (self.showGenreSelector) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGenreSelected:) name:NOTIF_GENRE_SELECTED object:nil];
        
        self.genreSelector = [[WheelSelectorGenre alloc] init];
        [self.view addSubview:self.genreSelector];
        [self.genreSelector initWithTheme:@"Genre"];
        
        
    }
    
    
    
    if (self.showRefreshIndicator) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifNextPageCancel:) name:NOTIF_NEXTPAGE_CANCEL object:nil];
        
        self.refreshIndicator = [[RefreshIndicator alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - REFRESH_INDICATOR_HEIGHT, self.view.frame.size.width, REFRESH_INDICATOR_HEIGHT) withStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:self.refreshIndicator];
    }
  
    
    if (self.tableViewContainer != nil) {
        [self.tableViewContainer release];
        self.tableViewContainer = nil;
    }
    
    self.tableViewContainer = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.tableViewContainer];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.tableViewContainer addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor clearColor];

}





- (void)viewDidLoad {
    
    [super viewDidLoad];
}




- (void)setRadios:(NSArray*)radiosArray forUrl:(NSURL*)url
{
    self.radios = [NSMutableArray arrayWithArray:radiosArray];
    self.url = url;
    
    self.radiosPreviousCount = self.radios.count;
    
    if (self.showGenreSelector) {
        [self tutorial];
    }

    if (self.url != nil) {
        NSString* genre = [[UserSettings main] objectForKey:self.url];
        if ((genre != nil) && (self.genreSelector.status != eGenreStatusOpened)) {
            [self openGenreSelector];
            [self.genreSelector open];
        }
    }

    
    [self.tableView reloadData];
    
    DLog(@"setRadios verif self.radios.count %d", self.radios.count);
}


- (void)tutorial {

    NSInteger nb = [[UserSettings main] integerForKey:USKEYtutorialGenreSelector error:nil];
    if (nb < 4) {
    
        [self openGenreSelectorAnimated:YES];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tutorial2) userInfo:nil repeats:NO];
        
        nb++;
        [[UserSettings main] setInteger:nb forKey:USKEYtutorialGenreSelector];
    }
    

}

- (void)tutorial2 {
    
    [self closeGenreSelector];
}








- (void)setFriends:(NSArray*)friends
{
    _friends = friends;
    [_friends retain];
    
    self.friendsMode = YES;
    [self.tableView reloadData];
}



- (void)setListeners:(NSArray*)listeners
{
    _friends = listeners;
    [_friends retain];
    
    self.friendsMode = YES;
    self.tableView = self.listenersTableview;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
    [self.listenersTableview reloadData];
}




- (void)appendRadios:(NSArray*)radios
{
//    DLog(@"appendRadios add %d radios   to existing radios %d", radios.count, self.radios.count);
    assert(self.radios);
    
    [self.radios addObjectsFromArray:radios];

    [self unfreeze];
}






                         
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.listenersMode)
        return 1;
    
    if (self.friendsMode)
        return NB_SECTIONS_FRIENDS;

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.friendsMode)
    {
        if (section == SECTION_FRIENDS_INDEX)
        {
            if (self.friends == nil)
                return 0;
            NSInteger nbRows = self.friends.count / 3;
            if ((self.friends.count % 3) != 0)
                nbRows++;
            return nbRows;
        }
        else if (section == SECTION_INVITE_FRIENDS_INDEX)
        {
            return NB_ROWS_SECTION_INVITE_FRIENDS;
        }
    }
    
    if (self.radios == nil)
        return 0;
    
    NSInteger nbRows = [self numberOfRowsFromRadios:self.radios.count];
    
    DLog(@"nb Rows in list : %d", nbRows);
    
    return nbRows;
}


- (NSInteger)numberOfRowsFromRadios:(NSInteger)radiosCount {
    
    NSInteger nbRows = radiosCount / 2;
    if ((radiosCount % 2) != 0)
        nbRows++;
    return nbRows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.friendsMode)
    {
        if (indexPath.section == SECTION_INVITE_FRIENDS_INDEX)
        {
            return 130.f;
        }
        return 100.f;
    }
    
    return 156.f;
}




- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.friendsMode)
        return [self userCellForRowAtIndexPath:indexPath tableView:aTableView];
    
    return [self radioCellForRowAtIndexPath:indexPath tableView:aTableView];
}


- (UITableViewCell*)radioCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)aTableView
{
    static NSString* cellRadioIdentifier = @"RadioListTableViewCell";

    RadioListTableViewCell* cell = (RadioListTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:cellRadioIdentifier];
    
    NSInteger radioIndex = indexPath.row * 2;
    
    //LBDEBUG
    assert(radioIndex < self.radios.count);
    
    YaRadio* radio1 = [self.radios objectAtIndex:radioIndex];
    [radio1 setAssignedTopRank:radioIndex+1];
    YaRadio* radio2 = nil;
    if (radioIndex+1 < self.radios.count) {
        radio2 = [self.radios objectAtIndex:radioIndex+1];
        [radio2 setAssignedTopRank:radioIndex+2];
    }
    
    NSArray* radiosForRow = [NSArray arrayWithObjects:radio1, radio2, nil];
    
    if (cell == nil)
    {
        CGFloat currentDelay = 0;
        if (self.delayTokens > 0)
            currentDelay = self.delay;
        
        cell = [[[RadioListTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellRadioIdentifier radios:radiosForRow delay:currentDelay target:self action:@selector(onRadioClicked:) showRank:_showRank] autorelease];
        
        self.delayTokens--;
        self.delay += 0.3;
    }
    else
    {
        [cell updateWithRadios:radiosForRow target:self action:@selector(onRadioClicked:)];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}




- (UITableViewCell*)userCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)aTableView
{
    static NSString* cellUserIdentifier = @"UserListTableViewCell";
    static NSString* cellInviteIdentifier = @"InviteUserTableViewCell";
    
    if (indexPath.section == SECTION_INVITE_FRIENDS_INDEX)
    {
        InviteFriendsTableViewCell* cell = (InviteFriendsTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:cellInviteIdentifier];
        if (cell == nil)
        {
            cell = [[InviteFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellInviteIdentifier];
        }
        return cell;
    }
    
    UserListTableViewCell* cell = (UserListTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:cellUserIdentifier];
    
    NSInteger userIndex = indexPath.row * 3;
    
    //LBDEBUG
    assert(userIndex < self.friends.count);

    User* user1 = [self.friends objectAtIndex:userIndex];
    User* user2 = nil;
    User* user3 = nil;
    if (userIndex+1 < self.friends.count)
        user2 = [self.friends objectAtIndex:userIndex+1];
    if (userIndex+2 < self.friends.count)
        user3 = [self.friends objectAtIndex:userIndex+2];
    
    NSArray* usersForRow = [NSArray arrayWithObjects:user1, user2, user3, nil];
    
    if (cell == nil)
    {
        CGFloat currentDelay = 0;
        if (self.delayTokens > 0)
            currentDelay = self.delay;
        
        cell = [[UserListTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellUserIdentifier users:usersForRow delay:currentDelay target:self action:@selector(onUserClicked:)];
        
        self.delayTokens--;
        self.delay += 0.3;
    }
    else
    {
        [cell updateWithUsers:usersForRow target:self action:@selector(onUserClicked:)];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.friendsMode && section == SECTION_INVITE_FRIENDS_INDEX)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.section.container" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        float height = sheet.frame.size.height;
        return height;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.friendsMode && section == SECTION_INVITE_FRIENDS_INDEX)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.section.container" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIView* view = [[UIView alloc] initWithFrame:sheet.frame];
        
        sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.section.separator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* img = [sheet makeImage];
        [view addSubview:img];
        
        sheet = [[Theme theme] stylesheetForKey:@"InviteFriends.section.title" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UILabel* label = [sheet makeLabel];
        label.text = NSLocalizedString(@"InviteFriendsSection.title", nil);
        [view addSubview:label];
        
        return view;
    }
    
    return nil;
}




#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
- (void)onRadioClicked:(YaRadio*)radio
{
    // call delegate with selected radio
    [self.listDelegate radioListDidSelect:radio];
}

- (void)onUserClicked:(User*)user
{
    // call delegate with selected radio
    [self.listDelegate friendListDidSelect:user];
}




#pragma mark - UIScrollViewDelegate



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [super scrollViewDidScroll:scrollView];
    
    //
    // Genre Selector
    //
    if (self.genreSelector.status == eGenreStatusClosed) {
        
        if (self.dragging && (scrollView.contentOffset.y < (0-self.genreSelector.frame.size.height))) {
            self.genreSelector.status = eGenreStatusPulled;
        }
        else
        
            if (self.dragging && (scrollView.contentOffset.y < 0)) {
            CGFloat posY = 0 - scrollView.contentOffset.y - self.genreSelector.frame.size.height;
            [self.genreSelector moveTo:posY];
        }
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    [super scrollViewWillBeginDragging:scrollView];

}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    

    if (self.showGenreSelector) {
        
        if (self.genreSelector.status == eGenreStatusClosed) {
            [self.genreSelector close];
        }

        else if (self.genreSelector.status == eGenreStatusPulled) {
            [self openGenreSelector];
        }
    }

}


- (BOOL) refreshIndicatorRequest {

    [super refreshIndicatorRequest];
    
    return [self.listDelegate listRequestNextPage];
}




- (void)refreshIndicatorDidFreeze {
    
    [super refreshIndicatorDidFreeze];
    [self.tableView setContentSize: CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height + self.refreshIndicator.height)];
}



- (void)refreshIndicatorDidUnfreeze {
    
    [super refreshIndicatorDidUnfreeze];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(unfreezeAnimationStoped:finished:context:)];

    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height - self.refreshIndicator.height);
    [UIView commitAnimations];

}


- (void)unfreezeAnimationStoped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if (!self.showRefreshIndicator)
        return;
    
    [self.tableView reloadData];
    
//    DLog(@"contentOffset.y  %.2f     rame.size.height %.2f => offset %.2f     (contentSize %.2f x %.2f)", self.tableView.contentOffset.y , self.tableView.frame.size.height, self.tableView.contentOffset.y + self.tableView.frame.size.height, self.tableView.contentSize.width, self.tableView.contentSize.height);
}







- (void)openGenreSelector {
    
    [self openGenreSelectorAnimated:NO];
}

- (void)openGenreSelectorAnimated:(BOOL)animated {
    
    self.genreSelector.status = eGenreStatusOpened;
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
    }
    
    CGRect frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + self.genreSelector.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height - self.genreSelector.frame.size.height);
    self.tableViewContainer.frame = frame;
    

    if (animated) {
        [UIView commitAnimations];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onGenreSelectorOpened:) userInfo:nil repeats:NO];

    [self.genreSelector open];
}


- (void)onGenreSelectorOpened:(NSTimer*)timer {

    CGRect frame = CGRectMake(0,0, self.tableViewContainer.frame.size.width, self.tableViewContainer.frame.size.height);
    self.tableView.frame = frame;
}





- (void)closeGenreSelector {
    
    self.genreSelector.status = eGenreStatusClosed;
    
    
    CGRect frame = CGRectMake(0,0, self.tableViewContainer.frame.size.width, self.tableViewContainer.frame.size.height + self.genreSelector.frame.size.height);
    self.tableView.frame = frame;

    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.33];
    
     frame = CGRectMake(0, self.tableViewContainer.frame.origin.y - self.genreSelector.frame.size.height, self.tableViewContainer.frame.size.width, self.tableViewContainer.frame.size.height + self.genreSelector.frame.size.height);
    self.tableViewContainer.frame = frame;

    [UIView commitAnimations];

    [self.genreSelector close];
}







#pragma mark - Notifications

- (void)onNotifGenreSelected:(NSNotification*)notif {
    
    NSString* genre = notif.object;
    
    if ([genre isEqualToString:@"style_all"])
    {
        [self closeGenreSelector];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        CGRect frame = CGRectMake(0, 0, self.tableViewContainer.frame.size.width, self.tableViewContainer.frame.size.height);
        self.tableViewContainer.frame = frame;
        [UIView commitAnimations];
    }
}



- (void)onNotifNextPageCancel:(NSNotification*)notif {
    
    [self unfreeze];    
}




@end
