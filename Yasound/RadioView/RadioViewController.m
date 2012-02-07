//
//  RadioViewController.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "RadioViewController.h"
#import "ASIFormDataRequest.h"
#import "Theme.h"
#import "Track.h"
#import "RadioViewCell.h"


#import "YasoundDataProvider.h"
#import "WallEvent.h"

#import "RadioUser.h"
#import "ActivityAlertView.h"
#import "Tutorial.h"
#import "InteractiveView.h"
#import "ActivityModelessSpinner.h"
#import "AudioStreamer.h"
#import "AudioStreamManager.h"
#import "RootViewController.h"

#import "User.h"
#import "DateAdditions.h"
#import "GANTracker.h"

#import "UserViewCell.h"

//#define LOCAL 1 // use localhost as the server

#define SERVER_DATA_REQUEST_TIMER 5.0f
#define ROW_SONG_HEIGHT 18

#define NB_MAX_EVENTMESSAGE 10

#define WALL_FIRSTREQUEST_FIRST_PAGESIZE 20
#define WALL_FIRSTREQUEST_SECOND_PAGESIZE 20


@implementation RadioViewController


static Song* _gNowPlayingSong = nil;



@synthesize radio;
//@synthesize messages;
@synthesize statusMessages;
@synthesize ownRadio;
@synthesize favoriteButton;

