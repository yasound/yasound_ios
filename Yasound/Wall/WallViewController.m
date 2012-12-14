//
//  WallViewController.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WallViewController.h"
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
#import "AudioStreamManager.h"
#import "RootViewController.h"

#import "User.h"
#import "DateAdditions.h"
#import "GANTracker.h"

#import "UserViewCell.h"
#import "LikeViewCell.h"
#import "LoadingCell.h"

#import "ProfilViewController.h"
#import "ShareModalViewController.h"
#import "ShareTwitterModalViewController.h"
#import "YasoundSessionManager.h"
#import "YasoundDataCache.h"

#import "SongInfoViewController.h"
#import "SongPublicInfoViewController.h"
#import "SongCatalog.h"
#import "WallViewController+NowPlayingBar.h"
#import "SettingsViewController.h"
#import "ProgrammingViewController.h"
#import "MessageBroadcastModalViewController.h"

//#define LOCAL 1 // use localhost as the server

#define SERVER_DATA_REQUEST_TIMER 5.0f
#define ROW_SONG_HEIGHT 33
#define ROW_LIKE_HEIGHT 33

#define NB_MAX_EVENTMESSAGE 10

#define WALL_FIRSTREQUEST_FIRST_PAGESIZE 20
#define WALL_FIRSTREQUEST_SECOND_PAGESIZE 20

#define WALL_PREVIOUS_EVENTS_REQUEST_PAGESIZE 20

#define WALL_WAITING_ROW_HEIGHT 44
#define HEADER_HEIGHT 166
#define POST_BAR_HEIGHT 51

#define NB_SECTIONS 2

#define SECTION_HEADER 0
#define ROW_HEADER 0
#define ROW_POST_BAR 1
#define SECTION_EVENTS 1

#define MESSAGE_WIDTH 248

@implementation WallViewController





@synthesize radio;
@synthesize statusMessages;
@synthesize ownRadio;

@synthesize keyboardShown;

@synthesize nowPlayingScrollview;
@synthesize nowPlayingTrackImage;
@synthesize nowPlayingMask;
@synthesize nowPlayingButton;
@synthesize nowPlayingLabel1;
@synthesize nowPlayingLabel2;
@synthesize nowPlayingShare;
@synthesize nowPlayingLike;
@synthesize nowPlayingBuy;


@synthesize tableview;
@synthesize cellWallHeader;


@synthesize cellPostBar;
@synthesize fixedCellPostBar;



