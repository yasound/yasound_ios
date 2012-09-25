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
@synthesize refreshIndicator;


#define REFRESH_INDICATOR_HEIGHT 62.f

#define NB_SECTIONS_FRIENDS 2

#define SECTION_FRIENDS_INDEX 0
#define SECTION_INVITE_FRIENDS_INDEX 1

#define NB_ROWS_SECTION_INVITE_FRIENDS 1

- (id)initWithFrame:(CGRect)frame url:(NSURL*)url radios:(NSArray*)radios withContentsHeight:(CGFloat)contentsHeight showRefreshIndicator:(BOOL)showRefreshIndicator showGenreSelector:(BOOL)showGenreSelector
{
    self = [super init];
    if (self)
    {
        _dragging = NO;
        
        self.showRefreshIndicator = showRefreshIndicator;
        self.showGenreSelector = showGenreSelector;
        
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
        
        _loadingNextPage = NO;
        _contentsHeight = contentsHeight;
        
        self.delayTokens = 2;
        self.delay = 0.15;
        
        self.url = url;
        self.radios = radios;
        self.radiosPreviousCount = radios.count;
        self.friendsMode = NO;
        

        if (self.showGenreSelector) {
            self.genreSelector = [[WheelSelectorGenre alloc] init];
            [self.view addSubview:self.genreSelector];
            [self.genreSelector initWithTheme:@"Genre"];

            if (self.url != nil) {
                NSString* genre = [[UserSettings main] objectForKey:self.url];
                if (genre != nil) {
                    [self openGenreSelector];
                    [self.genreSelector open];
                }
            }
            
        }
        

        if (self.showRefreshIndicator) {
            self.refreshIndicator = [[RefreshIndicator alloc] initWithFrame:CGRectMake(0, frame.size.height - REFRESH_INDICATOR_HEIGHT, self.view.frame.size.width, REFRESH_INDICATOR_HEIGHT)];
            [self.view addSubview:self.refreshIndicator];
        }

        self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self.view addSubview:self.tableView];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.tableView.backgroundColor = [UIColor clearColor];
        
        
    }
    return self;
}



- (void)setRadios:(NSArray*)radios forUrl:(NSURL*)url
{
    self.radios = radios;
    self.url = url;
    
    self.radiosPreviousCount = radios.count;
    
    if (self.url != nil) {
        NSString* genre = [[UserSettings main] objectForKey:self.url];
        if ((genre != nil) && (self.genreSelector.status != eGenreStatusOpened)) {
            [self openGenreSelector];
            [self.genreSelector open];
        }
    }

    
    [self.tableView reloadData];
}

- (void)setFriends:(NSArray*)friends
{
    _friends = friends;
    [_friends retain];
    
    self.friendsMode = YES;
    [self.tableView reloadData];
}

- (void)appendRadios:(NSArray*)radios
{
    NSMutableArray* newRadios = [NSMutableArray array];
    if (_radios)
    {
        [newRadios addObjectsFromArray:_radios];
        [_radios release];
        _radios = nil;
    }
    [newRadios addObjectsFromArray:radios];
    _radios = newRadios;
    [_radios retain];

//    if (!_dragging)
//        [self.tableView reloadData];
    [self unfreeze];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    self.nextPageView = [[UIView alloc] initWithFrame:CGRectMake(0, _contentsHeight-62, self.view.frame.size.width, 62)];
//    self.nextPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 62)];
//    self.nextPageView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:self.nextPageView];
////    [self.view sendSubviewToBack:self.nextPageView];
////    [self.view sendSubviewToBack:self.tableView];
//    self.nextPageView.hidden = NO;
    
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
//    [self.view addSubview:self.tableView];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
//    
//    self.nextPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 62)];
//    self.nextPageView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:self.nextPageView];
//    //    [self.view sendSubviewToBack:self.nextPageView];
//    //    [self.view sendSubviewToBack:self.tableView];
//    self.nextPageView.hidden = NO;
}


//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
//    
//}

//-(void) drawCABackgroundLayer: (CALayer*) layer inContext: (CGContextRef) context
//{
//    UIGraphicsPushContext(context);
//    
//    CGRect contentRect = [layer bounds];
//    
////    UIImage *bgImage = [[ImageCacheController sharedImageCache] imageFromCache: GENERIC_BGIMAGE_FILENAME];
////    
////    [bgImage drawInRect: CGRectMake(contentRect.origin.x, contentRect.origin.y, contentRect.size.width, contentRect.size.height)];
//    
////    [self.nextPageView draw]
//    
//    NSLog(@"DEBUG");
//    
//    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [indicatorView setFrame:CGRectMake(0, 0, 16, 16)];
//    [indicatorView setHidesWhenStopped:YES];
//    [indicatorView startAnimating];
//    [self.view addSubview:indicatorView];
//    
//    UIGraphicsPopContext();
//}
////- (void)updateNextPageView {
//
//    self.nextPageView.frame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 88)];
//}


                         
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
    if (self.friendsMode)
    {
        return NB_SECTIONS_FRIENDS;
    }
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




//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
////	UIImage *myImage = [UIImage imageNamed:@"bluebar.png"];
////    UIImageView *imageView = [[[UIImageView alloc] initWithImage:myImage] autorelease];
////    imageView.frame = CGRectMake(10,10,300,100);
////    return imageView;
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 88)];
//    view.backgroundColor = [UIColor redColor];
//    return view;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 10;
//}
//





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.friendsMode)
        return [self userCellForRowAtIndexPath:indexPath tableView:tableView];
    
    return [self radioCellForRowAtIndexPath:indexPath tableView:tableView];
}


