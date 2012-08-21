//
//  WallViewController.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WallViewController.h"
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

#import "ProfilViewController.h"
#import "ProfileMyRadioViewController.h"
#import "ShareModalViewController.h"
#import "ShareTwitterModalViewController.h"
#import "YasoundSessionManager.h"
#import "YasoundDataCache.h"

#import "SongInfoViewController.h"
#import "SongPublicInfoViewController.h"
#import "SongCatalog.h"
#import "WallViewController+NowPlayingBar.h"
#import "SettingsViewController.h"



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



@implementation WallViewController





@synthesize radio;
@synthesize statusMessages;
@synthesize ownRadio;

@synthesize requests;
@synthesize keyboardShown;

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



- (id)initWithRadio:(Radio*)radio
{
    self = [super init];
    if (self)
    {
        self.radio = radio;
        
        self.keyboardShown = NO;
        _stopWall = NO;
        
        self.ownRadio = [[YasoundDataProvider main].user.id intValue] == [self.radio.creator.id intValue];
        
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
//        _connectedUsers = nil;
//        _usersContainer = nil;
//        _radioForSelectedUser = nil;
        
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
    
    BOOL enableSettings = self.ownRadio;
    [self.topBar showSettingsItem:enableSettings];
    
    _waitingForPreviousEvents = NO;
    
    self.fixedCellPostBar.frame = CGRectMake(self.fixedCellPostBar.frame.origin.x, self.tableview.frame.origin.y, self.fixedCellPostBar.frame.size.width, self.fixedCellPostBar.frame.size.height);

    // table view
    self.tableview.actionTouched = @selector(tableViewTouched:withEvent:);

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.cellMessage.minHeight" error:nil];
    self.tableview.rowHeight = [[sheet.customProperties objectForKey:@"minHeight"] integerValue];
    
//    [self.cellWallHeader setHeaderRadio:self.radio];
    
    [self setPause:[AudioStreamManager main].isPaused];

    // get the actual data from the server to update the GUI
    [self updatePreviousWall];
    
    
    
    
    //    if (![self.radio.id isEqualToNumber:[AudioStreamManager main].currentRadio.id])
    //    {
    if (![AudioStreamManager main].isPaused)
    {
        [[AudioStreamManager main] startRadio:self.radio];
    }
    else
        [AudioStreamManager main].currentRadio = self.radio;
    
    [[YasoundDataProvider main] enterRadioWall:self.radio];
    
    //    }
    
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
    
    self.requests = [[NSMutableDictionary alloc] init];
    
    [self.cellWallHeader setHeaderRadio:self.radio];


    // launch timer here, but only the the wall has been filled already.
    // otherwise, wait for it to be filled, and then, we will launch the update timer.
    if (!_firstUpdateRequest && ((_timerUpdate == nil) || (![_timerUpdate isValid])))
    {
        // launch the update timer
        _timerUpdate = [NSTimer scheduledTimerWithTimeInterval:SERVER_DATA_REQUEST_TIMER target:self selector:@selector(onTimerUpdate:) userInfo:nil repeats:YES];
    }
    
}






- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [[YasoundDataProvider main] leaveRadioWall:self.radio];

    if (_serverErrorCount == 0)
    {
//        [[YasoundDataProvider main] leaveRadioWall:self.radio];
        
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
    
    // clean running requests
    //LBDEBUG ICI
    for (ASIHTTPRequest* req in self.requests)
    {
       // [req clearDelegatesAndCancel];
        [req release];
    }
    self.requests = nil;
    
//    // LBDEBUG hum hum... anti-bug for now
//    NSInteger retainCount = [self retainCount];
//    NSLog(@"RETAIN COUNT %d", retainCount);
//    for (NSInteger i = 0; i < retainCount-4; i++)
//        [self release];
        
    [super viewWillDisappear: animated];
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
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_wallEvents.count inSection:SECTION_EVENTS]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)removeWaitingEventRow
{
    if (!_waitingForPreviousEvents)
        return;
    
    _waitingForPreviousEvents = NO;
    // #FIXME: todo...
    [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_wallEvents.count inSection:SECTION_EVENTS]] withRowAnimation:UITableViewRowAnimationFade];
}