- (id)initWithRadio:(YaRadio*)aRadio
{
    self = [super init];
    if (self)
    {
        self.radio = aRadio;
        
        self.keyboardShown = NO;
        _stopWall = NO;
        
        self.ownRadio = NO;
        if ([YasoundSessionManager main].registered)
            self.ownRadio = [[YasoundDataProvider user_id] isEqualToNumber:self.radio.creator.id];
        
        self.view.userInteractionEnabled = YES;
        
        _serverErrorCount = 0;
        _updatingPrevious = NO;
        _firstUpdateRequest = YES;
        _latestEvent = nil;
        _lastWallEvent = nil;
        _countMessageEvent = 0;
        _lastSongUpdateDate = nil;
        
        self.statusMessages = [[NSMutableArray alloc] init];
        
        _statusBarButtonToggled = NO;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.message" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _messageFont = [sheet makeFont];
        [_messageFont retain];
        
        _messageWidth = sheet.frame.size.width;
        
        sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.minHeight" error:nil];
        _cellMinHeight = [[sheet.customProperties objectForKey:@"minHeight"] floatValue];
        
        _wallEvents = [[NSMutableArray alloc] init];
        _waitingForPreviousEvents = NO;
        
        _cellEditing = nil;
        
        _updateLock = [[NSLock alloc] init];
        
//        _socketIO = nil;
        _pushServerOk = NO;
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
    
    BOOL enableSettings = self.ownRadio;
    [self.topBar showSettingsItem:enableSettings];
    
    _waitingForPreviousEvents = NO;
    
    self.fixedCellPostBar.frame = CGRectMake(self.fixedCellPostBar.frame.origin.x, self.tableview.frame.origin.y, self.fixedCellPostBar.frame.size.width, self.fixedCellPostBar.frame.size.height);

    // table view
    self.tableview.actionTouched = @selector(tableViewTouched:withEvent:);
    
    // now playing bar
    self.nowPlayingScrollview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nowPlayingBkg.png"]];
    self.nowPlayingScrollview.contentSize = CGSizeMake(500,  self.nowPlayingScrollview.contentSize.height);
    

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.minHeight" error:nil];
    self.tableview.rowHeight = [[sheet.customProperties objectForKey:@"minHeight"] integerValue];
    
    [self setPause:[AudioStreamManager main].isPaused];

    // get the actual data from the server to update the GUI
    [self updatePreviousWall];
    
    
    
    if (![AudioStreamManager main].isPaused)
    {
        [[AudioStreamManager main] startRadio:self.radio];
    }
    else
        [AudioStreamManager main].currentRadio = self.radio;
    
    [[YasoundDataProvider main] enterRadioWall:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"enter wall error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"enter wall error: response status %d", status);
            return;
        }
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_DISPLAY_AUDIOSTREAM_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_PLAY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_STOP object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    // <=> background audio playing
    [self becomeFirstResponder];
    
    // check for tutorial
    [[Tutorial main] show:TUTORIAL_KEY_RADIOVIEW everyTime:NO];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.cellWallHeader setHeaderRadio:self.radio];


    // launch timer here, but only the the wall has been filled already.
    // otherwise, wait for it to be filled, and then, we will launch the update timer.
    if (!_firstUpdateRequest && ((_timerUpdate == nil) || (![_timerUpdate isValid])))
    {
        // launch the update timer
        _timerUpdate = [NSTimer scheduledTimerWithTimeInterval:SERVER_DATA_REQUEST_TIMER target:self selector:@selector(onTimerUpdate:) userInfo:nil repeats:YES];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REFRESH_GUI object:nil];
    
    // connect to push server
    NSString* pushHost;
#if USE_YASOUND_LOCAL_SERVER
    pushHost = @"localhost";
#else
    NSArray* components = [APPDELEGATE.serverURL componentsSeparatedByString:@"://"];
    if (components.count == 2)
    {
        pushHost = [components objectAtIndex:1];
        if ([pushHost hasSuffix:@"/"])
            pushHost = [pushHost substringToIndex:pushHost.length - 1];
    }
#endif
//    DLog(@"socketIO host: %@", pushHost);
//    _socketIO = [[SocketIO alloc] initWithDelegate:self];
//    [_socketIO connectToHost:pushHost onPort:9000 withParams:nil withNamespace:@"/radio"];
    
    PushManager* manager = [PushManager main];
    [manager subscribeToRadio:self.radio.id delegate:self];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    // close push server connection
    [[PushManager main] unsubscribeFromRadio:self.radio.id delegate:self];
//    if (_socketIO)
//    {
//        [_socketIO disconnect];
////        [_socketIO release];
//        _socketIO = nil;
//    }
    
    [[YasoundDataProvider main] leaveRadioWall:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"leave wall error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"leave wall error: response status %d", status);
            return;
        }
    }];

    if (_serverErrorCount == 0)
    {
        if ([AudioStreamManager main].isPaused)
            [[AudioStreamManager main] stopRadio];
    }
    else
    {
        [[AudioStreamManager main] stopRadio];
    }
    
    if ((_timerUpdate != nil) && [_timerUpdate isValid])
    {
        [_timerUpdate invalidate];
        _timerUpdate = nil;
    }
    
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
    NSLog(@"Wall dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_messageFont release];
    [_wallEvents release];
    [_updateLock release];
    
    [super dealloc];
}


- (void)showWaitingEventRow
{
    //LBDEBUG TRY
    if (_waitingForPreviousEvents)
        return;
    
    _waitingForPreviousEvents = YES;
    // #FIXME: todo...
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_wallEvents.count inSection:SECTION_EVENTS]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)removeWaitingEventRow
{
    //LBDEBUG TRY
    if (!_waitingForPreviousEvents)
        return;
    
    _waitingForPreviousEvents = NO;
    // #FIXME: todo...
    [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_wallEvents.count inSection:SECTION_EVENTS]] withRowAnimation:UITableViewRowAnimationFade];
}









#pragma mark - Data

- (void)refreshCurrentSong
{    
    [[YasoundDataProvider main] currentSongForRadio:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"radio current song error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"radio current song error: response status %d", status);
            return;
        }
        Song* song = (Song*)[response jsonToModel:[Song class]];
        if (song == nil)
        {
            DLog(@"radio current song error: cannot parse response %@", response);
            return;
        }
        
        [self setNowPlaying:song];
    }];
}

- (void)refreshCurrentUsers
{
    [[YasoundDataProvider main] currentUsersForRadio:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"radio current users error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"radio current users error: response status %d", status);
            return;
        }
        Container* usersContainer = [response jsonToContainer:[User class]];
        if (usersContainer == nil)
        {
            DLog(@"radio current users error: cannot parse response %@", response);
            return;
        }
        if (usersContainer.objects == nil)
        {
            DLog(@"radio current users error: bad response %@", response);
            return;
        }
        [self.cellWallHeader setListeners:usersContainer.objects.count];
    }];
}