- (id)initWithRadio:(Radio*)radio
{
    self = [super init];
    if (self) 
    {
        self.radio = radio;
        
        self.ownRadio = [[YasoundDataProvider main].user.id intValue] == [self.radio.creator.id intValue];

//        _trackInteractionViewDisplayed = NO;

        _serverErrorCount = 0;
        _streamErrorCount = 0;
        _updatingPrevious = NO;
        _firstUpdateRequest = YES;
        _latestEvent = nil;
        _lastWallEvent = nil;
        _countMessageEvent = 0;
        _lastSongUpdateDate = nil;

        self.statusMessages = [[NSMutableArray alloc] init];

        _statusBarButtonToggled = NO;

        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"CellMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _messageFont = [sheet makeFont];
        [_messageFont retain];

        _messageWidth = sheet.frame.size.width;

        sheet = [[Theme theme] stylesheetForKey:@"CellMinHeight" error:nil];
        _cellMinHeight = [[sheet.customProperties objectForKey:@"minHeight"] floatValue];

        _wallEvents = [[NSMutableArray alloc] init];
      _connectedUsers = nil;
      _usersContainer = nil;
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
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Header" error:nil];
    _headerView = [[UIView alloc] initWithFrame:sheet.frame];
    _headerView.backgroundColor = sheet.color;
    [self.view addSubview:_headerView];
    
    // header background
    sheet = [[Theme theme] stylesheetForKey:@"HeaderBackground" error:nil];
    UIImageView* image = [[UIImageView alloc] initWithImage:[sheet image]];
    CGFloat x = self.view.frame.origin.x + self.view.frame.size.width - sheet.frame.size.width;
    image.frame = CGRectMake(x, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
    [_headerView addSubview:image];
    
    
//    // header back arrow
//    sheet = [[Theme theme] stylesheetForKey:@"HeaderBack" error:nil];
//    UIButton* btn = [sheet makeButton];
//    [_headerView addSubview:btn];
    
    // header avatar, as a second back button
    sheet = [[Theme theme] stylesheetForKey:@"HeaderAvatar" error:nil];
    _radioImage = [[WebImageView alloc] initWithImageFrame:sheet.frame];
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    [_radioImage setUrl:imageURL];
    [_headerView addSubview:_radioImage];
    
    // header avatar mask  as button
    sheet = [[Theme theme] stylesheetForKey:@"HeaderAvatarMask" error:nil];
    UIButton* btn = [[UIButton alloc] initWithFrame:sheet.frame];
    [btn setImage:[sheet image] forState:UIControlStateNormal]; 
    [_headerView addSubview:btn];
    
    
    // header title
    sheet = [[Theme theme] stylesheetForKey:@"HeaderTitle" error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = self.radio.name;
    [_headerView addSubview:label];

    

    // header favorite
    sheet = [[Theme theme] stylesheetForKey:@"HeaderLikes" error:nil];
    _favoritesLabel = [sheet makeLabel];
    _favoritesLabel.text = [NSString stringWithFormat:@"%d", [self.radio.favorites integerValue]];
    [_headerView addSubview:_favoritesLabel];
    
    
    //favorites button
    sheet = [[Theme theme] stylesheetForKey:@"HeaderFavoriteButtonFrame" error:nil];
    CGRect frame = sheet.frame;
    self.favoriteButton = [[UIButton alloc] initWithFrame:sheet.frame];
    
    NSString* tmppath = [[Theme theme] pathForResource:@"btnFavoriteEmpty" ofType:@"png" inDirectory:@"images/Header/Buttons"];
    UIImage* imageFile = [UIImage imageWithContentsOfFile:tmppath];
    [self.favoriteButton setImage:imageFile forState:UIControlStateNormal];

    tmppath = [[Theme theme] pathForResource:@"btnFavoriteFull" ofType:@"png" inDirectory:@"images/Header/Buttons"];
    imageFile = [UIImage imageWithContentsOfFile:tmppath];
    [self.favoriteButton setImage:imageFile forState:UIControlStateSelected];
    
    [self.favoriteButton addTarget:self action:@selector(onFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:self.favoriteButton];
    
    
    
    
    
    
    
    
    
    

    
    
    //.................................................................................
    // header interactive zone to overload button
//    BundleStylesheet* sheetAvatar = [[Theme theme] stylesheetForKey:@"HeaderAvatar" error:nil];
//    
//    sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    
//    frame = CGRectMake(0, 0, sheetAvatar.frame.origin.x + sheetAvatar.frame.size.width, _headerView.frame.size.height - sheet.frame.size.height);
//    InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:frame target:self action:@selector(onBack:)];
//    [_headerView addSubview:interactiveView];

    sheet = [[Theme theme] stylesheetForKey:@"HeaderMenuButton" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    btn = [sheet makeButton];
    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:btn];
    
    
    
    
    
    //....................................................................................
    //
    // header now playing bar
    //
    
//    // border
//    sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBorder" error:nil];
//    UIImageView* imageView = [[UIImageView alloc] initWithImage:[sheet image]];
//    imageView.frame = sheet.frame;
//    [self.view addSubview:imageView];
    
    
    // header now playing bar image
    sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImageView* playingNowContainer = [[UIImageView alloc] initWithImage:[sheet image]];
    playingNowContainer.frame = sheet.frame;
    
//    _playingNowContainer = [[UIView alloc] initWithFrame:sheet.frame];
//    [self.view addSubview:_playingNowContainer];
    
    [self.view addSubview:playingNowContainer];

    _playingNowView = nil;
    
    // now playing bar is set in setNowPlaying;
  if (_gNowPlayingSong != nil)
  {
    [self setNowPlaying:_gNowPlayingSong];
  }
    

    
    
    
    //.......................................................................................................................................
    //
    // view container and view childs
    //
    sheet = [[Theme theme] stylesheetForKey:@"ViewContainer" error:nil];
    _viewContainer = [[UIView alloc] initWithFrame:sheet.frame];
    _viewContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_viewContainer];

    
    CGRect frameChild = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
    
    
    //.......................................................................................................................................
    //
    // child view Wall
    //
    _viewWall = [[UIView alloc] initWithFrame:frameChild];
    _viewWall.backgroundColor = [UIColor clearColor];
    [_viewContainer addSubview:_viewWall];
    
    
    
    //....................................................................................
    //
    // message bar
    //
    sheet = [[Theme theme] stylesheetForKey:@"MessageBarBackground" error:nil];
    UIImageView* messageBarView = [[UIImageView alloc] initWithImage:[sheet image]];
    messageBarView.frame = sheet.frame;
    
//    sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    messageBarView.backgroundColor = [UIColor colorWithPatternImage:sheet.image];
    [_viewWall addSubview:messageBarView];   
    
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewMessageBar" error:nil];    
    UITextField* messageBar = [[UITextField alloc] initWithFrame:sheet.frame];
    messageBar.delegate = self;
    [messageBar setBorderStyle:UITextBorderStyleRoundedRect];
    [messageBar setPlaceholder:NSLocalizedString(@"radioview_message", nil)];

    sheet = [[Theme theme] stylesheetForKey:@"RadioViewMessageBarFont" error:nil];
    [messageBar setFont:[sheet makeFont]];

    [_viewWall addSubview:messageBar];
    
    //....................................................................................
    //
    // table view
    //
    sheet = [[Theme theme] stylesheetForKey:@"TableView" error:nil];    
    _tableView = [[UITableView alloc] initWithFrame:sheet.frame style:UITableViewStylePlain];

    sheet = [[Theme theme] stylesheetForKey:@"TableViewBackground" error:nil];    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    

    sheet = [[Theme theme] stylesheetForKey:@"CellMinHeight" error:nil];    
    _tableView.rowHeight = [[sheet.customProperties objectForKey:@"minHeight"] integerValue];

    [_viewWall addSubview:_tableView];

    
    //....................................................................................
    //
    // status bar
    //
    BundleStylesheet* sheetStatus = [[Theme theme] stylesheetForKey:@"StatusBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _statusBar = [[UIView alloc] initWithFrame:sheetStatus.frame];
    UIImageView* statusBarBackground = [sheetStatus makeImage];
    statusBarBackground.frame = CGRectMake(0, 0, sheetStatus.frame.size.width, sheetStatus.frame.size.height);
    [self.view addSubview:_statusBar];
    [_statusBar addSubview:statusBarBackground];
    
    sheet = [[Theme theme] stylesheetForKey:@"StatusBarButton" error:nil];
    _statusBarButton = [sheet makeButton];
    [_statusBarButton addTarget:self action:@selector(onStatusBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_statusBar addSubview:_statusBarButton];
  
    
    // headset image
    sheet = [[Theme theme] stylesheetForKey:@"StatusHeadSet" error:nil];
    _listenersIcon = [[UIImageView alloc] initWithImage:[sheet image]];
    _listenersIcon.frame = sheet.frame;
    [_statusBar addSubview:_listenersIcon];
    
    // listeners
    sheet = [[Theme theme] stylesheetForKey:@"StatusListeners" error:nil];
    _listenersLabel = [sheet makeLabel];
    _listenersLabel.text = [NSString stringWithFormat:@"%d", [self.radio.listeners integerValue]];
    [_statusBar addSubview:_listenersLabel];
    
    
    
    
    
    
    
    
    
    //.......................................................................................................................................
    //
    // child view Tracks
    //
    
    frameChild = CGRectMake(frameChild.size.width, frameChild.origin.y, frameChild.size.width, frameChild.size.height);
    
    _viewTracks = [[TracksView alloc] initWithFrame:frameChild];
    [_viewTracks loadView];
    _viewTracks.backgroundColor = [UIColor clearColor];
    [_viewContainer addSubview:_viewTracks];
    
    _viewTracksDisplayed = NO;
    
    
    
    
    if (self.ownRadio)
    {
        // -----------------------------
        // One finger, swipe left
        // -----------------------------
        UISwipeGestureRecognizer* swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)] autorelease];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [_viewContainer addGestureRecognizer:swipeLeft];

        // -----------------------------
        // One finger, swipe right
        // -----------------------------
        UISwipeGestureRecognizer* swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)] autorelease];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [_viewContainer addGestureRecognizer:swipeRight];

        
        
        // -----------------------------
        // page control
        // -----------------------------
        CGRect framePageControl = CGRectMake(0, sheetStatus.frame.origin.y + 8, sheetStatus.frame.size.width, 12);
        
        _pageControl = [[UIPageControl alloc] initWithFrame:framePageControl];
        _pageControl.numberOfPages = 2;
        _pageControl.userInteractionEnabled = NO;
        [self.view addSubview:_pageControl];
    }
    
    
    
    // get the actual data from the server to update the GUI
    [self updatePreviousWall];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[AudioStreamManager main] startRadio:self.radio];
    [[YasoundDataProvider main] enterRadioWall:self.radio];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_PLAY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_STOP object:nil];
   
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    // <=> background audio playing
    [self becomeFirstResponder];    
    
    // check for tutorial
    [[Tutorial main] show:TUTORIAL_KEY_RADIOVIEW everyTime:NO];
    
    if (self.ownRadio)
        [[Tutorial main] show:TUTORIAL_KEY_TRACKSVIEW everyTime:NO];
    
    // update favorite button
    [[ActivityModelessSpinner main] addRef];
    [[YasoundDataProvider main] favoriteRadiosWithGenre:nil withTarget:self action:@selector(onFavoriteUpdate:)];
}
 


