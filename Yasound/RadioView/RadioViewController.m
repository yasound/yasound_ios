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
#import "YasoundAppDelegate.h"

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
#import "LikeViewCell.h"
#import "LoadingCell.h"

#import "ProfileViewController.h"
#import "ProfileMyRadioViewController.h"
#import "ShareModalViewController.h"
#import "ShareTwitterModalViewController.h"
#import "YasoundSessionManager.h"
#import "YasoundDataCache.h"

#import "SongInfoViewController.h"
#import "SongPublicInfoViewController.h"
#import "SongCatalog.h"


//#define LOCAL 1 // use localhost as the server

#define SERVER_DATA_REQUEST_TIMER 5.0f
#define ROW_SONG_HEIGHT 15
#define ROW_LIKE_HEIGHT 26

#define NB_MAX_EVENTMESSAGE 10

#define WALL_FIRSTREQUEST_FIRST_PAGESIZE 20
#define WALL_FIRSTREQUEST_SECOND_PAGESIZE 20

#define WALL_PREVIOUS_EVENTS_REQUEST_PAGESIZE 20

#define WALL_WAITING_ROW_HEIGHT 44

@implementation RadioViewController


static Song* _gNowPlayingSong = nil;



@synthesize radio;
//@synthesize messages;
@synthesize statusMessages;
@synthesize ownRadio;
@synthesize favoriteButton;
@synthesize playPauseButton;