//....................................................................
//
// onTimerUpdate
//
// timer callback to call for updates from server
//

- (void)onTimerUpdate:(NSTimer*)timer
{
    if (_stopWall)
    {
        [_timerUpdate invalidate];
        _timerUpdate = nil;
        return;
    }
    
    if ([_updateLock tryLock])
    {
        if (_pushServerOk == NO) // if push server is available, new wall events and current song events are sent directly, no nedd to poll
        {
            if (_wallEvents.count > 0)
            {
                NSNumber* newestEventID = ((WallEvent*)[_wallEvents objectAtIndex:0]).id;
                [[YasoundDataProvider main] wallEventsForRadio:self.radio newerThanEventWithID:newestEventID withCompletionBlock:^(int status, NSString* response, NSError* error){
                    [self currentWallEventsRequestReturnedWithStatus:status response:response error:error];
                }];
            }
            else
            {
                [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:25 withCompletionBlock:^(int status, NSString* response, NSError* error){
                    [self currentWallEventsRequestReturnedWithStatus:status response:response error:error];
                }];
            }
            
            [self refreshCurrentSong];
        }
        
        // current users are not handled by the push server
        [self refreshCurrentUsers];
        
        [_updateLock unlock];
    }
    
}

- (void)updatePreviousWall
{
    _updatingPrevious = YES;
    
    [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_FIRSTREQUEST_FIRST_PAGESIZE withCompletionBlock:^(int status, NSString* response, NSError* error){
        [self previousWallEventsRequestReturnedWithStatus:status response:response error:error];
    }];    
    [self refreshCurrentSong];
}

- (void)updateCurrentWall
{
    if (_wallEvents.count > 0)
    {
        NSNumber* newestEventID = ((WallEvent*)[_wallEvents objectAtIndex:0]).id;
        [[YasoundDataProvider main] wallEventsForRadio:self.radio newerThanEventWithID:newestEventID withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self currentWallEventsRequestReturnedWithStatus:status response:response error:error];
        }];
        
    }
    else
    {
        [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:25 withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self currentWallEventsRequestReturnedWithStatus:status response:response error:error];
        }];
    }
}








- (void)logWallEvents
{
    int i = 0;
    for (WallEvent* w in _wallEvents)
    {
        DLog(@"(%d) -%@- %@", i, w.type, [w isOfType:eWallEventTypeMessage]  ? w.text : w.song_name);
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

- (void)previousWallEventsRequestReturnedWithStatus:(int)status response:(NSString*)response error:(NSError*)error
{
    [self removeWaitingEventRow];
    BOOL ok = YES;
    if (error)
    {
        DLog(@"previous wall events error: %d - %@", error.code, error. domain);
        ok = NO;
    }
    if (status != 200)
    {
        DLog(@"previous wall events error: response status %d", status);
        ok = NO;
    }
    Container* eventsContainer = [response jsonToContainer:[WallEvent class]];
    if (eventsContainer == nil)
    {
        DLog(@"previous wall events error: cannot parse response %@", response);
        ok = NO;
    }
    if (eventsContainer.objects == nil)
    {
        DLog(@"previous wall events error: bad response %@", response);
        ok = NO;
    }
    
    if (ok == NO)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        return;
    }
    
    _serverErrorCount = 0;
    NSArray* events = eventsContainer.objects;
    
    if (!events || events.count == 0)
    {       
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
    
    DLog(@"\nreceivedPreviousWallEvents %d events", events.count);
    
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
    
    WallEvent* ev = [events objectAtIndex:0];
    WallEvent* wev = nil;
    
    if (_wallEvents.count > 0)
        wev = [_wallEvents objectAtIndex:0];
    
    if ((wev != nil) && [wev.start_date isLaterThan:ev.start_date])
        _latestEvent = wev;
    else
        _latestEvent = ev;
    
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
        [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_FIRSTREQUEST_SECOND_PAGESIZE olderThanEventWithID:_lastWallEvent.id withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self previousWallEventsRequestReturnedWithStatus:status response:response error:error];
        }];
    }
    else
    {
        _updatingPrevious = NO;
    }
    
    
    //DLog(@"end receivedPreviousWAllEvents\n");
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
- (void)currentWallEventsRequestReturnedWithStatus:(int)status response:(NSString*)response error:(NSError*)error
{
    BOOL ok = YES;
    if (error)
    {
        DLog(@"current wall events error: %d - %@", error.code, error. domain);
        ok = NO;
    }
    if (status != 200)
    {
        DLog(@"current wall events error: response status %d", status);
        ok = NO;
    }
    Container* eventsContainer = [response jsonToContainer:[WallEvent class]];
    if (eventsContainer == nil)
    {
        DLog(@"current wall events error: cannot parse response %@", response);
        ok = NO;
    }
    if (eventsContainer.objects == nil)
    {
        DLog(@"current wall events error: bad response %@", response);
        ok = NO;
    }
    
    if (ok == NO)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        return;
    }
    
    _serverErrorCount = 0;
    NSArray* events = eventsContainer.objects;
    if (!events || events.count == 0)
    {
        //DLog(@"NO MORE EVENTS. end receivedCurrentWallEvents\n");
        return;
    }    
    
    DLog(@"\nreceivedCurrentWallEvents %d events", events.count);
    
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
        
        DLog(@"first event is %@ : %@", [ev wallEventTypeString], ev.start_date);
        if (wev != nil)
            DLog(@"first wallevent is %@ : %@", [wev wallEventTypeString], wev.start_date);
        
        if ((wev != nil) && [wev.start_date isLaterThan:ev.start_date])
            _latestEvent = wev;
        else
            _latestEvent = ev;
        
        
        DLog(@"_latestEvent is %@ : %@", [_latestEvent wallEventTypeString], _latestEvent.start_date);
    }
    else
        return;
    
    DLog(@"end receivedCurrentWAllEvents\n");
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
    
    DLog(@"receivedCurrentMessageEvent ADD %@ : date %@", ev.user_name, ev.start_date);
    
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