- (void)onFavoriteUpdate:(NSArray*)radios
{
    [[ActivityModelessSpinner main] removeRef];

    NSInteger currentRadioId = [self.radio.id integerValue];
    
    for (Radio* radio in radios)
    {
        if ([radio.id integerValue] == currentRadioId)
        {
            self.favoriteButton.selected = YES;
            return;
        }
    }
}
    















- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    if (_serverErrorCount == 0)
        [[YasoundDataProvider main] leaveRadioWall:self.radio];
    else
    {
        [[AudioStreamManager main] stopRadio];
    }
    
    if ((_timerUpdate != nil) && [_timerUpdate isValid])
    {
        [_timerUpdate invalidate];
        _timerUpdate = nil;
    }

    [super viewWillDisappear: animated];
}



- (void)viewDidUnload
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [_wallEvents release];
    [super dealloc];
}











//.................................................................................................
//
// DATA UPDATE
//


#pragma mark - Data 

#define EV_TYPE_MESSAGE @"M"
#define EV_TYPE_SONG @"S"


//....................................................................
//
// onTimerUpdate
//
// timer callback to call for updates from server
//

- (void)onTimerUpdate:(NSTimer*)timer
{    
    [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:25 target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
  [[YasoundDataProvider main] currentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
    [[YasoundDataProvider main] radioWithId:self.radio.id target:self action:@selector(receiveRadio:withInfo:)];
  
  [[YasoundDataProvider main] connectedUsersForRadio:self.radio target:self action:@selector(receivedConnectedUsers:withInfo:)];
}

- (void)updatePreviousWall
{    
    // PROFILE
    _BEGIN = [NSDate date];
    [_BEGIN retain];
    
    _updatingPrevious = YES;

    [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_FIRSTREQUEST_FIRST_PAGESIZE target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
  [[YasoundDataProvider main] currentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
    [[YasoundDataProvider main] radioWithId:self.radio.id target:self action:@selector(receiveRadio:withInfo:)];
}

- (void)updateCurrentWall
{    
    [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:25 target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
}




- (WallEvent*)fakeEventSong:(NSString*)name timeInterval:(NSInteger)timeInterval
{
    WallEvent* ev = [[WallEvent alloc] init];
    ev.type = [NSString stringWithString:EV_TYPE_SONG];
    ev.start_date = [NSDate date];
    ev.start_date = [ev.start_date addTimeInterval:timeInterval];
    ev.song_name = [NSString stringWithString:name];
    ev.song_id = [NSNumber numberWithInt:1];
    
    return ev;
}

- (WallEvent*)fakeEventMessage:(NSString*)user text:(NSString*)text  timeInterval:(NSInteger)timeInterval
{
    WallEvent* ev = [[WallEvent alloc] init];
    ev.type = [NSString stringWithString:EV_TYPE_MESSAGE];
    ev.start_date = [NSDate date];
    ev.start_date = [ev.start_date addTimeInterval:timeInterval];
    ev.text = [NSString stringWithString:text];
    ev.user_name = [NSString stringWithString:user];
    ev.user_id = [NSNumber numberWithInt:1];
    
    return ev;
}






+ (NSString*)evTypeToString:(NSString*)type
{
    if ([type isEqualToString:EV_TYPE_MESSAGE])
        return @"MESSAGE";
    if ([type isEqualToString:EV_TYPE_SONG])
        return @"SONG";
    
    return @"UNKNOWN";
}

- (void)logWallEvents
{
    int i = 0;
    for (WallEvent* w in _wallEvents)
    {
        NSLog(@"(%d) -%@- %@", i, w.type, [w.type isEqualToString:EV_TYPE_MESSAGE] ? w.text : w.song_name);
        i++;
    }
}

- (int)eventMessageCount
{
    int count = 0;
    for (WallEvent* w in _wallEvents)
    {
        if ([w.type isEqualToString:EV_TYPE_MESSAGE])
            count++;
    }
    return count;
}

- (int)eventSongCount
{
    int count = 0;
    for (WallEvent* w in _wallEvents)
    {
        if ([w.type isEqualToString:EV_TYPE_SONG])
            count++;
    }
    return count;
}









//.......................................................................................................
//
// received previous wall events
//

- (void)receivedPreviousWallEvents:(NSArray*)events withInfo:(NSDictionary*)info
{
    // PROFILE
    if (_firstUpdateRequest)
    {
        _END = [NSDate date];
        NSTimeInterval timeDifference = [_END timeIntervalSinceDate:_BEGIN];
        NSLog(@"PROFILE %.2f", timeDifference);
        
        [_BEGIN release];
    }
    
    
    Meta* meta = [info valueForKey:@"meta"];
    NSError* err = [info valueForKey:@"error"];
    
    if (err)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        
        NSLog(@"receivedPreviousWallEvents ERROR!");
        return;
    }
    
    if (!meta)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        
        NSLog(@"receivedPreviousWallEvents : ERROR no meta data!");
        return;
    }
    
    // reset error count
    _serverErrorCount = 0;
    
    if (!events || events.count == 0)
    {
        NSLog(@"NO MORE EVENTS. end receivedPreviousWallEvents\n");
        
        _updatingPrevious = NO;
        
        if (_firstUpdateRequest)
        {
            assert(_timerUpdate == nil);
            
            _firstUpdateRequest = NO;
            // launch the update timer
            _timerUpdate = [NSTimer scheduledTimerWithTimeInterval:SERVER_DATA_REQUEST_TIMER target:self selector:@selector(onTimerUpdate:) userInfo:nil repeats:YES];
        }

        return;
    }
    
    NSLog(@"\nreceivedPreviousWallEvents %d events", events.count);
    
    for (WallEvent* ev in events)
    {
        if ([ev.type isEqualToString:EV_TYPE_SONG])
            [self receivedPreviousSongEvent:ev];

        else if ([ev.type isEqualToString:EV_TYPE_MESSAGE])
        {
            [self receivedPreviousMessageEvent:ev];
            _countMessageEvent++;
        }
        
    }

    NSInteger count = events.count;

    // update _latestEvent
    
    WallEvent* ev = [events objectAtIndex:0];
    WallEvent* wev = nil;
    
    if (_wallEvents.count > 0)
        wev = [_wallEvents objectAtIndex:0];
    
    NSLog(@"first event is %@ : %@", [RadioViewController evTypeToString:ev.type], ev.start_date);
    
    if (wev != nil)
        NSLog(@"first wallevent is %@ : %@", [RadioViewController evTypeToString:wev.type], wev.start_date);

    if ((wev != nil) && [wev.start_date isLaterThan:ev.start_date])
        _latestEvent = wev;
    else
        _latestEvent = ev;    

    NSLog(@"_latestEvent is %@ : %@", [RadioViewController evTypeToString:_latestEvent.type], _latestEvent.start_date);
    NSLog(@"_lastWallEvent is %@ : %@", [RadioViewController evTypeToString:_lastWallEvent.type], _lastWallEvent.start_date);

    // launch update timer
    if (_firstUpdateRequest)
    {
        assert(_timerUpdate == nil);
        
        _firstUpdateRequest = NO;
        // launch the update timer
        _timerUpdate = [NSTimer scheduledTimerWithTimeInterval:SERVER_DATA_REQUEST_TIMER target:self selector:@selector(onTimerUpdate:) userInfo:nil repeats:YES];
    }

    
    // ask for more previous messages
    if (_countMessageEvent < NB_MAX_EVENTMESSAGE)
    {
        [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_FIRSTREQUEST_SECOND_PAGESIZE afterEventWithID:_lastWallEvent.id target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
    }
    else
    {
        _updatingPrevious = NO;
    }
    
    
    NSLog(@"end receivedPreviousWAllEvents\n");
}


- (void)receivedPreviousSongEvent:(WallEvent*)ev
{
    // update lastWallEvent
    if ((_lastWallEvent == nil) || ([ev.start_date isEarlierThanOrEqualTo:_lastWallEvent.start_date]))
        _lastWallEvent = ev;

  [_wallEvents addObject:ev];
  [self addSong];
}


- (void)receivedPreviousMessageEvent:(WallEvent*)ev
{
    // update lastWallEvent
    if ([ev.start_date isEarlierThanOrEqualTo:_lastWallEvent.start_date])
        _lastWallEvent = ev;
    
    [_wallEvents addObject:ev];
    [self addMessage];
}















//.......................................................................................................
//
// received current wall events
//

- (void)receivedCurrentWallEvents:(NSArray*)events withInfo:(NSDictionary*)info
{
    Meta* meta = [info valueForKey:@"meta"];
    NSError* err = [info valueForKey:@"error"];
    
    if (err)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        
        NSLog(@"receivedCurrentWallEvents ERROR!");
        return;
    }
    
    if (!meta)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        
        NSLog(@"receivedCurrentWallEvents : ERROR no meta data!");
        return;
    }
    
    // reset error count
    _serverErrorCount = 0;
    
    if (!events || events.count == 0)
    {
        NSLog(@"NO MORE EVENTS. end receivedCurrentWallEvents\n");
        return;
    }
    
    
    NSLog(@"\nreceivedCurrentWallEvents %d events", events.count);
  
  for (int i = events.count - 1; i >= 0; i--)
    {
      WallEvent* ev = [events objectAtIndex:i];        
        if ([ev.type isEqualToString:EV_TYPE_SONG])
            [self receivedCurrentSongEvent:ev];
        
        else if ([ev.type isEqualToString:EV_TYPE_MESSAGE])
        {
            [self receivedCurrentMessageEvent:ev];
            _countMessageEvent++;
        }
        
    }
    
    NSInteger count = events.count;
    
    if (count > 0)
    {
        assert(events.count > 0);
//        assert(_wallEvents.count > 0);

        WallEvent* ev = [events objectAtIndex:0];
        WallEvent* wev = nil;
        
        if (_wallEvents.count > 0)
            wev = [_wallEvents objectAtIndex:0];
        
        NSLog(@"first event is %@ : %@", [RadioViewController evTypeToString:ev.type], ev.start_date);
        if (wev != nil)
            NSLog(@"first wallevent is %@ : %@", [RadioViewController evTypeToString:wev.type], wev.start_date);
        
        if ((wev != nil) && [wev.start_date isLaterThan:ev.start_date])
            _latestEvent = wev;
        else
            _latestEvent = ev;
        
        
        NSLog(@"_latestEvent is %@ : %@", [RadioViewController evTypeToString:_latestEvent.type], _latestEvent.start_date);
    }
    else
        return;
    
    NSLog(@"end receivedCurrentWAllEvents\n");
}


- (void)receivedCurrentSongEvent:(WallEvent*)ev
{
    if ((_latestEvent != nil) && ([ev.start_date isEarlierThanOrEqualTo:_latestEvent.start_date]))
        return;
    
  [_wallEvents insertObject:ev atIndex:0];
  [self insertSong];
}


- (void)receivedCurrentMessageEvent:(WallEvent*)ev
{
    if ((_latestEvent != nil) && ([ev.start_date isEarlierThanOrEqualTo:_latestEvent.start_date]))
        return;
    
    NSLog(@"receivedCurrentMessageEvent ADD %@ : date %@", ev.user_name, ev.start_date);

    [_wallEvents insertObject:ev atIndex:0];
    [self insertMessage];
}



//
// Current Song
//
- (void) receivedCurrentSong:(Song*)song withInfo:(NSDictionary*)info
{
  if (!song)
    return;
  
  if (!_gNowPlayingSong || [song.id intValue] != [_gNowPlayingSong.id intValue])
      [self setNowPlaying:song];
  
  [[YasoundDataProvider main] statusForSongId:song.id target:self action:@selector(receivedCurrentSongStatus:withInfo:)];
}

- (void)receivedCurrentSongStatus:(SongStatus*)status withInfo:(NSDictionary*)info
{
  if (!status)
    return;
  if (_playingNowView)
    [_playingNowView setSongStatus:status];
}

- (void)receiveRadio:(Radio*)r withInfo:(NSDictionary*)info
{
    if (!r)
        return;
    
    self.radio = r;
    _favoritesLabel.text = [NSString stringWithFormat:@"%d", [self.radio.favorites integerValue]];
    _listenersLabel.text = [NSString stringWithFormat:@"%d", [self.radio.listeners integerValue]];
}




- (void)userJoined:(User*)u
{
  NSLog(@"%@ joined", u.name);
  [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se connecter", u.name]];
  
}

- (void)userLeft:(User*)u
{
  NSLog(@"%@ left", u.name);
  [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se déconnecter", u.name]];
}

- (void)receivedConnectedUsers:(NSArray*)users withInfo:(NSDictionary*)info
{
  if (!users || users.count == 0)
    return;
  
  if (_connectedUsers && _connectedUsers.count > 0)
  {
    // get diff
    NSMutableArray* joined = [NSMutableArray array];
    NSMutableArray* left = [NSMutableArray array];
    
    // user arrays are sorted by id
    NSArray* oldUsers = _connectedUsers;
    NSArray* newUsers = users;
    User* u;
    
    User* firstNew = [newUsers objectAtIndex:0];
    User* lastNew = [newUsers objectAtIndex:newUsers.count - 1];
    User* firstOld = [oldUsers objectAtIndex:0];
    User* lastOld = [oldUsers objectAtIndex:oldUsers.count - 1];
    
    
    for (u in oldUsers)
    {
      if ([u.id intValue] >= [firstNew.id intValue])
        break;
      [left addObject:u];
    }
    
    NSEnumerator* reverseEnumerator = [oldUsers reverseObjectEnumerator];
    while (u = [reverseEnumerator nextObject]) 
    {
      if ([u.id intValue] <= [lastNew.id intValue])
        break;
      [left addObject:u];
    }
    
    for (u in newUsers)
    {
      if ([u.id intValue] >= [firstOld.id intValue])
        break;
      [joined addObject:u];
    }
    
    reverseEnumerator = [newUsers reverseObjectEnumerator];
    while (u = [reverseEnumerator nextObject]) 
    {
      if ([u.id intValue] <= [lastOld.id intValue])
        break;
      [joined addObject:u];
    }
    
    
    for (u in joined)
      [self userJoined:u];
    for (u in left)
      [self userLeft:u];
  }
  
  if (_connectedUsers)
    [_connectedUsers release];
  _connectedUsers = users;
  [_connectedUsers retain];
  
  if (_usersContainer)
    [_usersContainer reloadData];
}














//.................................................................................................
//
// NOW PLAYING
//


#pragma mark - Now Playing

- (void)setNowPlaying:(Song*)song
{
  assert(song != nil);
    if (_gNowPlayingSong != nil)
        [_gNowPlayingSong release];
    
    _gNowPlayingSong = song;
    [_gNowPlayingSong retain];
    
//    if (_trackInteractionViewDisplayed)
//        return;
    
    if (_playingNowView != nil)
    {
        [_playingNowView removeFromSuperview];
        [_playingNowView release];
    }
    
    //LBDEBUG TODO : get image, likes dislikes from Song
    _playingNowView = [[NowPlayingView alloc] initWithSong:_gNowPlayingSong target:self action:@selector(onNowPlayingTouched)];
    [_playingNowView.playPauseButton addTarget:self action:@selector(onPlayPause:) forControlEvents:UIControlEventTouchUpInside];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _playingNowView.frame = sheet.frame;
    
    [self.view addSubview:_playingNowView];

    
//    [UIView transitionWithView:_playingNowContainer
//                      duration:0.5
//                       options:UIViewAnimationOptionTransitionFlipFromRight
//                    animations:^{ [_playingNowView removeFromSuperview]; if (_playingNowView){[_playingNowView release];} [_playingNowContainer addSubview:view]; _playingNowView = view; }
//                    completion:NULL];    
}


//- (void)onNowPlayingTouched
//{
//    CGRect frame, playingNowFrame, viewContainerFrame;
//    BOOL callbackWhenStop = NO;
//
//    // open the track interaction view
//    if (!_trackInteractionViewDisplayed)
//    {
//        _trackInteractionViewDisplayed = YES;
//
//        frame = _playingNowContainer.frame;
//        playingNowFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height *2);
//        viewContainerFrame = CGRectMake(_viewContainer.frame.origin.x, _viewContainer.frame.origin.y + frame.size.height, _viewContainer.frame.size.width, _viewContainer.frame.size.height - frame.size.height);
//        
//        _trackInteractionView = [[TrackInteractionView alloc] initWithSong:_playingNowView.song];
//        _trackInteractionView.frame = CGRectMake(0, frame.size.height -1, frame.size.width, frame.size.height);
//
//        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        _trackInteractionView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
//        
//        [_playingNowContainer addSubview:_trackInteractionView];
//
//    }
//
//    // close the track interaction view
//    else
//    {
//        _trackInteractionViewDisplayed = NO;
//        callbackWhenStop = YES;
//        
//        frame = _playingNowContainer.frame;
//        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height /2);
//        playingNowFrame = frame;
//        viewContainerFrame = CGRectMake(_viewContainer.frame.origin.x, _viewContainer.frame.origin.y - frame.size.height, _viewContainer.frame.size.width, _viewContainer.frame.size.height + frame.size.height);
//    }
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration: 0.16];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    if (callbackWhenStop)
//    {
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(nowPlayingAnimationFinished:finished:context:)];
//    }
//
//    
//    _playingNowContainer.frame = playingNowFrame;
//    _viewContainer.frame = viewContainerFrame;
//    
//    [UIView commitAnimations];        
//}



//- (void)nowPlayingAnimationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
//{
//    [_trackInteractionView removeFromSuperview];
//    [_trackInteractionView release];
//    _trackInteractionView = nil;
//}





//.................................................................................................
//
// MESSAGES
//

- (void)addMessage
{
    NSInteger index = _wallEvents.count - 1;

    WallEvent* ev = [_wallEvents objectAtIndex:index];
    [ev computeTextHeightUsingFont:_messageFont withConstraint:270];
    
    UITableViewRowAnimation anim = UITableViewRowAnimationNone;
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:anim];
}
     

- (void)addSong
{
    NSInteger index = _wallEvents.count - 1;

    UITableViewRowAnimation anim = UITableViewRowAnimationNone;
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:anim];
}