- (UITableViewCell*)radioCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)tableView
{
    static NSString* cellRadioIdentifier = @"RadioListTableViewCell";

    RadioListTableViewCell* cell = (RadioListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellRadioIdentifier];
    
    NSInteger radioIndex = indexPath.row * 2;
    
    Radio* radio1 = [self.radios objectAtIndex:radioIndex];
    Radio* radio2 = nil;
    if (radioIndex+1 < self.radios.count)
        radio2 = [self.radios objectAtIndex:radioIndex+1];
    
    NSArray* radiosForRow = [NSArray arrayWithObjects:radio1, radio2, nil];
    
    if (cell == nil)
    {
        CGFloat delay = 0;
        if (self.delayTokens > 0)
            delay = self.delay;
        
        cell = [[[RadioListTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellRadioIdentifier radios:radiosForRow delay:delay target:self action:@selector(onRadioClicked:)] autorelease];
        
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




- (UITableViewCell*)userCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)tableView
{
    static NSString* cellUserIdentifier = @"UserListTableViewCell";
    static NSString* cellInviteIdentifier = @"InviteUserTableViewCell";
    
    if (indexPath.section == SECTION_INVITE_FRIENDS_INDEX)
    {
        InviteFriendsTableViewCell* cell = (InviteFriendsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellInviteIdentifier];
        if (cell == nil)
        {
            cell = [[InviteFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellInviteIdentifier];
        }
        return cell;
    }
    
    UserListTableViewCell* cell = (UserListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellUserIdentifier];
    
    NSInteger userIndex = indexPath.row * 3;
    
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
        CGFloat delay = 0;
        if (self.delayTokens > 0)
            delay = self.delay;
        
        cell = [[UserListTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellUserIdentifier users:usersForRow delay:delay target:self action:@selector(onUserClicked:)];
        
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





//- (void)cellFadeIn:(NSTimer*)timer
//{
//    RadioListTableViewCell* cell = timer.userInfo;
//    cell
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
- (void)onRadioClicked:(Radio*)radio
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
    
//    if (!self.showRefreshIndicator)
//        return;
    
    //
    // Refresh Indicator
    //
    if (self.refreshIndicator.status != eStatusOpened) {

        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;

        // close it
        if (bottomEdge < (scrollView.contentSize.height + self.refreshIndicator.height/2.f)) {
            
            if (self.refreshIndicator.status == eStatusPulled)
                [self.refreshIndicator close];
        }
        
        // pull it out
        else if (_dragging && (self.refreshIndicator.status == eStatusClosed) && (bottomEdge >= (scrollView.contentSize.height + self.refreshIndicator.height/2.f))) {
            
            [self.refreshIndicator pull];
        }

        // open it entirely
        else if (_dragging && (self.refreshIndicator.status == eStatusPulled) &&  (bottomEdge >= (scrollView.contentSize.height + self.refreshIndicator.height))) {
            
            [self.refreshIndicator open];
        }
    }
    
    
    //
    // Genre Selector
    //
    if (self.genreSelector.status == eGenreStatusClosed) {
        
//        NSLog(@"%.2f < %.2f",scrollView.contentOffset.y, self.genreSelector.frame.size.height );
        
        if (_dragging && (scrollView.contentOffset.y < (0-self.genreSelector.frame.size.height))) {
            self.genreSelector.status = eGenreStatusPulled;
        }
        else
        
            if (_dragging && (scrollView.contentOffset.y < 0)) {
            CGFloat posY = 0 - scrollView.contentOffset.y - self.genreSelector.frame.size.height;
            [self.genreSelector moveTo:posY];
        }
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    _dragging = YES;

}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    _dragging = NO;
    
    if (self.showRefreshIndicator) {

        if (self.refreshIndicator.status == eStatusWaitingToClose) {
            [self unfreeze];
        }
        
        else if ((self.refreshIndicator.status == eStatusOpened) && !_loadingNextPage) {

            [self.refreshIndicator openedAndRelease];
            
            [self freeze];
            
            
            // request next page to the server
            _loadingNextPage = [self.listDelegate listRequestNextPage];
            
            if (!_loadingNextPage)
                [self unfreeze];

        }
        
    }


    if (self.showGenreSelector) {
        
        if (self.genreSelector.status == eGenreStatusPulled) {
            [self openGenreSelector];
        }
    }

}


- (void)openGenreSelector {
    
    self.genreSelector.status = eGenreStatusOpened;
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + self.genreSelector.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height - self.genreSelector.frame.size.height);
    
    [self.genreSelector open];

}



- (void)freeze {
    
    if (!self.showRefreshIndicator)
        return;
    
    
    _freezeDate = [NSDate date];
    [_freezeDate retain];
    
    _freezeTimeout = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(freezeTimeout:) userInfo:nil repeats:NO];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height + self.refreshIndicator.height);
    [UIView commitAnimations];
    
//    self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + self.refreshIndicator.height);
    
}


- (void)freezeTimeout:(NSTimer*)timer {
    
    _freezeTimeout = nil;
    
    [self unfreeze];
}


- (void)unfreeze {
    
    if (!self.showRefreshIndicator)
        return;
    
    [_freezeTimeout invalidate];
    _freezeTimeout = nil;
    
    if (_dragging) {
        self.refreshIndicator.status = eStatusWaitingToClose;
        return;
    }

    _dragging = NO;
    _loadingNextPage = NO;
    
    NSDate* now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:_freezeDate];
    
    if (interval < 1)
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(unfreezeFinish) userInfo:nil repeats:NO];
    else
        [self unfreezeFinish];

}

- (void)unfreezeFinish {
    
    if (!self.showRefreshIndicator)
        return;

    [self.refreshIndicator close];
    
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
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + self.tableView.frame.size.height) animated:YES];
}






@end