- (void)userJoined:(User*)u
{
    DLog(@"userJoined %@", u.name);
    [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se connecter", u.name]];
    
}

- (void)userLeft:(User*)u
{
    DLog(@"userLeft %@", u.name);
    [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se déconnecter", u.name]];
}







//.................................................................................................
//
// MESSAGES
//

- (void)addMessage
{
    NSInteger index = _wallEvents.count - 1;
    
    WallEvent* ev = [_wallEvents objectAtIndex:index];
    [ev computeTextHeightUsingFont:_messageFont withConstraint:MESSAGE_WIDTH];
    
    UITableViewRowAnimation anim = UITableViewRowAnimationNone;
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:SECTION_EVENTS]] withRowAnimation:anim];
}


- (void)addSong
{
    NSInteger index = _wallEvents.count - 1;
    
    UITableViewRowAnimation anim = UITableViewRowAnimationNone;
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:SECTION_EVENTS]] withRowAnimation:anim];
}

- (void)addLike
{
    NSInteger index = _wallEvents.count - 1;
    
    UITableViewRowAnimation anim = UITableViewRowAnimationNone;
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:SECTION_EVENTS]] withRowAnimation:anim];
}




- (void)insertMessage
{
    NSInteger index = 0;
    
    WallEvent* ev = [_wallEvents objectAtIndex:index];
    [ev computeTextHeightUsingFont:_messageFont withConstraint:MESSAGE_WIDTH];
    
    UITableViewRowAnimation anim = UITableViewRowAnimationTop;
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:SECTION_EVENTS]] withRowAnimation:anim];
}


- (void)insertSong
{
    NSInteger index = 0;
    
    UITableViewRowAnimation anim = UITableViewRowAnimationTop;
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:SECTION_EVENTS]] withRowAnimation:anim];
}

- (void)insertLike
{
    NSInteger index = 0;
    
    UITableViewRowAnimation anim = UITableViewRowAnimationTop;
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:SECTION_EVENTS]] withRowAnimation:anim];
}