- (void)insertMessage
{
    NSInteger index = 0;
    
    WallEvent* ev = [_wallEvents objectAtIndex:index];
    [ev computeTextHeightUsingFont:_messageFont withConstraint:270];
    
    UITableViewRowAnimation anim = UITableViewRowAnimationTop;
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:anim];
}


- (void)insertSong
{
    NSInteger index = 0;

    WallEvent* ev = [_wallEvents objectAtIndex:index];
    UITableViewRowAnimation anim = UITableViewRowAnimationTop;
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:anim];
}

- (NSIndexPath *)usersContainerWillSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  return nil;
}


- (void*)usersContainerWillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}



- (NSInteger)numberOfSectionsInUsersContainer
{
  return 1;
}

- (NSInteger)usersContainerNumberOfRowsInSection:(NSInteger)section
{
  return _connectedUsers.count;
}

- (CGFloat)usersContainerWidthForRowAtIndexPath:(NSIndexPath *)indexPath
{
  BundleStylesheet* nameSheet = [[Theme theme] stylesheetForKey:@"StatusBarUserName" retainStylesheet:YES overwriteStylesheet:NO error:nil];
  CGRect nameRect = nameSheet.frame;
  return nameRect.size.width + 2 * USER_VIEW_CELL_BORDER;
}