- (id)initWithRadio:(Radio*)radio
{
    self = [super init];
    if (self) 
    {
        self.radio = radio;
        
        self.ownRadio = [[YasoundDataProvider main].user.id intValue] == [self.radio.creator.id intValue];

//        _trackInteractionViewDisplayed = NO;

        self.view.userInteractionEnabled = YES;

        _serverErrorCount = 0;
        _updatingPrevious = NO;
        _firstUpdateRequest = YES;
        _latestEvent = nil;
        _lastWallEvent = nil;
        _countMessageEvent = 0;
        _lastSongUpdateDate = nil;
        _favoritesButtonLocked = NO;

        self.statusMessages = [[NSMutableArray alloc] init];

        _statusBarButtonToggled = NO;

        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"CellMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _messageFont = [sheet makeFont];
        [_messageFont retain];

        _messageWidth = sheet.frame.size.width;

        sheet = [[Theme theme] stylesheetForKey:@"CellMinHeight" error:nil];
        _cellMinHeight = [[sheet.customProperties objectForKey:@"minHeight"] floatValue];

        _wallEvents = [[NSMutableArray alloc] init];
//        _wallEvents = nil;
        _waitingForPreviousEvents = NO;
        _connectedUsers = nil;
        _usersContainer = nil;
        _radioForSelectedUser = nil;
        
        _cellEditing = nil;
        
        _updateLock = [[NSLock alloc] init];
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
    
    _waitingForPreviousEvents = NO;
    
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
    [btn addTarget:self action:@selector(onAvatarClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    // "back to menu" button

    sheet = [[Theme theme] stylesheetForKey:@"HeaderMenuButton" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    btn = [sheet makeButton];
    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:btn];
    
    
    
    //....................................................................................
    //
    // header now playing bar
    //
    
    // header now playing bar image
    sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImageView* playingNowContainer = [[UIImageView alloc] initWithImage:[sheet image]];
    playingNowContainer.frame = sheet.frame;
    
    [self.view addSubview:playingNowContainer];

    _playingNowView = nil;
    
    // now playing bar is set in setNowPlaying;
  if (_gNowPlayingSong != nil)
  {
    [self setNowPlaying:_gNowPlayingSong];
  }
    

    
    //play pause button
    sheet = [[Theme theme] stylesheetForKey:@"PlayPauseButton" error:nil];
    frame = sheet.frame;
    self.playPauseButton = [sheet makeButton];
    [self.playPauseButton addTarget:self action:@selector(onPlayPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playPauseButton];
    
    self.playPauseButton.selected = YES;

    
    
    
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
    
    [_viewWall addSubview:messageBarView];   
    
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewMessageBar" error:nil];    
    _messageBar = [[UITextField alloc] initWithFrame:sheet.frame];
    _messageBar.delegate = self;
    [_messageBar setBorderStyle:UITextBorderStyleRoundedRect];
    [_messageBar setPlaceholder:NSLocalizedString(@"radioview_message", nil)];

    sheet = [[Theme theme] stylesheetForKey:@"RadioViewMessageBarFont" error:nil];
    [_messageBar setFont:[sheet makeFont]];

    [_viewWall addSubview:_messageBar];
    
    //....................................................................................
    //
    // table view
    //
    sheet = [[Theme theme] stylesheetForKey:@"TableView" error:nil];    
    _tableView = [[TouchedTableView alloc] initWithFrame:sheet.frame style:UITableViewStylePlain];

    _tableView.actionTouched = @selector(tableViewTouched:withEvent:);


    sheet = [[Theme theme] stylesheetForKey:@"WallBackground" error:nil];    
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
    
    sheet = [[Theme theme] stylesheetForKey:@"StatusBarButtonOff" error:nil];
  _statusBarButtonImage = [sheet makeImage];
  [_statusBar addSubview:_statusBarButtonImage];
  
  sheet = [[Theme theme] stylesheetForKey:@"StatusBarInteractiveView" error:nil];
  InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:sheet.frame target:self action:@selector(onStatusBarButtonClicked:)];
  [_statusBar addSubview:interactiveView];
  
    
    // headset image
    sheet = [[Theme theme] stylesheetForKey:@"StatusHeadSet" error:nil];
    _listenersIcon = [[UIImageView alloc] initWithImage:[sheet image]];
    _listenersIcon.frame = sheet.frame;
    [_statusBar addSubview:_listenersIcon];
    
    // listeners
    sheet = [[Theme theme] stylesheetForKey:@"StatusListeners" error:nil];
    _listenersLabel = [sheet makeLabel];
    _listenersLabel.text = [NSString stringWithFormat:@"%d", [self.radio.nb_current_users integerValue]];
    [_statusBar addSubview:_listenersLabel];
    
    
    
    
    
    
    
    
    
    //.......................................................................................................................................
    //
    // child view Tracks
    //
    
//    frameChild = CGRectMake(frameChild.size.width, frameChild.origin.y, frameChild.size.width, frameChild.size.height);
//    
//    _viewTracks = [[TracksView alloc] initWithFrame:frameChild];
//    [_viewTracks loadView];
//    _viewTracks.backgroundColor = [UIColor clearColor];
//    [_viewContainer addSubview:_viewTracks];
//    
//    _viewTracksDisplayed = NO;
    
    
    
    
    if (self.ownRadio)
    {
#if 0 // Disabled next track editing for first release (SM on 13/02).
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
#endif
    }
    
    
    // get the actual data from the server to update the GUI
    [self updatePreviousWall];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.playPauseButton.selected)
    {
        [[AudioStreamManager main] startRadio:self.radio];
        [[YasoundDataProvider main] enterRadioWall:self.radio];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_DISPLAY_AUDIOSTREAM_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_PLAY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_STOP object:nil];
   
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    // <=> background audio playing
    [self becomeFirstResponder];    
    
    // check for tutorial
    [[Tutorial main] show:TUTORIAL_KEY_RADIOVIEW everyTime:NO];

    // we don't do it for now, since we removed the TracksView from the scenario
//    if (self.ownRadio)
//        [[Tutorial main] show:TUTORIAL_KEY_TRACKSVIEW everyTime:NO];
    
    // update favorite button
    [[ActivityModelessSpinner main] addRef];
    

    
    NSDictionary* entry = [[YasoundDataCache main] menuEntry:MENU_ENTRY_ID_FAVORITES];
    NSString* url = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_URL forEntry:entry];
    [[YasoundDataCache main] requestRadiosWithUrl:[NSURL URLWithString:url] withGenre:nil target:self action:@selector(onFavoriteUpdate:)];
    
    // launch timer here, but only the the wall has been filled already.
    // otherwise, wait for it to be filled, and then, we will launch the update timer.
    if (!_firstUpdateRequest && ((_timerUpdate == nil) || (![_timerUpdate isValid])))
    {
        // launch the update timer
        _timerUpdate = [NSTimer scheduledTimerWithTimeInterval:SERVER_DATA_REQUEST_TIMER target:self selector:@selector(onTimerUpdate:) userInfo:nil repeats:YES];
    }
    
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
    [_updateLock release];
    
//    if (_ap != nil)
//        [_ap release];

    [super dealloc];
}


- (void)showWaitingEventRow
{
    if (_waitingForPreviousEvents)
        return;
    
    _waitingForPreviousEvents = YES;
    // #FIXME: todo...
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_wallEvents.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)removeWaitingEventRow
{
    if (!_waitingForPreviousEvents)
        return;
    
    _waitingForPreviousEvents = NO;
    // #FIXME: todo...
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_wallEvents.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}









//.................................................................................................
//
// DATA UPDATE
//


#pragma mark - Data 

//....................................................................
//
// onTimerUpdate
//
// timer callback to call for updates from server
//

- (void)onTimerUpdate:(NSTimer*)timer
{    
//    if (_ap != nil)
//        [_ap release];
//    
//    _ap = [[NSAutoreleasePool alloc] init];
    
    if ([_updateLock tryLock])
    {
        if (_wallEvents.count > 0)
        {
            NSNumber* newestEventID = ((WallEvent*)[_wallEvents objectAtIndex:0]).id;
            [[YasoundDataProvider main] wallEventsForRadio:self.radio newerThanEventWithID:newestEventID target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
        }
        else
            [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:25 target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
    
        [[YasoundDataProvider main] currentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
        [[YasoundDataProvider main] radioWithId:self.radio.id target:self action:@selector(receiveRadio:withInfo:)];
        [[YasoundDataProvider main] currentUsersForRadio:self.radio target:self action:@selector(receivedCurrentUsers:withInfo:)];

        [_updateLock unlock];
    }

}

- (void)updatePreviousWall
{    
    _updatingPrevious = YES;

    [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_FIRSTREQUEST_FIRST_PAGESIZE target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
    
    [[YasoundDataProvider main] currentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
    [[YasoundDataProvider main] radioWithId:self.radio.id target:self action:@selector(receiveRadio:withInfo:)];
}

- (void)updateCurrentWall
{    
    if (_wallEvents.count > 0)
    {
        NSNumber* newestEventID = ((WallEvent*)[_wallEvents objectAtIndex:0]).id;
        [[YasoundDataProvider main] wallEventsForRadio:self.radio newerThanEventWithID:newestEventID target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
    }
    else
        [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:25 target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
}








- (void)logWallEvents
{
    int i = 0;
    for (WallEvent* w in _wallEvents)
    {
      NSLog(@"(%d) -%@- %@", i, w.type, [w isOfType:eWallEventTypeMessage]  ? w.text : w.song_name);
        i++;
    }
}

- (int)eventMessageCount
{
    int count = 0;
    for (WallEvent* w in _wallEvents)
    {
        if ([w isOfType:eWallEventTypeMessage])
            count++;
    }
    return count;
}

- (int)eventSongCount
{
    int count = 0;
    for (WallEvent* w in _wallEvents)
    {
        if ([w isOfType:eWallEventTypeSong])
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
    [self removeWaitingEventRow];
    
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
        // NSLog(@"NO MORE EVENTS. end receivedPreviousWallEvents\n");
        
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
        if ([ev isOfType:eWallEventTypeSong])
            [self receivedPreviousSongEvent:ev];
        else if ([ev isOfType:eWallEventTypeMessage])
        {
            [self receivedPreviousMessageEvent:ev];
            _countMessageEvent++;
        }
        else if ([ev isOfType:eWallEventTypeLike])
          [self receivedPreviousLikeEvent:ev];
        
    }

    NSInteger count = events.count;

    // update _latestEvent
    
    WallEvent* ev = [events objectAtIndex:0];
    WallEvent* wev = nil;
    
    if (_wallEvents.count > 0)
        wev = [_wallEvents objectAtIndex:0];
    
    NSLog(@"first event is %@ : %@", [ev wallEventTypeString], ev.start_date);
    
    if (wev != nil)
        NSLog(@"first wallevent is %@ : %@", [wev wallEventTypeString], wev.start_date);

    if ((wev != nil) && [wev.start_date isLaterThan:ev.start_date])
        _latestEvent = wev;
    else
        _latestEvent = ev;    

    NSLog(@"_latestEvent is %@ : %@", [_latestEvent wallEventTypeString], _latestEvent.start_date);
    NSLog(@"_lastWallEvent is %@ : %@", [_lastWallEvent wallEventTypeString], _lastWallEvent.start_date);

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
        [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_FIRSTREQUEST_SECOND_PAGESIZE olderThanEventWithID:_lastWallEvent.id target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
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

- (void)receivedPreviousLikeEvent:(WallEvent*)ev
{
  // update lastWallEvent
  if ([ev.start_date isEarlierThanOrEqualTo:_lastWallEvent.start_date])
    _lastWallEvent = ev;
  
  [_wallEvents addObject:ev];
  [self addLike];
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
        //NSLog(@"NO MORE EVENTS. end receivedCurrentWallEvents\n");
        return;
    }
    
    
    NSLog(@"\nreceivedCurrentWallEvents %d events", events.count);
  
  for (int i = events.count - 1; i >= 0; i--)
    {
      WallEvent* ev = [events objectAtIndex:i];        
      if ([ev isOfType:eWallEventTypeSong])
            [self receivedCurrentSongEvent:ev];
      else if ([ev isOfType:eWallEventTypeMessage])
      {
          [self receivedCurrentMessageEvent:ev];
          _countMessageEvent++;
      }
      else if ([ev isOfType:eWallEventTypeLike])
        [self receivedCurrentLikeEvent:ev];
        
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
        
        NSLog(@"first event is %@ : %@", [ev wallEventTypeString], ev.start_date);
        if (wev != nil)
            NSLog(@"first wallevent is %@ : %@", [wev wallEventTypeString], wev.start_date);
        
        if ((wev != nil) && [wev.start_date isLaterThan:ev.start_date])
            _latestEvent = wev;
        else
            _latestEvent = ev;
        
        
        NSLog(@"_latestEvent is %@ : %@", [_latestEvent wallEventTypeString], _latestEvent.start_date);
    }
    else
        return;
    
    NSLog(@"end receivedCurrentWAllEvents\n");
}


- (void)receivedCurrentSongEvent:(WallEvent*)ev
{
    if ((_latestEvent != nil) && ([ev.start_date isEarlierThanOrEqualTo:_latestEvent.start_date]))
        return;
    
    assert(ev != nil);
    
  [_wallEvents insertObject:ev atIndex:0];
  [self insertSong];
}


-(void)playSound
{
  return;
  //Get the filename of the sound file:
  NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/beeps/.wav"];
  
  //declare a system sound
  SystemSoundID soundID;
  
  //Get a URL for the sound file
  NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
  
  //Use audio sevices to create the sound
  AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
  //Use audio services to play the sound
  AudioServicesPlaySystemSound(soundID);
}

- (void)receivedCurrentMessageEvent:(WallEvent*)ev
{
    if ((_latestEvent != nil) && ([ev.start_date isEarlierThanOrEqualTo:_latestEvent.start_date]))
        return;
    
    NSLog(@"receivedCurrentMessageEvent ADD %@ : date %@", ev.user_name, ev.start_date);

    assert(ev != nil);
    
    [_wallEvents insertObject:ev atIndex:0];
    [self insertMessage];
  [self playSound];
}

- (void)receivedCurrentLikeEvent:(WallEvent*)ev
{
  if ((_latestEvent != nil) && ([ev.start_date isEarlierThanOrEqualTo:_latestEvent.start_date]))
    return;
    
    assert(ev != nil);
  
  [_wallEvents insertObject:ev atIndex:0];
  [self insertLike];
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
    _listenersLabel.text = [NSString stringWithFormat:@"%d", [self.radio.nb_current_users integerValue]];
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

- (void)receivedCurrentUsers:(NSArray*)users withInfo:(NSDictionary*)info
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
    
    if (_playingNowView != nil)
    {
        [_playingNowView removeFromSuperview];
        [_playingNowView release];
    }
    
    _playingNowView = [[NowPlayingView alloc] initWithSong:_gNowPlayingSong];
    
    InteractiveView* trackImageButton = [[InteractiveView alloc] initWithFrame:CGRectMake(15, 6, 50, 50) target:self action:@selector(onTrackImageClicked:)];
    [trackImageButton addTargetOnTouchDown:self action:@selector(onTrackImageTouchDown:)];
    [_playingNowView addSubview:trackImageButton];
    [trackImageButton release];

    
    [_playingNowView.trackInteractionView.shareButton addTarget:self action:@selector(onTrackShare:) forControlEvents:UIControlEventTouchUpInside];

    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _playingNowView.frame = sheet.frame;
    
    [self.view addSubview:_playingNowView];
    [self.view bringSubviewToFront:self.playPauseButton];
}




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

- (void)addLike
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

- (void)insertLike
{
  NSInteger index = 0;
  
  UITableViewRowAnimation anim = UITableViewRowAnimationTop;
  [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:anim];
}









#pragma mark - User list

- (NSIndexPath *)usersContainerDidSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell* cell = [_usersContainer cellForRowAtIndexPath:indexPath];
    cell.selected = NO;

    User* user = [_connectedUsers objectAtIndex:indexPath.row];
    
    // Launch profile view
    ProfileViewController* view = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil user:user];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
//    [user release];
    
    return nil;
}


- (void)usersContainerWillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UIView* view = [[UIView alloc] initWithFrame:cell.frame];
//    view.backgroundColor = [UIColor redColor];
//    
//    CGFloat width = cell.frame.size.width;
//    
//    UIView* selection = [[UIView alloc] initWithFrame:CGRectMake(0, 12, width, 58)];
//    selection.backgroundColor = [UIColor blueColor];
//    [view addSubview:selection];
//
//    cell.selectedBackgroundView = view;
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
    
    
    CGFloat width = cell.frame.size.width;

    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ListenerSelectedBackground.png"]];
    view.frame = CGRectMake(0, 12, width, 58);
    cell.selectedBackgroundView = view;
    
  return cell;
}






- (void)receivedRadioForSelectedUser:(Radio*)r withInfo:(NSDictionary*)info
{
  if (!r)
    return;
  if (![r.ready boolValue])
  {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:r.creator.name message:NSLocalizedString(@"GoTo_CurrentUser_Radio_Unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"GoTo_CurrentUser_Radio_Unavailable_OkButton_Title", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    return;
  }
  
  NSLog(@"radio '%@'   creator '%@'", r.name, r.creator.name);
  _radioForSelectedUser = r;
  
  NSString* s = NSLocalizedString(@"GoTo_CurrentUser_Radio", nil);
  NSString* msg = [NSString stringWithFormat:s, _radioForSelectedUser.name];
  _alertGoToRadio = [[UIAlertView alloc] initWithTitle:r.creator.name message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"GoTo_CurrentUser_Radio_CancelButton_Title", nil) otherButtonTitles:NSLocalizedString(@"GoTo_CurrentUser_Radio_OkButton_Title", nil), nil];
  [_alertGoToRadio show];
  [_alertGoToRadio release];
  
  
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertGoToRadio)
    {
        if (buttonIndex == 0)
        {
            // cancel
            NSLog(@"don't go to radio");
        }
        else if (buttonIndex == 1)
        {
            NSLog(@"go to %@ - %@", _radioForSelectedUser.name, _radioForSelectedUser.id);
            RadioViewController* view = [[RadioViewController alloc] initWithRadio:_radioForSelectedUser];
            [self.navigationController pushViewController:view animated:YES];
            [view release]; 

            _radioForSelectedUser = nil;
        }
    }
    
    else if (alertView == _alertGoToLogin)
    {
        if (buttonIndex == 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_SCREEN object:nil];
            return;
        }
    }
}


//.................................................................................................
//
// TABLE VIEW DELEGATE
//

#pragma mark - TableView Source and Delegate


- (NSIndexPath *)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView == _usersContainer)
    {
        return [self usersContainerDidSelectRowAtIndexPath:indexPath];
    } 

    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _usersContainer)
    {
        [self usersContainerWillDisplayCell:cell forRowAtIndexPath:indexPath];
        return;
    }
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
  
    NSInteger nbRows = [_wallEvents count];
    if (_waitingForPreviousEvents)
        nbRows++;
    return nbRows;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  if (tableView == _usersContainer)
    return [self usersContainerWidthForRowAtIndexPath:indexPath];
    
    if (_waitingForPreviousEvents && indexPath.row == _wallEvents.count)
        return WALL_WAITING_ROW_HEIGHT;
  
    WallEvent* ev = [_wallEvents objectAtIndex:indexPath.row];
    
    if ([ev isOfType:eWallEventTypeMessage])
    {
        assert([ev isTextHeightComputed] == YES);
        
        CGFloat height = [ev getTextHeight];
        
        if ((height + THE_REST_OF_THE_CELL_HEIGHT) < _cellMinHeight)
        {
            return _cellMinHeight;
        }
        
        return (height + THE_REST_OF_THE_CELL_HEIGHT);
    }
    else if ([ev isOfType:eWallEventTypeSong])
    {
        return ROW_SONG_HEIGHT;
    }
    else if ([ev isOfType:eWallEventTypeLike])
    {
      return ROW_LIKE_HEIGHT;
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
    
    // waiting cell
    if (_waitingForPreviousEvents && indexPath.row == _wallEvents.count)
    {
        static NSString* LoadingCellIdentifier = @"RadioViewLoadingCell";
        
        LoadingCell* cell = (LoadingCell*)[tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
        if (cell == nil)
        {
            cell = [[[LoadingCell alloc] initWithFrame:CGRectZero reuseIdentifier:LoadingCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;            
        }
        return cell;
    }
  
    
    WallEvent* ev = [_wallEvents objectAtIndex:indexPath.row];

    if ([ev isOfType:eWallEventTypeMessage])
    {
        static NSString* CellIdentifier = @"RadioViewMessageCell";
        
        RadioViewCell* cell = (RadioViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
//            cell = [[[RadioViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier event:ev indexPath:indexPath target:self action:@selector(onAvatarClickedInWall:)] autorelease];
            cell = [[[RadioViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier ownRadio:self.ownRadio event:ev indexPath:indexPath] autorelease];
            cell.delegate = self;
            cell.actionAvatarClick = @selector(onCellAvatarClick:);
            cell.actionEditing = @selector(onCellEditing:editing:);
            cell.actionDelete = @selector(onCellDelete:);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
        else
            [cell update:ev indexPath:indexPath];
        return cell;
    }
    else if ([ev isOfType:eWallEventTypeSong])
    {
        static NSString* CellIdentifier = @"RadioViewSongCell";
        CGFloat height = 0; // unused

        SongViewCell* cell = (SongViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[SongViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier event:ev height:height indexPath:indexPath] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
            [cell update:ev height:height indexPath:indexPath];
        
        return cell;
    }
    else if ([ev isOfType:eWallEventTypeLike])
    {
        static NSString* CellIdentifier = @"RadioViewLikeCell";
        CGFloat height = ROW_LIKE_HEIGHT;
      
        LikeViewCell* cell = (LikeViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[LikeViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier event:ev height:height indexPath:indexPath] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
            [cell update:ev height:height indexPath:indexPath];
        
      return cell;
    }
    else
    {
        assert(0);
        return nil;
    }
    
    return nil;
}


- (void)askForPreviousEvents
{
    NSLog(@"ask for previous events");
    if (_waitingForPreviousEvents)
        return;
    
    if (_wallEvents.count > 0)
    {
        NSNumber* lastEventID = ((WallEvent*)[_wallEvents objectAtIndex:_wallEvents.count - 1]).id;
        [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_PREVIOUS_EVENTS_REQUEST_PAGESIZE olderThanEventWithID:lastEventID target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
    }
    else
        [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_PREVIOUS_EVENTS_REQUEST_PAGESIZE target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
    
    [self showWaitingEventRow];
}


#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_waitingForPreviousEvents)
    {
        float offset = scrollView.contentOffset.y;
        float contentHeight = scrollView.contentSize.height;
        float viewHeight = scrollView.bounds.size.height;
        
        if (offset + viewHeight > contentHeight + WALL_WAITING_ROW_HEIGHT)
        {
            [self askForPreviousEvents];
        }
    }
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField != _messageBar)
        return NO;
    
    if ([YasoundSessionManager main].registered)
        return YES;
    
    _alertGoToLogin = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RadioView_goToLogin_title", nil) message:NSLocalizedString(@"RadioView_goToLogin_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_cancel", nil) otherButtonTitles:NSLocalizedString(@"Navigation_OK", nil),nil];
    [_alertGoToLogin show];
    [_alertGoToLogin release];
    
    return NO;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:TRUE];
    
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* cleanText = [textField.text stringByTrimmingCharactersInSet:space];
    if (cleanText.length == 0)
        return FALSE;
    
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
    // I need to check something... 
    YasoundAppDelegate* appDelegate = (YasoundAppDelegate*)[[UIApplication sharedApplication] delegate];
    UINavigationController* appController = appDelegate.navigationController;
    UINavigationController* thisController = self.navigationController;
    
     
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAvatarClicked:(id)sender
{
    if (self.radio.creator) 
    {
        if (self.ownRadio)
        {
            ProfileMyRadioViewController* view = [[ProfileMyRadioViewController alloc] initWithNibName:@"ProfileMyRadioViewController" bundle:nil radio:self.radio];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
        else
        {
            ProfileViewController* view = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil user:self.radio.creator];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
    }
}

- (void)onCellAvatarClick:(RadioViewCell*)cell
{
//    InteractiveView *btn = (InteractiveView *)sender;
//    id parent = [btn superview];
//    id gparent = [parent superview];
//    id ggparent = [gparent superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    WallEvent *event = [_wallEvents objectAtIndex:indexPath.row];
    if (event != nil && event.user_id != nil) 
    {
        // Build fake user object with given id
        User *user = [[User alloc] init];
        user.id = event.user_id;
        
        // Launch profile view
        ProfileViewController* view = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil user:user];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        [user release];
    }
}


- (void)onCellEditing:(RadioViewCell*)cell editing:(NSNumber*)nbEditing
{
    BOOL editing = [nbEditing boolValue];

    if (editing)
    {
        // one editing cell at a time
        if (_cellEditing != nil)
        {
            [_cellEditing deactivateEditModeAnimated:YES silent:YES];
            _cellEditing = nil;
        }

        _cellEditing = cell;
    }
    else
        _cellEditing = nil;
    
}


- (void)onCellDelete:(RadioViewCell*)cell 
{
    [_updateLock lock];
    {
        [_wallEvents removeObject:cell.wallEvent];
        
        if (_cellEditing != nil)
        {
            [_cellEditing deactivateEditModeAnimated:YES silent:YES];
            _cellEditing = nil;
        }
        
        NSIndexPath* indexPath = [_tableView indexPathForCell:cell];
        
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    [_updateLock unlock];
}



- (IBAction)onTrackImageTouchDown:(id)sender
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarMaskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [_playingNowView.trackImageMask setImage:[sheet image]];
}


- (IBAction)onTrackImageClicked:(id)sender
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    [_playingNowView.trackImageMask setImage:[sheet image]];
    
    if (_gNowPlayingSong.isSongRemoved)
        return;
    
    if (self.ownRadio)
    {
        SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:_gNowPlayingSong showNowPlaying:NO];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        SongPublicInfoViewController* view = [[SongPublicInfoViewController alloc] initWithNibName:@"SongPublicInfoViewController" bundle:nil song:_gNowPlayingSong onRadio:self.radio showNowPlaying:NO];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
}


- (IBAction)onFavorite:(id)sender
{
    if (_favoritesButtonLocked)
        return;
    
    _favoritesButtonLocked = YES;
    
    [[ActivityModelessSpinner main] addRef];
    
    // update the local GUI in advance, and then send the request, and wait for the delayed update
    self.favoriteButton.selected = !self.favoriteButton.selected;
    NSInteger nbFavorites = [_favoritesLabel.text integerValue];
    if (self.favoriteButton.selected)
        nbFavorites++;
    else
        nbFavorites--;
    
    _favoritesLabel.text = [NSString stringWithFormat:@"%d", nbFavorites];
    
    // send online request
    NSDictionary* entry = [[YasoundDataCache main] menuEntry:MENU_ENTRY_ID_FAVORITES];
    NSString* url = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_URL forEntry:entry];
    [[YasoundDataCache main] requestRadiosWithUrl:[NSURL URLWithString:url] withGenre:nil target:self action:@selector(onFavoritesRadioReceived:)];
    
    
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

            // and clear the cache for favorites
            NSDictionary* entry = [[YasoundDataCache main] menuEntry:MENU_ENTRY_ID_FAVORITES];
            NSString* url = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_URL forEntry:entry];
            [[YasoundDataCache main] clearRadios:url];

            _favoritesButtonLocked = NO;
            return;
        }
    }
            
    [[ActivityModelessSpinner main] removeRef];
    [[YasoundDataProvider main] setRadio:self.radio asFavorite:YES];
    self.favoriteButton.selected = YES;
    _favoritesButtonLocked = NO;
}



- (IBAction) onPlayPause:(id)sender
{
    if (self.playPauseButton.selected)
    {
        [self pauseAudio];
    }
    else
    {
        [self playAudio];
    }
}



//- (void)onSwipeLeft:(UISwipeGestureRecognizer *)recognizer 
//{ 
//    CGPoint point = [recognizer locationInView:[self view]];
//    NSLog(@"Swipe left - start location: %f,%f", point.x, point.y);
//    
//    if (_viewTracksDisplayed)
//        return;
//    
//    NSError* error;
//	if (![[GANTracker sharedTracker] trackEvent:@"swipe" action:@"Go to TracksView" label:nil value:0 withError:&error]) 
//    {
//		        NSLog(@"GANTracker Error tracking foreground event: %@", error);
//	}
//    
//    [_viewTracks updateView];
//
//    CGRect frame = _viewWall.frame;
//    
//    [UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:0.3];
//    [UIView setAnimationDelay: UIViewAnimationCurveEaseInOut];
//    _viewWall.frame = CGRectMake(- frame.size.width, 0, frame.size.width, frame.size.height);
//    _viewTracks.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    [UIView commitAnimations];   
//    
//    _viewTracksDisplayed = YES;
//    _pageControl.currentPage = 1;
//}
//
//
//- (void)onSwipeRight:(UISwipeGestureRecognizer *)recognizer 
//{ 
//    CGPoint point = [recognizer locationInView:[self view]];
//    NSLog(@"Swipe right - start location: %f,%f", point.x, point.y);
//
//    if (!_viewTracksDisplayed)
//        return;
//
//    NSError* error;
//	if (![[GANTracker sharedTracker] trackEvent:@"swipe" action:@"Go back to RadioView" label:nil value:0 withError:&error]) 
//    {
//        NSLog(@"GANTracker Error tracking foreground event: %@", error);
//	}
//    
//    CGRect frame = _viewWall.frame;
//    
//    [UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:0.3];
//    [UIView setAnimationDelay: UIViewAnimationCurveEaseInOut];
//    _viewWall.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    _viewTracks.frame = CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height);
//    [UIView commitAnimations];   
//
//    _viewTracksDisplayed = NO;
//    _pageControl.currentPage = 0;
//}













- (void)playAudio
{
    self.playPauseButton.selected = YES;
    [[AudioStreamManager main] startRadio:self.radio];
}

- (void)pauseAudio
{
    self.playPauseButton.selected = NO;
    
    [[AudioStreamManager main] stopRadio];
}




- (IBAction)onStatusBarButtonClicked:(id)sender
{
    BundleStylesheet* sheet = nil;
    
    // downsize status bar : hide users
    if (_statusBarButtonToggled)
    {
        _statusBarButtonToggled = !_statusBarButtonToggled;

        sheet = [[Theme theme] stylesheetForKey:@"StatusBarButtonOff" retainStylesheet:YES overwriteStylesheet:NO error:nil];
      [_statusBarButtonImage setImage:[sheet image]];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 0.15];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onStatusBarClosed:finished:context:)];
        
      _statusBarButtonImage.frame = sheet.frame;
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

        BundleStylesheet* buttonImageSheet = [[Theme theme] stylesheetForKey:@"StatusBarButtonOn" retainStylesheet:YES overwriteStylesheet:NO error:nil];
      [_statusBarButtonImage setImage:[buttonImageSheet image]];
        
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
        
      _statusBarButtonImage.frame = buttonImageSheet.frame;
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
    [UIView setAnimationDelegate:nil];
  [_usersContainer removeFromSuperview];
  [_usersContainer release];
  _usersContainer = nil;

  
}



- (void)onTrackShare:(id)sender
{
    _queryShare = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_saveOrCancel_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
        [_queryShare addButtonWithTitle:@"Facebook"];
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
        [_queryShare addButtonWithTitle:@"Twitter"];
    
    [_queryShare addButtonWithTitle:NSLocalizedString(@"ShareModalView_email_label", nil)];
    
    _queryShare.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [_queryShare showInView:self.view];

}


#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{

    // share query result
    if (actionSheet == _queryShare)
    {
        NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

        if ([buttonTitle isEqualToString:@"Facebook"])
        {
            ShareModalViewController* view = [[ShareModalViewController alloc] initWithNibName:@"ShareModalViewController" bundle:nil forSong:_gNowPlayingSong onRadio:self.radio target:self action:@selector(onShareModalReturned)];
            [self.navigationController presentModalViewController:view animated:YES];
            [view release];
        }
        else if ([buttonTitle isEqualToString:@"Twitter"])

        {
            ShareTwitterModalViewController* view = [[ShareTwitterModalViewController alloc] initWithNibName:@"ShareTwitterModalViewController" bundle:nil forSong:_gNowPlayingSong onRadio:self.radio target:self action:@selector(onShareModalReturned)];
            [self.navigationController presentModalViewController:view animated:YES];
            [view release];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"ShareModalView_email_label", nil)])
        {
            [self shareWithMail];
        }
        
        return;
    }
}