#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertGoToRadio)
    {
        if (buttonIndex == 0)
        {
            // cancel
            DLog(@"don't go to radio");
        }
        else if (buttonIndex == 1)
        {
//            DLog(@"go to %@ - %@", _radioForSelectedUser.name, _radioForSelectedUser.id);
//            WallViewController* view = [[WallViewController alloc] initWithRadio:_radioForSelectedUser];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//            
//            _radioForSelectedUser = nil;
        }
    }
    
    else if (alertView == _alertGoToLogin)
    {
        if (buttonIndex == 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_LOGIN object:nil];
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
    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NB_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_HEADER)
        return 2;
    
    NSInteger nbRows = [_wallEvents count];
    if (_waitingForPreviousEvents)
        nbRows++;
    return nbRows;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ((indexPath.section == SECTION_HEADER) && (indexPath.row == ROW_HEADER))
        return HEADER_HEIGHT;

    if ((indexPath.section == SECTION_HEADER) && (indexPath.row == ROW_POST_BAR))
        return POST_BAR_HEIGHT;
    
        
    if (_waitingForPreviousEvents && indexPath.row == _wallEvents.count)
        return WALL_WAITING_ROW_HEIGHT;
    
    WallEvent* ev = [_wallEvents objectAtIndex:indexPath.row];
    
    if ([ev isOfType:eWallEventTypeMessage])
    {
        assert([ev isTextHeightComputed] == YES);
        
        CGFloat height = [ev getTextHeight];
        
        if ((height + THE_REST_OF_THE_CELL_HEIGHT) < _cellMinHeight)
        {
            [ev setCellHeight:_cellMinHeight];
            return _cellMinHeight;
        }
        
        CGFloat cellHeight = height + THE_REST_OF_THE_CELL_HEIGHT;
        [ev setCellHeight:cellHeight];
        return cellHeight;
    }
    else if ([ev isOfType:eWallEventTypeSong])
    {
        [ev setCellHeight:ROW_SONG_HEIGHT];
        return ROW_SONG_HEIGHT;
    }
    else if ([ev isOfType:eWallEventTypeLike])
    {
        [ev setCellHeight:ROW_LIKE_HEIGHT];
        return ROW_LIKE_HEIGHT;
    }
    else
    {
        [ev setCellHeight:0];
        assert(0);
        return 0;
    }
    

    return 0;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_HEADER) && (indexPath.row == ROW_HEADER))
        return self.cellWallHeader;

    if ((indexPath.section == SECTION_HEADER) && (indexPath.row == ROW_POST_BAR))
        return self.cellPostBar;
    
    
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
    
    //LBDEBUG : try anti-bug
    if (!ev.isCellHeightComputed)
    {
        [self tableView:tableView heightForRowAtIndexPath:indexPath];
        assert(ev.isCellHeightComputed);
    }

    if ([ev isOfType:eWallEventTypeMessage])
    {
        static NSString* CellIdentifier = @"RadioViewMessageCell";
        
        RadioViewCell* cell = (RadioViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
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
    DLog(@"ask for previous events");
    if (_waitingForPreviousEvents)
        return;
    
    if (_wallEvents.count > 0)
    {
        NSNumber* lastEventID = ((WallEvent*)[_wallEvents objectAtIndex:_wallEvents.count - 1]).id;
        [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_PREVIOUS_EVENTS_REQUEST_PAGESIZE olderThanEventWithID:lastEventID withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self previousWallEventsRequestReturnedWithStatus:status response:response error:error];
        }];
    }
    else
    {
        [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_PREVIOUS_EVENTS_REQUEST_PAGESIZE withCompletionBlock:^(int status, NSString* response, NSError* error){
            [self previousWallEventsRequestReturnedWithStatus:status response:response error:error];
        }];
    }
    
    [self showWaitingEventRow];
}


#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.keyboardShown)
        return;
    
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

    if (scrollView.contentOffset.y > HEADER_HEIGHT)
    {
        // fix the post-message-bar at the top of the tableview
        if (!self.fixedCellPostBar.fixed)
            [self showFixedPostBar];
    }
    else
    {
        // put the post-message-bar back at its original position
        if (self.fixedCellPostBar.fixed)
            [self hideFixedPostBar];
    }
}


- (void)showFixedPostBar
{
    self.fixedCellPostBar.fixed = YES;
    self.fixedCellPostBar.textfield.text = self.cellPostBar.textfield.text;
    [self.view addSubview:self.fixedCellPostBar];
}


- (void)hideFixedPostBar
{
    self.fixedCellPostBar.fixed = NO;
    self.cellPostBar.textfield.text = self.fixedCellPostBar.textfield.text;
    [self.fixedCellPostBar removeFromSuperview];
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
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.Status.RadioViewStatusBarMessage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
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


- (IBAction)onPostBarButtonClicked:(id)sender
{
    NSString* msg;
    if (sender == self.cellPostBar.button)
        msg = self.cellPostBar.textfield.text;
    else if (sender == self.fixedCellPostBar.button)
        msg = self.fixedCellPostBar.textfield.text;
    else
    {
        assert(0);
    }
    
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* cleanText = [msg stringByTrimmingCharactersInSet:space];
    if (cleanText.length == 0)
        return;
    
    
    [self sendMessage:msg];
    self.cellPostBar.textfield.text = nil;
    self.fixedCellPostBar.textfield.text = nil;
    [self.cellPostBar.textfield endEditing:YES];
    [self.fixedCellPostBar.textfield endEditing:YES];
}


- (void)sendMessage:(NSString *)message
{
    [[ActivityModelessSpinner main] addRef];
    [[YasoundDataProvider main] postWallMessage:message toRadio:self.radio withCompletionBLock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"post wall message error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 201)
        {
            DLog(@"post wall message error: response status %d", status);
            return;
        }
        
        [[ActivityModelessSpinner main] removeRef];
        if (_pushServerOk == NO)
            [self updateCurrentWall];
    }];
}















