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

- (id)initWithFrame:(CGRect)frame radios:(NSArray*)radios withContentsHeight:(CGFloat)contentsHeight showRefreshIndicator:(BOOL)showRefreshIndicator
{
    self = [super init];
    if (self)
    {
        _dragging = NO;
        
        self.showRefreshIndicator = showRefreshIndicator;
        
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radioListRowBkgSize2.png"]];
        
        _loadingNextPage = NO;
        _contentsHeight = contentsHeight;
        
        self.delayTokens = 2;
        self.delay = 0.15;
        
        self.radios = radios;
        self.radiosPreviousCount = radios.count;
        self.friendsMode = NO;
        

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

- (void)setRadios:(NSArray*)radios
{
    _radios = radios;
    [_radios retain];
    
    self.radiosPreviousCount = radios.count;
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.friendsMode)
    {
        if (self.friends == nil)
            return 0;
        NSInteger nbRows = self.friends.count / 3;
        if ((self.friends.count % 3) != 0)
            nbRows++;
        return nbRows;
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
    
    if (!self.showRefreshIndicator)
        return;

    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;

    if (bottomEdge < (scrollView.contentSize.height + self.refreshIndicator.height/2.f)) {
        
        if (self.refreshIndicator.status == eStatusPulled)
            [self.refreshIndicator close];
//        else if (self.refreshIndicator.status == eStatusOpened)
//            [self.refreshIndicator unfree];
    }
    
    
    else if (_dragging && (self.refreshIndicator.status == eStatusClosed) && (bottomEdge >= (scrollView.contentSize.height + self.refreshIndicator.height/2.f))) {
        
        [self.refreshIndicator pull];
    }

    
    else if (_dragging && (self.refreshIndicator.status == eStatusPulled) &&  (bottomEdge >= (scrollView.contentSize.height + self.refreshIndicator.height))) {
        
        [self.refreshIndicator open];
        
//        // request next page to the server
//        _loadingNextPage = [self.listDelegate listRequestNextPage];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    _dragging = YES;

    if (!self.showRefreshIndicator)
        return;
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    _dragging = NO;
    
    if (!self.showRefreshIndicator)
        return;

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

//    else if ((self.refreshIndicator.status == eStatusOpened) && _loadingNextPage) {
//        [self freeze];
//    }
    
//    [self.tableView reloadData];    
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
//    self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - self.refreshIndicator.height);
    
    
}


//UITableViewRowAnimationFade,
//UITableViewRowAnimationRight,           // slide in from right (or out to right)
//UITableViewRowAnimationLeft,
//UITableViewRowAnimationTop,
//UITableViewRowAnimationBottom,
//UITableViewRowAnimationNone,            // available in iOS 3.0
//UITableViewRowAnimationMiddle,          // available in iOS 3.2.  attempts to keep cell centered in the space it will/did occupy
//UITableViewRowAnimationAutomatic = 100  // available in iOS 5.0.  chooses an appropriate animation style for you
//


- (void)unfreezeAnimationStoped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if (!self.showRefreshIndicator)
        return;

//    [self.tableView beginUpdates];
//
//    
//    //    [self.tableView reloadData];
//    NSMutableArray* array = [NSMutableArray array];
//    
//    NSInteger previousNbRows = [self numberOfRowsFromRadios:self.radiosPreviousCount];
//    NSInteger nbRows = [self numberOfRowsFromRadios:self.radios.count];
//    
//    for (NSInteger row = previousNbRows; row < nbRows; row++) {
//        NSLog(@"row %d", row);
//        [array addObject:[NSIndexPath indexPathForRow:row inSection:0]];
//    }
//    
//    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
//
//    [self.tableView endUpdates];
//    
//    [array insertObject:[NSIndexPath indexPathForRow:(previousNbRows-1) inSection:0] atIndex:0];
//    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
//    
//    self.radiosPreviousCount = self.radios.count;
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + self.tableView.frame.size.height) animated:YES];
    
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(afterReload:) userInfo:nil repeats:NO];
}

- (void)afterReload:(NSTimer*)timer {

    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + self.tableView.frame.size.height) animated:YES];
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3];
//
//    self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + self.tableView.frame.size.height);
//    [UIView commitAnimations];
}






@end