- (void)onShareModalReturned
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}




- (void)shareWithMail
{
    NSString* message = NSLocalizedString(@"ShareModalView_share_message", nil);
    NSString* fullMessage = [NSString stringWithFormat:message, _gNowPlayingSong.name, _gNowPlayingSong.artist, self.radio.name];
    NSString* link = [APPDELEGATE getServerUrlWith:@"listen/%@"];
    NSURL* fullLink = [[NSURL alloc] initWithString:[NSString stringWithFormat:link, self.radio.uuid]];
    
    NSString* body = [NSString stringWithFormat:@"%@\n\n%@", fullMessage, [fullLink absoluteString]];

	MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setSubject: NSLocalizedString(@"Yasound_share", nil)];
    
    [mailViewController setMessageBody:body isHTML:NO];
    
	mailViewController.mailComposeDelegate = self;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
		mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
	}
#endif
	
	[self presentModalViewController:mailViewController animated:YES];
	[mailViewController release];

}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{	
	[self dismissModalViewControllerAnimated:YES];
	
	NSString *mailError = nil;
	
	switch (result) 
    {
		case MFMailComposeResultSent: 
        { 
            [[YasoundDataProvider main] radioHasBeenShared:self.radio with:@"email"];            
            break;
        }
		case MFMailComposeResultFailed: mailError = @"Failed sending media, please try again...";
			break;
		default:
			break;
	}	
}







#pragma mark - Notifications

- (void)onAudioStreamNotif:(NSNotification *)notification
{
    if ([notification.name isEqualToString:NOTIF_DISPLAY_AUDIOSTREAM_ERROR])
    {
        [self setStatusMessage:NSLocalizedString(@"RadioView_status_message_audiostream_error", nil)];
        NSLog(@"stream error notification");
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




#pragma makr - Touches

// one editing cell at a time

- (void)tableViewTouched:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_cellEditing != nil)
    {
        [_cellEditing deactivateEditModeAnimated:YES];
        _cellEditing = nil;
    }
}


// one editing cell at a time
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_cellEditing != nil)
    {
        [_cellEditing deactivateEditModeAnimated:YES];
        _cellEditing = nil;
    }    
}








@end