//..........................................................................................................
//
// IBACTIONS
//
// [...], status bar button action
//

#pragma mark - IBActions

- (void)onCellAvatarClick:(RadioViewCell*)cell
{
    //    InteractiveView *btn = (InteractiveView *)sender;
    //    id parent = [btn superview];
    //    id gparent = [parent superview];
    //    id ggparent = [gparent superview];
    NSIndexPath *indexPath = [self.tableview indexPathForCell:cell];
    
    WallEvent *event = [_wallEvents objectAtIndex:indexPath.row];
    if (event != nil && event.user_id != nil)
    {
        // Launch profile view
        ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil withUserId:event.user_id andModelUsername:event.user_username];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
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
        
        NSIndexPath* indexPath = [self.tableview indexPathForCell:cell];
        
        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    [_updateLock unlock];
}






- (void)playAudio
{
    [self setPause:NO];
}

- (void)pauseAudio
{
    [self setPause:YES];
}










#pragma mark - Notifications

- (void)onAudioStreamNotif:(NSNotification *)notification
{
    if ([notification.name isEqualToString:NOTIF_DISPLAY_AUDIOSTREAM_ERROR])
    {
        [self setStatusMessage:NSLocalizedString(@"RadioView_status_message_audiostream_error", nil)];
        return;
    }
    else if ([notification.name isEqualToString:NOTIF_AUDIOSTREAM_PLAY])
    {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];

        [self playAudio];
        return;
    }
    else if ([notification.name isEqualToString:NOTIF_AUDIOSTREAM_STOP])
    {
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        
        [self pauseAudio];
        return;
    }  
}



- (BOOL)canBecomeFirstResponder {
    return YES;
}





#pragma makr - Touches

// one editing cell at a time

- (void)tableViewTouched:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.cellPostBar.textfield endEditing:YES];
    [self.fixedCellPostBar.textfield endEditing:YES];
    
    UITouch *touch = [touches anyObject];
	CGPoint touchCoordinates = [touch locationInView:_cellEditing];
    
    if (_cellEditing != nil)
    {
        if (![_cellEditing touch:touchCoordinates])
        {
            [_cellEditing deactivateEditModeAnimated:YES];
            _cellEditing = nil;
        }
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






#pragma mark - TopBarDelegate

- (BOOL)topBarItemClicked:(TopBarItemId)itemId
{
    if (itemId == TopBarItemBack)
    {
        _stopWall = YES;
        self.topBar.delegate = nil;
        self.tableview.delegate = nil;

    }
    
    else if (itemId == TopBarItemSettings)
    {
        DLog(@"settings item clicked for radio : %@", [self.radio toString]);

         _sheetTools = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Radio.sheet.title", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Radio.sheet.button.programming", nil), NSLocalizedString(@"Radio.sheet.button.broadcast", nil), NSLocalizedString(@"Radio.sheet.button.settings", nil), nil];
        _sheetTools.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [_sheetTools showInView:self.view];
        [_sheetTools release];
    }
    
    return YES;
}









#pragma mark - ActionSheet Delegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _queryShare)
        [self shareActionSheetClickedButtonAtIndex:buttonIndex];

    else if (actionSheet == _sheetTools)
    {
        if (buttonIndex == 0)
        {
            ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil  forRadio:self.radio];
            [self.navigationController pushViewController:view animated:YES];
            [view release];
            return;
        }
        else if (buttonIndex == 1)
        {
            [ActivityAlertView showWithTitle:nil];
            [[YasoundDataProvider main] favoriteUsersForRadio:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
                if (error)
                {
                    DLog(@"radio favorite users error: %d - %@", error.code, error. domain);
                    return;
                }
                if (status != 200)
                {
                    DLog(@"radio favorite users error: response status %d", status);
                    return;
                }
                Container* usersContainer = [response jsonToContainer:[User class]];
                if (usersContainer == nil)
                {
                    DLog(@"radio favorite users error: cannot parse response %@", response);
                    return;
                }
                if (usersContainer.objects == nil)
                {
                    DLog(@"radio favorite users error: bad response %@", response);
                    return;
                }
                
                [ActivityAlertView close];
                
                MessageBroadcastModalViewController* view = [[MessageBroadcastModalViewController alloc] initWithNibName:@"MessageBroadcastModalViewController" bundle:nil forRadio:self.radio subscribers:usersContainer.objects target:self action:@selector(onModalReturned)];
                [self.navigationController presentModalViewController:view animated:YES];
                [view release];
            }];
            return;
        }
        else if (buttonIndex == 2)
        {
            SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil forRadio:self.radio createMode:NO];
            [APPDELEGATE.navigationController pushViewController:view animated:YES];
            [view release];
            return;
        }

    
    }
}

