//
//  RadioViewController.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioViewController.h"
#import "ASIFormDataRequest.h"
#import "AudioStreamer.h"
#import "Theme.h"
#import "Track.h"
#import "RadioViewCell.h"

//#define LOCAL 1 // use localhost as the server

#define SERVER_DATA_REQUEST_TIMER 5.0f

@implementation RadioViewController


@synthesize messages;
@synthesize statusMessages;


- (id)init
{
    self = [super init];
    if (self) 
    {
        self.messages = [[NSMutableArray alloc] init];
        self.statusMessages = [[NSMutableArray alloc] init];
        
        _statusBarButtonToggled = NO;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewCellMessage" error:nil];
        _messageFont = [sheet makeFont];
        [_messageFont retain];
        
        _messageWidth = sheet.frame.size.width;
        
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewTableViewCellMinHeight" error:nil];
        _cellMinHeight = [[sheet.customProperties objectForKey:@"minHeight"] floatValue];

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
    
    //....................................................................................
    //
    // header
    //
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeader" error:nil];
    UIView* headerView = [[UIView alloc] initWithFrame:sheet.frame];
    headerView.backgroundColor = sheet.color;
    [self.view addSubview:headerView];
    
    // header picto image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderPicto" error:nil];
    UIImageView* image = [[UIImageView alloc] initWithImage:[sheet image]];
    CGFloat x = self.view.frame.origin.x + self.view.frame.size.width - sheet.frame.size.width;
    image.frame = CGRectMake(x, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
    [headerView addSubview:image];
    
    
    // header back arrow
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderBack" error:nil];
    UIButton* btn = [sheet makeButton];
    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn];
    
    // header avatar
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderAvatar" error:nil];
    UIImageView* avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarDummy.png"]];
    avatar.frame = sheet.frame;
    [headerView addSubview:avatar];
    
    // header avatar mask
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderAvatarMask" error:nil];
    UIImageView* avatarMask = [[UIImageView alloc] initWithImage:[sheet image]];
    avatarMask.frame = sheet.frame;
    [headerView addSubview:avatarMask];
    
    // header title
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderTitle" error:nil];
    UILabel* label = [sheet makeLabel];
    [headerView addSubview:label];
    
    // header heart image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderHeart" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [headerView addSubview:image];

    // header likes
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderLikes" error:nil];
    label = [sheet makeLabel];
    [headerView addSubview:label];
    
    // header headset image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderHeadSet" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [headerView addSubview:image];
    
    // header listeners
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderListeners" error:nil];
    label = [sheet makeLabel];
    [headerView addSubview:label];
    
    //....................................................................................
    //
    // header now playing bar
    //
    
    // header now playing bar image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBar" error:nil];
    
    _playingNowContainer = [[UIView alloc] initWithFrame:sheet.frame];
    [self.view addSubview:_playingNowContainer];

    _playingNowView = nil;

    // now playing bar is set in setNowPlaying;
    
    //....................................................................................
    //
    // message bar
    //
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewMessageBarBackground" error:nil];
    UIView* messageBarView = [[UIView alloc] initWithFrame:sheet.frame];
    messageBarView.backgroundColor = sheet.color;
    [self.view addSubview:messageBarView];   
    
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewMessageBar" error:nil];    
    UITextField* messageBar = [[UITextField alloc] initWithFrame:sheet.frame];
    messageBar.delegate = self;
    [messageBar setBorderStyle:UITextBorderStyleRoundedRect];
    [messageBar setPlaceholder:NSLocalizedString(@"radioview_message", nil)];

    sheet = [[Theme theme] stylesheetForKey:@"RadioViewMessageBarFont" error:nil];
    [messageBar setFont:[sheet makeFont]];

    // don't add messagebar now, do it after the extra layer
    
    //....................................................................................
    //
    // table view
    //
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewTableView" error:nil];    
    _tableView = [[UITableView alloc] initWithFrame:sheet.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    

    sheet = [[Theme theme] stylesheetForKey:@"RadioViewTableViewCellMinHeight" error:nil];    
    _tableView.rowHeight = [[sheet.customProperties objectForKey:@"minHeight"] integerValue];

    [self.view addSubview:_tableView];

    
    //....................................................................................
    //
    // extra layer
    //
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewExtraLayer" error:nil];
    image = [sheet makeImage];
    [self.view addSubview:image];

    
    //....................................................................................
    //
    // status bar
    //
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBar" error:nil];
    _statusBar = [[UIView alloc] initWithFrame:sheet.frame];
    UIImageView* statusBarBackground = [sheet makeImage];
    statusBarBackground.frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
    [self.view addSubview:_statusBar];
    [_statusBar addSubview:statusBarBackground];
    
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarButton" error:nil];
    _statusBarButton = [sheet makeButton];
    [_statusBarButton addTarget:self action:@selector(onStatusBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_statusBar addSubview:_statusBarButton];
    
    // status bar avatar
    // build dynamically
    _statusUsers = nil;
    
    

    
    //....................................................................................
    //
    // add objects that must display ABOVE the extra layer
    //
    [self.view addSubview:messageBar];

    
    [self onUpdate:nil];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    
//  NSURL* radiourl = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net:8000/cedric.mp3"];
//  mpStreamer = [[AudioStreamer alloc] initWithURL: radiourl];
//  [mpStreamer retain];
//  [mpStreamer start];
    
    //....................................................................................
    //
    // data update timer
    //
    _timerUpdate = [NSTimer scheduledTimerWithTimeInterval:SERVER_DATA_REQUEST_TIMER target:self selector:@selector(onUpdate:) userInfo:nil repeats:YES];    

    // LBDEBUG fake timer for status messages
    [self onFakeUpdateStatus:nil];
    _timerFake = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(onFakeUpdateStatus:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
//  [mpStreamer stop];
//  [mpStreamer release];
    
    [_timerUpdate invalidate];
    [_timerFake invalidate];
    _timerUpdate = nil;
    _timerFake = nil;
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

- (void)dealloc
{
    [_messageFont release];
    [super dealloc];
}





#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:TRUE];
    [self sendMessage:textField.text];
    textField.text = nil;
    return FALSE;
}


- (void)sendMessage:(NSString *)message
{
  
#if LOCAL
  NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/sendpostAPI/"];
#else
  NSURL *url = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net/yaapp/wall/sendpostAPI/"];
#endif

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request addPostValue:@"jmp" forKey:@"author"];
    //[request addPostValue:@"meeloo" forKey:@"author"];
    [request addPostValue:[[UIDevice currentDevice] name] forKey:@"author"];

    [request addPostValue:@"pipo" forKey:@"password"];
    [request addPostValue:@"text" forKey:@"kind"];
    [request addPostValue:message forKey:@"posttext"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(sendMessageFailed:)];
    [request setDidFinishSelector:@selector(sendMessageFinished:)];    
    
    NSLog(@"\nSENDMESSAGE '%@'\n", message);
    
//    [request startAsynchronous];
    [request startSynchronous];
}


- (void)sendMessageFailed:(ASIHTTPRequest *)request
{
    NSLog(@"sendMessage failed.");
}

- (void)sendMessageFinished:(ASIHTTPRequest*)request
{
    NSLog(@"sendMessage finished with code %d", request.responseStatusCode);
}




#pragma mark - TableView Source and Delegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
//    NSLog(@"number messages %d", [self.messages count]);
    return [self.messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    Message* m = [self.messages objectAtIndex:indexPath.row];

    return m.textHeight + _cellMinHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"RadioViewCell";
    
    Message* m = [self.messages objectAtIndex:indexPath.row];

    RadioViewCell* cell = (RadioViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[RadioViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier message:m indexPath:indexPath] autorelease];
    }
    else
        [cell update:m indexPath:indexPath];
    
    return cell;
}




//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}
//





#pragma mark - Data 


//LBDEBUG fake messages in status bar
static NSArray* fakeMessages = nil;
static NSMutableArray* fakeTracks = nil;
static NSInteger gFakeTrackIndex = -1;

- (void)onFakeUpdateStatus:(NSTimer*)timer
{
    //LBDEBUG fake messages in status bar
    if (fakeMessages == nil)
    {
        fakeMessages = [NSArray arrayWithObjects:@"Vestibulum interdum magna sed quam", @"Pellentesque dapibus sodales enim", @"Nullam porttitor elementum ligula", @"Vivamus convallis urna id felis", nil];
        [fakeMessages retain];
        srand(time(NULL));
    }
    NSInteger fakeIndex = rand() % 4;
    NSString* fakeText = [NSString stringWithString:[fakeMessages objectAtIndex:fakeIndex]];
    [self setStatusMessage:fakeText];
    
    
    if (fakeTracks == nil)
    {
        fakeTracks = [[NSMutableArray alloc] init];
        [fakeTracks retain];
        
        Track* track = [[[Track alloc] init] autorelease];
        track.artist = @"quis";
        track.title = @"Vestibulum interdum magna sed quam";
        track.likes = rand() % 99999;
        track.dislikes = rand() % 99999;
        [fakeTracks addObject:track];
        
        track = [[[Track alloc] init] autorelease];
        track.artist = @"quisque";
        track.title = @"Etiam eu ante non leo egestas nonummy";
        track.likes = rand() % 99999;
        track.dislikes = rand() % 99999;
        [fakeTracks addObject:track];

        track = [[[Track alloc] init] autorelease];
        track.artist = @"vivamus";
        track.title = @"Maecenas tempus dictum libero";
        track.likes = rand() % 99999;
        track.dislikes = rand() % 99999;
        [fakeTracks addObject:track];
    }
    
    //LBDEBUG
    NSInteger fakeTrackIndex = rand() % 3;
    while (fakeTrackIndex == gFakeTrackIndex)
        fakeTrackIndex = rand() % 3;
    Track* track = [fakeTracks objectAtIndex:fakeTrackIndex];
    gFakeTrackIndex = fakeTrackIndex;
    
    [self setNowPlaying:track];
    
    /////////////////////////////
}

//////////////////

- (void)onUpdate:(NSTimer*)timer
{
//#if LOCAL
//    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/all/"];  
//#else
//    NSURL *url = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net/yaapp/wall/all/"];
//#endif
    
#if LOCAL
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/allAPI/"];
#else
    NSURL *url = [NSURL URLWithString:@"http://dev.yasound.com/yaapp/wall/allAPI/"];
#endif

    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startSynchronous];

    // asynchronous
//	ASIHTTPRequest *request = [ASIFormDataRequest requestWithURL:url];
//	[request setDelegate:self];
//	[request startAsynchronous];
    
    
    
    
}


//- (void)requestStarted:(ASIHTTPRequest *)request
//{
//    NSLog(@"requestStarted");
//}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"RadioViewController update requestFailed");
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Request sent, response we got: \n%@\n\n", request.responseString);
    NSLog(@"status message: %@\n\n", request.responseStatusMessage);
    NSLog(@"cookies: %@\n\n", request.responseCookies);
    
    //clean message arrays
    [self.messages removeAllObjects];
    
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:request.responseData];
    [parser setDelegate:self];
    [parser parse];
    
    [_tableView reloadData];    
}