- (UITableViewCell*)usersContainerCellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  NSString* cellIdentifier = @"UserViewCell";
  UserViewCell* cell = [_usersContainer dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil)
  {
    cell = [[[UserViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
  }
  cell.user = [_connectedUsers objectAtIndex:indexPath.row];
  return cell;
}


//.................................................................................................
//
// TABLE VIEW DELEGATE
//

#pragma mark - TableView Source and Delegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  if (tableView == _usersContainer)
    return [self usersContainerWillSelectRowAtIndexPath:indexPath];
  
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (tableView == _usersContainer)
    [self usersContainerWillDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if (tableView == _usersContainer)
    return [self numberOfSectionsInUsersContainer];
  
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  if (tableView == _usersContainer)
    return [self usersContainerNumberOfRowsInSection:section];
  
  
  return [_wallEvents count];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  if (tableView == _usersContainer)
    return [self usersContainerWidthForRowAtIndexPath:indexPath];
  
    WallEvent* ev = [_wallEvents objectAtIndex:indexPath.row];
    
    if ([ev.type isEqualToString:EV_TYPE_MESSAGE])
    {
        assert([ev isTextHeightComputed] == YES);
        
        CGFloat height = [ev getTextHeight];
        
        if ((height + THE_REST_OF_THE_CELL_HEIGHT) < _cellMinHeight)
        {
            return _cellMinHeight;
        }
        
        return (height + THE_REST_OF_THE_CELL_HEIGHT);
    }
    else if ([ev.type isEqualToString:EV_TYPE_SONG])
    {
        return ROW_SONG_HEIGHT;
    }
    else
    {
        assert(0);
    }

    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  if (tableView == _usersContainer)
    return [self usersContainerCellForRowAtIndexPath:indexPath];
  
    static NSString* CellIdentifier = @"RadioViewCell";
    
    WallEvent* ev = [_wallEvents objectAtIndex:indexPath.row];

    if ([ev.type isEqualToString:EV_TYPE_MESSAGE])
    {
        RadioViewCell* cell = [[[RadioViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier event:ev height:0 indexPath:indexPath] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if ([ev.type isEqualToString:EV_TYPE_SONG])
    {
        CGFloat height = 0; // unused

       SongViewCell* cell = [[[SongViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier event:ev height:height indexPath:indexPath] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        assert(0);
        return nil;
    }
    
    return nil;
}








//..........................................................................................................
//
// STATUS BAR
//
//

#pragma mark - Status Bar

- (void)setStatusMessage:(NSString*)message
{
    if (_statusBarButtonToggled)
        return;
    
    [self cleanStatusMessages];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = message;
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












//..........................................................................................................
//
// TEXTFIELD DELEGATE
//
//

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:TRUE];
    
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* cleanText = [textField.text stringByTrimmingCharactersInSet:space];
    if (cleanText.length == 0)
        return;
    
    [self sendMessage:textField.text];
    textField.text = nil;
    return FALSE;
}


- (void)sendMessage:(NSString *)message
{
    [[ActivityModelessSpinner main] addRef];
    [[YasoundDataProvider main] postWallMessage:message toRadio:self.radio target:self action:@selector(wallMessagePosted:withInfo:)];
}

- (void)wallMessagePosted:(NSString*)eventURL withInfo:(NSDictionary*)info
{
    [[ActivityModelessSpinner main] removeRef];

    NSError* error = [info valueForKey:@"error"];
    if (error)
    {
        NSLog(@"wall message can't be posted: %@", error.domain);
        return;
    }

    [self updateCurrentWall];
}
















//..........................................................................................................
//
// IBACTIONS
//
// [...], status bar button action
//

#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MENU object:nil];
}



- (IBAction)onFavorite:(id)sender
{
    [[ActivityModelessSpinner main] addRef];
    [[YasoundDataProvider main] favoriteRadiosWithGenre:nil withTarget:self action:@selector(onFavoritesRadioReceived:)];
}

- (void)onFavoritesRadioReceived:(NSArray*)radios
{
    NSInteger currentRadioId = [self.radio.id integerValue];
    
    for (Radio* radio in radios)
    {
        if ([radio.id integerValue] == currentRadioId)
        {
            [[ActivityModelessSpinner main] removeRef];
            [[YasoundDataProvider main] setRadio:self.radio asFavorite:NO];
            self.favoriteButton.selected = NO;
            [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_favorite_removed", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];
            return;
        }
    }
            
    [[ActivityModelessSpinner main] removeRef];
    [[YasoundDataProvider main] setRadio:self.radio asFavorite:YES];
    self.favoriteButton.selected = YES;

    [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioView_favorite_added", nil) closeAfterTimeInterval:ACTIVITYALERT_TIMEINTERVAL];
}



- (IBAction) onPlayPause:(id)sender
{
    if (!_playingNowView.playPauseButton.selected)
        [self pauseAudio];
    else
        [self playAudio];
}



- (void)onSwipeLeft:(UISwipeGestureRecognizer *)recognizer 
{ 
    CGPoint point = [recognizer locationInView:[self view]];
    NSLog(@"Swipe left - start location: %f,%f", point.x, point.y);
    
    if (_viewTracksDisplayed)
        return;
    
    NSError* error;
	if (![[GANTracker sharedTracker] trackEvent:@"swipe" action:@"Go to TracksView" label:nil value:0 withError:&error]) 
    {
		        NSLog(@"GANTracker Error tracking foreground event: %@", error);
	}
    
    [_viewTracks updateView];

    CGRect frame = _viewWall.frame;
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay: UIViewAnimationCurveEaseInOut];
    _viewWall.frame = CGRectMake(- frame.size.width, 0, frame.size.width, frame.size.height);
    _viewTracks.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [UIView commitAnimations];   
    
    _viewTracksDisplayed = YES;
    _pageControl.currentPage = 1;
}


- (void)onSwipeRight:(UISwipeGestureRecognizer *)recognizer 
{ 
    CGPoint point = [recognizer locationInView:[self view]];
    NSLog(@"Swipe right - start location: %f,%f", point.x, point.y);

    if (!_viewTracksDisplayed)
        return;

    NSError* error;
	if (![[GANTracker sharedTracker] trackEvent:@"swipe" action:@"Go back to RadioView" label:nil value:0 withError:&error]) 
    {
        NSLog(@"GANTracker Error tracking foreground event: %@", error);
	}
    
    CGRect frame = _viewWall.frame;
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay: UIViewAnimationCurveEaseInOut];
    _viewWall.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _viewTracks.frame = CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height);
    [UIView commitAnimations];   

    _viewTracksDisplayed = NO;
    _pageControl.currentPage = 0;
}













- (void)playAudio
{
    _playingNowView.playPauseButton.selected = NO;
    [[AudioStreamManager main] startRadio:self.radio];
}

- (void)pauseAudio
{
    _playingNowView.playPauseButton.selected = YES;
    
    [[AudioStreamManager main] stopRadio];
}


//- (IBAction) onSearch:(id)sender
//{
//    RadioTabBarController* tabBarController = [[RadioTabBarController alloc] init];
//    [self.navigationController pushViewController:tabBarController animated:YES];    
//}


- (IBAction)onStatusBarButtonClicked:(id)sender
{
    BundleStylesheet* sheet = nil;
    
    // downsize status bar : hide users
    if (_statusBarButtonToggled)
    {
        _statusBarButtonToggled = !_statusBarButtonToggled;

        sheet = [[Theme theme] stylesheetForKey:@"StatusBarButtonOff" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [_statusBarButton setImage:[sheet image] forState:UIControlStateNormal];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 0.15];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onStatusBarClosed:finished:context:)];
        
        _statusBar.frame = CGRectMake(_statusBar.frame.origin.x, _statusBar.frame.origin.y + _statusBar.frame.size.height/2, _statusBar.frame.size.width, _statusBar.frame.size.height);
        
        _pageControl.alpha = 1;
        _listenersIcon.alpha = 1;
        _listenersLabel.alpha = 1;
        
        [UIView commitAnimations];        
    }
    
    // upsize status bar : show users
    else
    {
        [self cleanStatusMessages];
        
        _statusBarButtonToggled = !_statusBarButtonToggled;

        sheet = [[Theme theme] stylesheetForKey:@"StatusBarButtonOn" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [_statusBarButton setImage:[sheet image] forState:UIControlStateNormal];
        
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarUserScrollView" retainStylesheet:YES overwriteStylesheet:NO error:nil];
      _usersContainer = [[OrientedTableView alloc] initWithFrame:sheet.frame];
      _usersContainer.orientedTableViewDataSource = self;
      _usersContainer.delegate = self;
      _usersContainer.tableViewOrientation = kTableViewOrientationHorizontal;
      _usersContainer.backgroundColor = [UIColor clearColor];
      _usersContainer.separatorColor = [UIColor clearColor];
      _usersContainer.separatorStyle = UITableViewCellSeparatorStyleNone;
      
      [_statusBar addSubview:_usersContainer];


        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 0.15];
        
        _statusBar.frame = CGRectMake(_statusBar.frame.origin.x, _statusBar.frame.origin.y - _statusBar.frame.size.height/2, _statusBar.frame.size.width, _statusBar.frame.size.height);
        _usersContainer.alpha = 1;
        
        _pageControl.alpha = 0;
        _listenersIcon.alpha = 0;
        _listenersLabel.alpha = 0;

        
        [UIView commitAnimations];        

    }
    
}


- (void)onStatusBarClosed:(NSString *)animationId finished:(BOOL)finished context:(void *)context 
{
  [_usersContainer removeFromSuperview];
  [_usersContainer release];
  _usersContainer = nil;

  
}






#pragma mark - Notifications

- (void)onAudioStreamNotif:(NSNotification *)notification
{
    if ([notification.name isEqualToString:NOTIF_AUDIOSTREAM_ERROR])
    {
        [self setStatusMessage:NSLocalizedString(@"RadioView_status_message_audiostream_error", nil)];
        
        // LBDEBUG TO BE COMPLETED
        _streamErrorCount++;
        //[[AudioStreamManager main] stopRadio];
        [[AudioStreamManager main] startRadio:self.radio];
        return;
    }
    else if ([notification.name isEqualToString:NOTIF_AUDIOSTREAM_PLAY])
    {
      [self playAudio];
      return;
    }
    else if ([notification.name isEqualToString:NOTIF_AUDIOSTREAM_STOP])
    {
      [self pauseAudio];
      return;
    }  
}







//#pragma mark -
//#pragma mark ScrollView Callbacks
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{	
////    NSLog(@"SCROLLVIEW frame %.2f,%.2f  %.2f x %.2f", scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
////    NSLog(@"SCROLLVIEW scrollView.contentOffset.y %.2f ", scrollView.contentOffset.y);
////    NSLog(@"SCROLLVIEW scrollView.contentSize.height %.2f ", scrollView.contentSize.height);
//
//    
//    if (!_updatingPrevious)
//        return;
//    
//    CGFloat posY = scrollView.frame.origin.y + (scrollView.contentOffset.y * (-1)) + scrollView.contentSize.height;
//    
//    if (_updatingPreviousIndicator == nil)
//    {
//        _updatingPreviousIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        [self.view addSubview:_updatingPreviousIndicator];
//        [_updatingPreviousIndicator startAnimating];
//        
//        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"UpdatingPreviousLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//        _updatingPreviousLabel = [sheet makeLabel];
//        _updatingPreviousLabel.text = NSLocalizedString(@"UpdatingPrevious_label", nil);
//        [self.view addSubview:_updatingPreviousLabel];
//    }
//
//    _updatingPreviousIndicator.frame = CGRectMake(60, posY+10, 22, 22);
//    _updatingPreviousLabel.frame = CGRectMake(160, posY+10, 150, 22);
//
////	if (scrollView.isDragging)
////    {
////        if (scrollView.contentOffset.y > -DRAGGABLE_HEIGHT && scrollView.contentOffset.y < 0.0f) 
////        {
////            self.draggableTableView.frame = CGRectMake(0,  -DRAGGABLE_HEIGHT - scrollView.contentOffset.y, self.draggableTableView.frame.size.width, self.draggableTableView.frame.size.height);
////        } 
////        else if (scrollView.contentOffset.y < -DRAGGABLE_HEIGHT) 
////        {
////        }
////	}
//}


#pragma mark Updating Previous

//
//- (void)show
//


@end