#pragma mark - Data

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
        [timer invalidate];
        return;
    }
    //    if (_ap != nil)
    //        [_ap release];
    //
    //    _ap = [[NSAutoreleasePool alloc] init];
    
    if ([_updateLock tryLock])
    {
        if (_wallEvents.count > 0)
        {
            NSNumber* newestEventID = ((WallEvent*)[_wallEvents objectAtIndex:0]).id;
            ASIHTTPRequest* req = [[YasoundDataProvider main] wallEventsForRadio:self.radio newerThanEventWithID:newestEventID target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
            [self.requests setObject:req forKey:req];
        }
        else
        {
            ASIHTTPRequest* req = [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:25 target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
            [self.requests setObject:req forKey:req];
        }
        
        [[YasoundDataProvider main] currentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
        [[YasoundDataProvider main] radioWithId:self.radio.id target:self action:@selector(receiveRadio:withInfo:)];
//        [[YasoundDataProvider main] currentUsersForRadio:self.radio target:self action:@selector(receivedCurrentUsers:withInfo:)];
        
        [_updateLock unlock];
    }
    
}

- (void)updatePreviousWall
{
    _updatingPrevious = YES;
    
    ASIHTTPRequest* req = [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_FIRSTREQUEST_FIRST_PAGESIZE target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
    [self.requests setObject:req  forKey:req];
    
    [[YasoundDataProvider main] currentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
    [[YasoundDataProvider main] radioWithId:self.radio.id target:self action:@selector(receiveRadio:withInfo:)];
}

- (void)updateCurrentWall
{
    if (_wallEvents.count > 0)
    {
        NSNumber* newestEventID = ((WallEvent*)[_wallEvents objectAtIndex:0]).id;
        ASIHTTPRequest* req = [[YasoundDataProvider main] wallEventsForRadio:self.radio newerThanEventWithID:newestEventID target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
        [self.requests setObject:req  forKey:req];
    }
    else
    {
        ASIHTTPRequest* req = [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:25 target:self action:@selector(receivedCurrentWallEvents:withInfo:)];
        [self.requests setObject:req  forKey:req];
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

//ICI
- (void)receivedPreviousWallEvents:(NSArray*)events withInfo:(NSDictionary*)info
{
    //LBDEBUG
    //NSLog(@"%@", info);
    ///////////////////
    
    NSDictionary* userData = [info objectForKey:@"userData"];
    ASIHTTPRequest* req = [userData objectForKey:@"request"];
    assert(req);
    [self.requests removeObjectForKey:req];
    
    [self removeWaitingEventRow];
    
    Meta* meta = [info valueForKey:@"meta"];
    NSError* err = [info valueForKey:@"error"];
    
    if (err)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        
        DLog(@"receivedPreviousWallEvents ERROR!");
        return;
    }
    
    if (!meta)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        
        DLog(@"receivedPreviousWallEvents : ERROR no meta data!");
        return;
    }
    
    // reset error count
    _serverErrorCount = 0;
    
    if (!events || events.count == 0)
    {
        // DLog(@"NO MORE EVENTS. end receivedPreviousWallEvents\n");
        
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
    
    NSInteger count = events.count;
    
    // update _latestEvent
    
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
    DLog(@"_lastWallEvent is %@ : %@", [_lastWallEvent wallEventTypeString], _lastWallEvent.start_date);
    
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
        ASIHTTPRequest* req = [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_FIRSTREQUEST_SECOND_PAGESIZE olderThanEventWithID:_lastWallEvent.id target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
        [self.requests setObject:req forKey:req];
    }
    else
    {
        _updatingPrevious = NO;
    }
    
    
    DLog(@"end receivedPreviousWAllEvents\n");
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
//ICI
- (void)receivedCurrentWallEvents:(NSArray*)events withInfo:(NSDictionary*)info
{
    //LBDEBUG
    //NSLog(@"%@", info);
    ///////////////////
    NSDictionary* userData = [info objectForKey:@"userData"];
    ASIHTTPRequest* req = [userData objectForKey:@"request"];
    assert(req);
    [self.requests removeObjectForKey:req];


    Meta* meta = [info valueForKey:@"meta"];
    NSError* err = [info valueForKey:@"error"];
    
    if (err)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        
        DLog(@"receivedCurrentWallEvents ERROR!");
        return;
    }
    
    if (!meta)
    {
        if (_serverErrorCount == 3)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
        else
            _serverErrorCount++;
        
        DLog(@"receivedCurrentWallEvents : ERROR no meta data!");
        return;
    }
    
    // reset error count
    _serverErrorCount = 0;
    
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



//
// Current Song
//
- (void) receivedCurrentSong:(Song*)song withInfo:(NSDictionary*)info
{
    if (!song)
        return;
    
    [self setNowPlaying:song];
    
    [[YasoundDataProvider main] statusForSongId:song.id target:self action:@selector(receivedCurrentSongStatus:withInfo:)];
}

- (void)receivedCurrentSongStatus:(SongStatus*)status withInfo:(NSDictionary*)info
{
    if (!status)
        return;
//    if (_playingNowView)
//        [_playingNowView setSongStatus:status];
}

- (void)receiveRadio:(Radio*)r withInfo:(NSDictionary*)info
{
    if (!r)
        return;
    
    self.radio = r;
    
    
//    _favoritesLabel.text = [NSString stringWithFormat:@"%d", [self.radio.favorites integerValue]];
    _listenersLabel.text = [NSString stringWithFormat:@"%d", [self.radio.nb_current_users integerValue]];
}




- (void)userJoined:(User*)u
{
    DLog(@"%@ joined", u.name);
    [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se connecter", u.name]];
    
}

- (void)userLeft:(User*)u
{
    DLog(@"%@ left", u.name);
    [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se déconnecter", u.name]];
}

//- (void)receivedCurrentUsers:(NSArray*)users withInfo:(NSDictionary*)info
//{
//    if (!users || users.count == 0)
//        return;
//    
//    if (_connectedUsers && _connectedUsers.count > 0)
//    {
//        // get diff
//        NSMutableArray* joined = [NSMutableArray array];
//        NSMutableArray* left = [NSMutableArray array];
//        
//        // user arrays are sorted by id
//        NSArray* oldUsers = _connectedUsers;
//        NSArray* newUsers = users;
//        User* u;
//        
//        User* firstNew = [newUsers objectAtIndex:0];
//        User* lastNew = [newUsers objectAtIndex:newUsers.count - 1];
//        User* firstOld = [oldUsers objectAtIndex:0];
//        User* lastOld = [oldUsers objectAtIndex:oldUsers.count - 1];
//        
//        
//        for (u in oldUsers)
//        {
//            if ([u.id intValue] >= [firstNew.id intValue])
//                break;
//            [left addObject:u];
//        }
//        
//        NSEnumerator* reverseEnumerator = [oldUsers reverseObjectEnumerator];
//        while (u = [reverseEnumerator nextObject])
//        {
//            if ([u.id intValue] <= [lastNew.id intValue])
//                break;
//            [left addObject:u];
//        }
//        
//        for (u in newUsers)
//        {
//            if ([u.id intValue] >= [firstOld.id intValue])
//                break;
//            [joined addObject:u];
//        }
//        
//        reverseEnumerator = [newUsers reverseObjectEnumerator];
//        while (u = [reverseEnumerator nextObject])
//        {
//            if ([u.id intValue] <= [lastOld.id intValue])
//                break;
//            [joined addObject:u];
//        }
//        
//        
//        for (u in joined)
//            [self userJoined:u];
//        for (u in left)
//            [self userLeft:u];
//    }
//    
//    if (_connectedUsers)
//        [_connectedUsers release];
//    _connectedUsers = users;
//    [_connectedUsers retain];
//    
//    if (_usersContainer)
//        [_usersContainer reloadData];
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
    [ev computeTextHeightUsingFont:_messageFont withConstraint:270];
    
    UITableViewRowAnimation anim = UITableViewRowAnimationTop;
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:SECTION_EVENTS]] withRowAnimation:anim];
}


- (void)insertSong
{
    NSInteger index = 0;
    
    WallEvent* ev = [_wallEvents objectAtIndex:index];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_LOGIN object:nil];
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

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}

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
        assert(0);
    }
    
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (tableView == _usersContainer)
//        return [self usersContainerCellForRowAtIndexPath:indexPath];
//
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
    DLog(@"ask for previous events");
    if (_waitingForPreviousEvents)
        return;
    
    if (_wallEvents.count > 0)
    {
        NSNumber* lastEventID = ((WallEvent*)[_wallEvents objectAtIndex:_wallEvents.count - 1]).id;
        ASIHTTPRequest* req = [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_PREVIOUS_EVENTS_REQUEST_PAGESIZE olderThanEventWithID:lastEventID target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
        [self.requests setObject:req forKey:req];
    }
    else
    {
        ASIHTTPRequest* req = [[YasoundDataProvider main] wallEventsForRadio:self.radio pageSize:WALL_PREVIOUS_EVENTS_REQUEST_PAGESIZE target:self action:@selector(receivedPreviousWallEvents:withInfo:)];
        [self.requests setObject:req  forKey:req];
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
//    if (textField != _messageBar)
//        return NO;
    
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
    
    [self sendMessage:msg];
    self.cellPostBar.textfield.text = nil;
    self.fixedCellPostBar.textfield.text = nil;
    [self.cellPostBar.textfield endEditing:YES];
    [self.fixedCellPostBar.textfield endEditing:YES];
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
        DLog(@"wall message can't be posted: %@", error.domain);
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

//- (IBAction)onBack:(id)sender
//{
//    // I need to check something...
//    YasoundAppDelegate* appDelegate = (YasoundAppDelegate*)[[UIApplication sharedApplication] delegate];
//    UINavigationController* appController = appDelegate.navigationController;
//    UINavigationController* thisController = self.navigationController;
//    
//    
//    [self.navigationController popViewControllerAnimated:YES];
//}

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
            ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:self.radio.creator];
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




//- (IBAction)onFavorite:(id)sender
//{
//    if (_favoritesButtonLocked)
//        return;
//    
//    _favoritesButtonLocked = YES;
//    
//    [[ActivityModelessSpinner main] addRef];
//    
//    // update the local GUI in advance, and then send the request, and wait for the delayed update
//    self.favoriteButton.selected = !self.favoriteButton.selected;
//    NSInteger nbFavorites = [_favoritesLabel.text integerValue];
//    if (self.favoriteButton.selected)
//        nbFavorites++;
//    else
//        nbFavorites--;
//    
//    _favoritesLabel.text = [NSString stringWithFormat:@"%d", nbFavorites];
//    
//    // send online request
//    NSString* url = URL_RADIOS_FAVORITES;
//    [[YasoundDataCache main] requestRadiosWithUrl:[NSURL URLWithString:url] withGenre:nil target:self action:@selector(onFavoritesRadioReceived:)];
//    
//    
//}





//- (void)onSwipeLeft:(UISwipeGestureRecognizer *)recognizer
//{
//    CGPoint point = [recognizer locationInView:[self view]];
//    DLog(@"Swipe left - start location: %f,%f", point.x, point.y);
//
//    if (_viewTracksDisplayed)
//        return;
//
//    NSError* error;
//	if (![[GANTracker sharedTracker] trackEvent:@"swipe" action:@"Go to TracksView" label:nil value:0 withError:&error])
//    {
//		        DLog(@"GANTracker Error tracking foreground event: %@", error);
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
//    DLog(@"Swipe right - start location: %f,%f", point.x, point.y);
//
//    if (!_viewTracksDisplayed)
//        return;
//
//    NSError* error;
//	if (![[GANTracker sharedTracker] trackEvent:@"swipe" action:@"Go back to RadioView" label:nil value:0 withError:&error])
//    {
//        DLog(@"GANTracker Error tracking foreground event: %@", error);
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
    [self setPause:NO];
//    [[AudioStreamManager main] startRadio:self.radio];
}

- (void)pauseAudio
{
    [self setPause:YES];
//    [[AudioStreamManager main] Radio];
}










#pragma mark - Notifications

- (void)onAudioStreamNotif:(NSNotification *)notification
{
    if ([notification.name isEqualToString:NOTIF_DISPLAY_AUDIOSTREAM_ERROR])
    {
        [self setStatusMessage:NSLocalizedString(@"RadioView_status_message_audiostream_error", nil)];
        DLog(@"stream error notification");
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
//        self.tableview.dataSource = nil;

        NSLog(@"RETAIN COUNT %d", [self retainCount]);

//        // LBDEBUG hum hum... anti-bug for now
//        NSInteger retainCount = [self retainCount];
//        NSLog(@"RETAIN COUNT %d", retainCount);
//        for (NSInteger i = 0; i < retainCount-3; i++)
//            [self autorelease];
    }
    
    else if (itemId == TopBarItemSettings)
    {
        DLog(@"settings item clicked for radio : %@", [self.radio toString]);

        SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil forRadio:self.radio];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];        
    }
    
    return YES;
}


//#pragma mark - WallPostCellDelegate
//- (void)postCellMoveToSuperview
//{
//    NSLog(@"prout");
//}
//



 
- (void)keyboardWillShow:(NSNotification *)note
{
    self.keyboardShown = YES;

    if (!self.fixedCellPostBar.fixed)
    {
        CGPoint scrollPoint = CGPointMake(0.0, self.cellPostBar.frame.size.height + 11);
        [self.tableview setContentOffset:scrollPoint animated:YES];
    }

//    NSDictionary *info = [note userInfo];
//    NSValue *beginPoint = [info objectForKey:UIKeyboardCenterBeginUserInfoKey];
//    NSValue *endPoint = [info objectForKey:UIKeyboardCenterEndUserInfoKey];
//    NSValue *keyBounds = [info objectForKey:UIKeyboardBoundsUserInfoKey];
//    
//    CGPoint pntBegin;
//    CGPoint pntEnd;
//    CGRect bndKey;
//    [beginPoint getValue:&pntBegin];
//    [endPoint getValue:&pntEnd];
//    [keyBounds getValue:&bndKey];
    
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    self.tableview.contentInset = contentInsets;
//    self.tableview.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, self.cellPostBar.frame.origin) ) {
//        CGPoint scrollPoint = CGPointMake(0.0, self.cellPostBar.frame.size.height + 11);
//        [self.tableview setContentOffset:scrollPoint animated:YES];
//    }
    
    //[self showFixedPostBar];
}




- (void)keyboardDidHide:(NSNotification *)note
{
    self.keyboardShown = NO;

    [self scrollViewDidScroll:self.tableview];
}



@end