#pragma mark - NSXLMParser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    //NSLog(@"XML start element: %@", elementName);
    
    if ( [elementName isEqualToString:@"post"]) 
        _currentMessage = [[Message alloc] init];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    if (!_currentXMLString)
        _currentXMLString = [[NSMutableString alloc] initWithCapacity:50];

    [_currentXMLString appendString:string];
}



- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString* str = [_currentXMLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    //NSLog(@"XML end element: %@", elementName);
    
    if ([elementName isEqualToString:@"post"]) 
    {
        if ([self.messages count] < _currentMessage.identifier - 1)
        {
            //NSLog(@"New post: %d\n", _currentMessage.identifier);

            Message* m = [[Message alloc] init];
            m.user = _currentMessage.user;
            m.date = _currentMessage.date;
            m.text = _currentMessage.text;
            
            // compute the size of the text => will allow to update the cell's height dynamically
            CGSize suggestedSize = [m.text sizeWithFont:_messageFont constrainedToSize:CGSizeMake(_messageWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            m.textHeight = suggestedSize.height;

            
            [self.messages insertObject:m atIndex:0];
        }
        else
            [_currentMessage release];
            _currentMessage = nil;
    }
    else if ([elementName isEqualToString:@"id"]) 
    {
        _currentMessage.identifier = str.intValue;
    }
    else if ([elementName isEqualToString:@"kind"]) 
    {
        _currentMessage.kind = str;
    }
    else if ([elementName isEqualToString:@"author"]) 
    {
        _currentMessage.user = str;
    }
    else if ([elementName isEqualToString:@"date"]) 
    {
        _currentMessage.date = str;
    }
    else if ([elementName isEqualToString:@"message"]) 
    {
        _currentMessage.text = str;
    }

    [_currentXMLString release];
    _currentXMLString = nil;
}




#pragma mark - Now Playing
- (void)setNowPlaying:(Track*)track
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];

    CGRect frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
    UIView* view = [[UIView alloc] initWithFrame:frame];
                    
    //LBDEBUG
    NSInteger randIndex = (rand() %5)+1;
    UIImage* avatar = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
    
    // header now playing bar track image 
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarImage" error:nil];
    UIImageView* image = [[UIImageView alloc] initWithImage:avatar];
    image.frame = sheet.frame;
    [view addSubview:image];
    
    // header now playing bar track image mask
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarMask" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [view addSubview:image];
    
    
    // header now playing bar label
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarLabel" error:nil];
    UILabel* label = [sheet makeLabel];
    [view addSubview:label];
    
    // header now playing bar artist
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarArtist" error:nil];
    label = [sheet makeLabel];
    label.text = track.artist;
    [view addSubview:label];
    
    // header now playing bar title
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarTitle" error:nil];
    label = [sheet makeLabel];
    label.text = track.title;
    [view addSubview:label];
    
    // header now playing bar likes image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarLikesImage" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [view addSubview:image];
    
    // header now playing bar likes
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarLikes" error:nil];
    label = [sheet makeLabel];
    label.text = [NSString stringWithFormat:@"%d", track.likes];
    [view addSubview:label];
    
    // header now playing bar dislikes image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarDislikesImage" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [view addSubview:image];
    
    // header now playing bar dislikes
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarDislikes" error:nil];
    label = [sheet makeLabel];
    label.text = [NSString stringWithFormat:@"%d", track.dislikes];
    [view addSubview:label];
    
//    [self.view addSubview:view];

//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1.0];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:view cache:YES];
//    
////    UIView *parent = self.view.superview;
//    if (_playingNowView)
//        [_playingNowView removeFromSuperview];
//
//    [self.view addSubview:view];
//    
//    [UIView commitAnimations];   

    
    [UIView transitionWithView:_playingNowContainer
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ [_playingNowView removeFromSuperview]; [_playingNowContainer addSubview:view]; }
                    completion:NULL];
    
    _playingNowView = view;
    
}