- (void)onModalReturned
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



 
- (void)keyboardWillShow:(NSNotification *)note
{
    self.keyboardShown = YES;

    if (!self.fixedCellPostBar.fixed)
    {
        CGPoint scrollPoint = CGPointMake(0.0, self.cellPostBar.frame.size.height + 11);
        [self.tableview setContentOffset:scrollPoint animated:YES];
    }

}




- (void)keyboardDidHide:(NSNotification *)note
{
    self.keyboardShown = NO;

    [self scrollViewDidScroll:self.tableview];
}


//#pragma mark - SocketIODelegate
//
//- (void) socketIODidConnect:(SocketIO*)socket
//{
//    DLog(@"socketIODidConnect");
//    if (socket != _socketIO)
//    {
//        DLog(@"wrong socketIO");
//        return;
//    }
//    
//    [_socketIO sendEvent:@"subscribe" withData:[NSDictionary dictionaryWithObject:self.radio.id forKey:@"radio_id"]];
//}
//
//- (void) socketIODidDisconnect:(SocketIO*)socket
//{
//    DLog(@"socketIODidDisconnect");
//    if (socket != _socketIO)
//    {
//        DLog(@"wrong socketIO");
//        return;
//    }
//    
//    if (_socketIO)
//    {
//        [_socketIO release];
//        _socketIO = nil;
//    }
//}
//
//- (void) socketIO:(SocketIO*)socket didReceiveMessage:(SocketIOPacket*)packet
//{
//    DLog(@"socketIO: didReceiveMessage");
//}
//
//- (void) socketIO:(SocketIO*)socket didReceiveJSON:(SocketIOPacket*)packet
//{
//    DLog(@"socketIO: didReceiveJSON");
//}
//
//- (void) socketIO:(SocketIO*)socket didReceiveEvent:(SocketIOPacket*)packet
//{
//    DLog(@"socketIO: didReceiveEvent");
//    if (socket != _socketIO)
//    {
//        DLog(@"wrong socketIO");
//        return;
//    }
//    
//    if (!packet.data)
//        return;
//    
//    NSDictionary* packetDataDict = [packet.data JSONValue];
//    if (!packetDataDict)
//        return;
//    
//    NSString* eventName = [packetDataDict valueForKey:@"name"];
//    if ([eventName isEqualToString:@"radio_event"] == NO)
//        return;
//    
//    NSArray* args = [packetDataDict valueForKey:@"args"];
//    if (!args || [args isKindOfClass:[NSArray class]] == NO || args.count == 0)
//        return;
//    
//    NSDictionary* arg0 = [args objectAtIndex:0];
//    if (!arg0)
//        return;
//    
//    NSString* dataStr = [arg0 valueForKey:@"data"];
//    if (!dataStr)
//        return;
//    
//    NSDictionary* data = [dataStr JSONValue];
//    if (!data)
//        return;
//    
//    NSString* type = [data valueForKey:@"event_type"];
//    if (!type)
//        return;
//    
//    NSString* descStr = [data valueForKey:@"data"];
//    if (!descStr)
//        return;
//    
//    if ([type isEqualToString:@"wall_event"])
//    {
//        WallEvent* ev = (WallEvent*)[descStr jsonToModel:[WallEvent class]];
//        if (!ev.id)
//            return;
//        DLog(@"socket.io: new wall event (id = %@)", ev.id);
//        
//        if ([ev wallEventType] == eWallEventTypeMessage)
//        {
//            [self receivedCurrentMessageEvent:ev];
//            _countMessageEvent++;
//        }
//        else if ([ev wallEventType] == eWallEventTypeLike)
//            [self receivedCurrentLikeEvent:ev];
//        else if ([ev wallEventType] == eWallEventTypeSong)
//            [self receivedCurrentSongEvent:ev];
//    }
//    else if ([type isEqualToString:@"wall_event_deleted"])
//    {
//        WallEvent* ev = (WallEvent*)[descStr jsonToModel:[WallEvent class]];
//        if (!ev.id)
//            return;
//        DLog(@"socket.io: wall event deleted (id = %@)", ev.id);
//        
//        int index = 0;
//        BOOL toremove = NO;
//        for (WallEvent* e in _wallEvents)
//        {
//            if ([ev isEqual:e])
//            {
//                toremove = YES;
//                break;
//            }
//            index++;
//        }
//        
//        if (toremove)
//        {
//            [_wallEvents removeObjectAtIndex:index];
//            if ([ev isEqual:_lastWallEvent])
//                _lastWallEvent = [_wallEvents objectAtIndex:_wallEvents.count - 1];
//            if ([ev isEqual:_latestEvent])
//                _latestEvent = [_wallEvents objectAtIndex:_wallEvents.count - 1];
//            if ([ev wallEventType] == eWallEventTypeMessage)
//                _countMessageEvent--;
//        }
//    }
//    else if ([type isEqualToString:@"song"])
//    {
//        Song* song = (Song*)[descStr jsonToModel:[Song class]];
//        if (!song.id)
//            return;
//        
//        DLog(@"current song updated (id = %@ - name = %@)", song.id, song.name);
//        [self setNowPlaying:song];
//    }
//}
//
//- (void) socketIO:(SocketIO*)socket didSendMessage:(SocketIOPacket*)packet
//{
//}
//
//- (void) socketIOHandshakeFailed:(SocketIO*)socket
//{
//    DLog(@"socketIOHandshakeFailed");
//    if (socket != _socketIO)
//    {
//        DLog(@"wrong socketIO");
//        return;
//    }
//    
//    if (_socketIO)
//    {
//        [_socketIO disconnect];
//        [_socketIO release];
//        _socketIO = nil;
//    }
//}