#pragma mark - Status Bar

- (void)setStatusMessage:(NSString*)msg
{
    if (_statusBarButtonToggled)
        return;
    
    [self cleanStatusMessages];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = msg;
    label.alpha = 1;
    [_statusBar addSubview:label];

    [self.statusMessages addObject:label];
    
    // make the text appear with animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.33];
    label.frame = CGRectMake(8, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
    [UIView commitAnimations];        
    
    // programm a fade out with delay
    [NSTimer scheduledTimerWithTimeInterval:2.4f target:self selector:@selector(onStatusMessageFadeOutTick:) userInfo:label repeats:NO];
}

- (void)cleanStatusMessages
{
    if ([self.statusMessages count] > 0)
    {
        for (UILabel* label in self.statusMessages)
        {
            [self onStatusMessageFadeOut:label withRelease:NO];
        }
    }
}


- (void)onStatusMessageFadeOutTick:(NSTimer*)timer
{
    UILabel* label = timer.userInfo;
    [self onStatusMessageFadeOut:label withRelease:YES];
}


- (void)onStatusMessageFadeOut:(UILabel*)label withRelease:(BOOL)withRelease
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.33];
    label.alpha = 0;
    [UIView commitAnimations];          

    // programm a release
    if (withRelease)
        [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(onStatusMessageRelease:) userInfo:label repeats:NO];
}

- (void)onStatusMessageRelease:(NSTimer*)timer
{
    UILabel* label = timer.userInfo;
    
    [label release];
    [self.statusMessages removeObject:label];
}


#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)onStatusBarButtonClicked:(id)sender
{
    BundleStylesheet* sheet = nil;
    
    // downsize status bar : hide users
    if (_statusBarButtonToggled)
    {
        _statusBarButtonToggled = !_statusBarButtonToggled;

        sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarButtonOff" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [_statusBarButton setImage:[sheet image] forState:UIControlStateNormal];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 0.15];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onStatusBarClosed:finished:context:)];
        
        _statusBar.frame = CGRectMake(_statusBar.frame.origin.x, _statusBar.frame.origin.y + _statusBar.frame.size.height/2, _statusBar.frame.size.width, _statusBar.frame.size.height);
        _statusUsers.alpha = 0;
        [UIView commitAnimations];        
    }
    
    // upsize status bar : show users
    else
    {
        [self cleanStatusMessages];
        
        _statusBarButtonToggled = !_statusBarButtonToggled;

        sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarButtonOn" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [_statusBarButton setImage:[sheet image] forState:UIControlStateNormal];
        
        BundleStylesheet* imageSheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarUserImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        BundleStylesheet* nameSheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarUserName" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        CGRect imageRect = imageSheet.frame;
        CGRect nameRect = nameSheet.frame;

        // get list of users and create scrollview
        NSArray* users = [NSArray arrayWithObjects:@"tom", @"bernard", @"Jean-Claude Machine", @"Alberte", @"Jackie42", @"Mouss4_3", @"Tchoupi2", @"LeSanglier", @"Coco A", @"Riquiqui", nil];
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarUserScrollView" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _statusUsers = [[UIScrollView alloc] initWithFrame:sheet.frame];
        
        // fill scrollview with users
        for (NSString* user in users)
        {
            NSInteger randIndex = (rand() %5)+1;
            UIImage* avatar = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
            if (avatar == nil)
            {
                NSLog(@"error loading avatar %@", [NSString stringWithFormat:@"avatarDummy%d.png", randIndex]);
            }
            UIImageView* image = [[UIImageView alloc] initWithImage:avatar];
            image.frame = imageRect;
            [_statusUsers addSubview:image];
            
            UILabel* name = [nameSheet makeLabel];
            name.frame = nameRect;
            name.text = user;
            [_statusUsers addSubview:name];
            
            imageRect = CGRectMake(imageRect.origin.x + nameRect.size.width +1, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
            nameRect = CGRectMake(nameRect.origin.x + nameRect.size.width +1, nameRect.origin.y, nameRect.size.width, nameRect.size.height);
            
        }
        
        // set scrollview content size
//        [_statusUsers setContentSize:CGSizeMake(nameRect.origin.x + nameRect.size.width, _statusBar.frame.size.height)];
        [_statusUsers setContentSize:CGSizeMake(nameRect.origin.x, _statusBar.frame.size.height)];
        
        _statusUsers.alpha = 0;
        [_statusBar addSubview:_statusUsers];


        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 0.15];
        _statusBar.frame = CGRectMake(_statusBar.frame.origin.x, _statusBar.frame.origin.y - _statusBar.frame.size.height/2, _statusBar.frame.size.width, _statusBar.frame.size.height);
        _statusUsers.alpha = 1;
        [UIView commitAnimations];        
    }
    
}


- (void)onStatusBarClosed:(NSString *)animationId finished:(BOOL)finished context:(void *)context 
{
    [_statusUsers removeFromSuperview];
    [_statusUsers release];
}









@end







//- (NSString*) getWall
//{
//    // Needed to init cookies
//#if LOCAL
//    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/wall/all/"];  
//#else
//    NSURL *url = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net/yaapp/wall/all/"];
//#endif
//    
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request setDelegate:self];
//    [request startSynchronous];
//    
//    //NSLog(@"Request sent, response we got: %@\n\n", request.responseString);
//    return request.responseString;
//}