#pragma mark - PushDelegate

- (void)didConnectToPushServerForRadioId:(NSNumber*)radioId
{
    if ([radioId isEqualToNumber:self.radio.id] == NO)
    {
        DLog(@"push server connect: wrong radio (%@ != %@)", radioId, self.radio.id);
        return;
    }
    
    DLog(@"push server ready for radio %@", radioId);
    _pushServerOk = YES;
}

- (void)didDisconnectFromPushServerForRadioId:(NSNumber*)radioId
{
    if ([radioId isEqualToNumber:self.radio.id] == NO)
    {
        DLog(@"push server disconnect: wrong radio (%@ != %@)", radioId, self.radio.id);
        return;
    }
    
    DLog(@"push server disconnected for radio %@", radioId);
    _pushServerOk = NO;
}

- (void)didReceiveEventFromRadio:(NSNumber*)radioId data:(NSDictionary*)data
{
    if ([radioId isEqualToNumber:self.radio.id] == NO)
    {
        DLog(@"push server event received: wrong radio (%@ != %@)", radioId, self.radio.id);
        return;
    }
    
    DLog(@"radio %@ did receive event %@", radioId, data);
    
    NSString* type = [data valueForKey:@"event_type"];
    if (!type)
        return;
    
    NSString* descStr = [data valueForKey:@"data"];
    if (!descStr)
        return;
    
    if ([type isEqualToString:@"wall_event"])
    {
        WallEvent* ev = (WallEvent*)[descStr jsonToModel:[WallEvent class]];
        if (!ev.id)
            return;
        DLog(@"socket.io: new wall event (id = %@)", ev.id);
        
        if ([ev wallEventType] == eWallEventTypeMessage)
        {
            [self receivedCurrentMessageEvent:ev];
            _countMessageEvent++;
        }
        else if ([ev wallEventType] == eWallEventTypeLike)
            [self receivedCurrentLikeEvent:ev];
        else if ([ev wallEventType] == eWallEventTypeSong)
            [self receivedCurrentSongEvent:ev];
    }
    else if ([type isEqualToString:@"wall_event_deleted"])
    {
        WallEvent* ev = (WallEvent*)[descStr jsonToModel:[WallEvent class]];
        if (!ev.id)
            return;
        DLog(@"socket.io: wall event deleted (id = %@)", ev.id);
        
        int index = 0;
        BOOL toremove = NO;
        for (WallEvent* e in _wallEvents)
        {
            if ([ev isEqual:e])
            {
                toremove = YES;
                break;
            }
            index++;
        }
        
        if (toremove)
        {
            [_wallEvents removeObjectAtIndex:index];
            if ([ev isEqual:_lastWallEvent])
                _lastWallEvent = [_wallEvents objectAtIndex:_wallEvents.count - 1];
            if ([ev isEqual:_latestEvent])
                _latestEvent = [_wallEvents objectAtIndex:_wallEvents.count - 1];
            if ([ev wallEventType] == eWallEventTypeMessage)
                _countMessageEvent--;

            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:SECTION_EVENTS];
            [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }
    else if ([type isEqualToString:@"song"])
    {
        Song* song = (Song*)[descStr jsonToModel:[Song class]];
        if (!song.id)
            return;
        
        DLog(@"current song updated (id = %@ - name = %@)", song.id, song.name);
        [self setNowPlaying:song];
    }

}


@end






