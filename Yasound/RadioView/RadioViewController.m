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
#import "RadioTabBarController.h"


#import "YasoundDataProvider.h"
#import "WallEvent.h"

#import "RadioUser.h"
#import "ActivityAlertView.h"
#import "Tutorial.h"
#import "InteractiveView.h"
#import "ActivityModelessSpinner.h"
#import "AudioStreamer.h"
#import "AudioStreamManager.h"

#import "SongViewCell.h"


//#define LOCAL 1 // use localhost as the server

#define SERVER_DATA_REQUEST_TIMER 5.0f

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

        _trackInteractionViewDisplayed = NO;
    
    //LBDEBUG
    //        [[YasoundDataProvider main] radioWithID:1 target:self action:@selector(receiveRadio:withInfo:)];
    
    
    _lastWallEventDate = nil;
    _lastSongUpdateDate = nil;
    
//    self.messages = [[NSMutableArray alloc] init];
    self.statusMessages = [[NSMutableArray alloc] init];
    
    _statusBarButtonToggled = NO;
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"CellMessage" error:nil];
    _messageFont = [sheet makeFont];
    [_messageFont retain];
    
    _messageWidth = sheet.frame.size.width;
    
    sheet = [[Theme theme] stylesheetForKey:@"CellMinHeight" error:nil];
    _cellMinHeight = [[sheet.customProperties objectForKey:@"minHeight"] floatValue];
        
        _wallEvents = [[NSMutableArray alloc] init];
        _wallHeights = [[NSMutableArray alloc] init];
//        [_wallEvents retain];
//        [_wallHeights retain];
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
    
    
    // header back arrow
    sheet = [[Theme theme] stylesheetForKey:@"HeaderBack" error:nil];
    UIButton* btn = [sheet makeButton];
//    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:btn];
    
    // header avatar, as a second back button
    sheet = [[Theme theme] stylesheetForKey:@"HeaderAvatar" error:nil];
//    _radioImage = [[WebImageView alloc] initWithImageFrame:CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height)];
    _radioImage = [[WebImageView alloc] initWithImageFrame:sheet.frame];
    NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    [_radioImage setUrl:imageURL];
    [_headerView addSubview:_radioImage];
    
//    btn = [[UIButton alloc] initWithFrame:sheet.frame];
//    [btn.imageView addSubview:_radioImage];
//    [btn setImage:[UIImage imageNamed:myImage[0]] forState:UIControlStateNormal]; 

//    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
//    [_headerView addSubview:btn];
    

//    // header avatar mask 
//    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderAvatarMask" error:nil];
//    UIImageView* avatarMask = [[UIImageView alloc] initWithImage:[sheet image]];
//    avatarMask.frame = sheet.frame;
//    [_headerView addSubview:avatarMask];
    
    // header avatar mask  as button
    sheet = [[Theme theme] stylesheetForKey:@"HeaderAvatarMask" error:nil];
    btn = [[UIButton alloc] initWithFrame:sheet.frame];
    [btn setImage:[sheet image] forState:UIControlStateNormal]; 
//    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:btn];
    
    
    //    [btn.imageView addSubview:_radioImage];
    
    //    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    //    [_headerView addSubview:btn];

    
    // header title
    sheet = [[Theme theme] stylesheetForKey:@"HeaderTitle" error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = self.radio.name;
    [_headerView addSubview:label];
    
    // header heart image
    sheet = [[Theme theme] stylesheetForKey:@"HeaderHeart" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [_headerView addSubview:image];

    // header likes
    sheet = [[Theme theme] stylesheetForKey:@"HeaderLikes" error:nil];
    label = [sheet makeLabel];
    label.text = [NSString stringWithFormat:@"%d", [self.radio.likes integerValue]];
    [_headerView addSubview:label];
    
    // header headset image
    sheet = [[Theme theme] stylesheetForKey:@"HeaderHeadSet" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [_headerView addSubview:image];
    
    // header listeners
    sheet = [[Theme theme] stylesheetForKey:@"HeaderListeners" error:nil];
    label = [sheet makeLabel];
    label.text = [NSString stringWithFormat:@"%d", [self.radio.listeners integerValue]];
    [_headerView addSubview:label];
    
    // header edit settings button
    //LBDEBUG
//    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderEditButton" error:nil];
//    btn = [sheet makeButton];
//    [btn addTarget:self action:@selector(onEdit:) forControlEvents:UIControlEventTouchUpInside];
//    [_headerView addSubview:btn];

    //favorites button

    sheet = [[Theme theme] stylesheetForKey:@"HeaderFavoriteEmptyButton" error:nil];
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
    BundleStylesheet* sheetAvatar = [[Theme theme] stylesheetForKey:@"HeaderAvatar" error:nil];
    
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBar" error:nil];
    
    frame = CGRectMake(0, 0, sheetAvatar.frame.origin.x + sheetAvatar.frame.size.width, _headerView.frame.size.height - sheet.frame.size.height);
    InteractiveView* interactiveView = [[InteractiveView alloc] initWithFrame:frame target:self action:@selector(onBack:)];
    [_headerView addSubview:interactiveView];
    
    
    
    
    
    //....................................................................................
    //
    // header now playing bar
    //
    
    // border
    sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBorder" error:nil];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[sheet image]];
    imageView.frame = sheet.frame;
    [self.view addSubview:imageView];
    
    
    // header now playing bar image
    sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBar" error:nil];
    
    _playingNowContainer = [[UIView alloc] initWithFrame:sheet.frame];
    [self.view addSubview:_playingNowContainer];

    _playingNowView = nil;
    
    // now playing bar is set in setNowPlaying;
    
    

    
    
    
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
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewMessageBarBackground" error:nil];
    UIView* messageBarView = [[UIView alloc] initWithFrame:sheet.frame];
    
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    messageBarView.backgroundColor = [UIColor colorWithPatternImage:sheet.image];
    [_viewWall addSubview:messageBarView];   
    
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

//    sheet = [[Theme theme] stylesheetForKey:@"RadioViewTableView" error:nil];    
//    _tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyYasoundBackground.png"]];
//    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MyYasoundBackground.png"]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    

    sheet = [[Theme theme] stylesheetForKey:@"RadioViewTableViewCellMinHeight" error:nil];    
    _tableView.rowHeight = [[sheet.customProperties objectForKey:@"minHeight"] integerValue];

    [_viewWall addSubview:_tableView];

    
//    //....................................................................................
//    //
//    // extra layer
//    //
//    sheet = [[Theme theme] stylesheetForKey:@"RadioViewExtraLayer" error:nil];
//    image = [sheet makeImage];
//    [_viewWall addSubview:image];

    
    //....................................................................................
    //
    // status bar
    //
    BundleStylesheet* sheetStatus = [[Theme theme] stylesheetForKey:@"RadioViewStatusBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _statusBar = [[UIView alloc] initWithFrame:sheetStatus.frame];
    UIImageView* statusBarBackground = [sheetStatus makeImage];
    statusBarBackground.frame = CGRectMake(0, 0, sheetStatus.frame.size.width, sheetStatus.frame.size.height);
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
    [_viewWall addSubview:messageBar];
    
    
    
    
    
    
    
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
        CGRect framePageControl = CGRectMake(0, sheetStatus.frame.origin.y, sheetStatus.frame.size.width, 12);
        
        _pageControl = [[UIPageControl alloc] initWithFrame:framePageControl];
        _pageControl.numberOfPages = 2;
        _pageControl.userInteractionEnabled = NO;
        [self.view addSubview:_pageControl];
    }
    
    
    
    // get the actual data from the server to update the GUI
    [self onUpdate:nil];
}



- (void)viewDidAppear:(BOOL)animated
{
    [[AudioStreamManager main] startRadio:self.radio];
    [[YasoundDataProvider main] enterRadioWall:self.radio];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_PLAY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_STOP object:nil];
   
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    // <=> background audio playing
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];    
    
    //....................................................................................
    //
    // data update timer
    //
    _timerUpdate = [NSTimer scheduledTimerWithTimeInterval:SERVER_DATA_REQUEST_TIMER target:self selector:@selector(onUpdate:) userInfo:nil repeats:YES];
    
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
    
    [[YasoundDataProvider main] leaveRadioWall:self.radio];
    
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
    [_wallHeights release];
    [super dealloc];
}











//.................................................................................................
//
// DATA UPDATE
//


#pragma mark - Data 


//....................................................................
//
// onUpdate
//
// timer callback to call for updates from server
//

- (void)onUpdate:(NSTimer*)timer
{    
  [[YasoundDataProvider main] wallEventsForRadio:self.radio target:self action:@selector(receiveWallEvents:withInfo:)];
  [[YasoundDataProvider main] songsForRadio:self.radio target:self action:@selector(receiveRadioSongs:withInfo:)];
//    
}


#define EV_TYPE_MESSAGE @"M"
#define EV_TYPE_LOGIN @"J"
#define EV_TYPE_LOGOUT @"L"
#define EV_TYPE_SONG @"S"
#define EV_TYPE_START_LISTENING @"T"
#define EV_TYPE_STOP_LISTENING @"P"


+ (NSString*)evTypeToString:(NSString*)type
{
    if ([type isEqualToString:EV_TYPE_MESSAGE])
        return @"Message";
    if ([type isEqualToString:EV_TYPE_LOGIN])
        return @"Login";
    if ([type isEqualToString:EV_TYPE_LOGOUT])
        return @"Logout";
    if ([type isEqualToString:EV_TYPE_SONG])
        return @"Song";
    if ([type isEqualToString:EV_TYPE_START_LISTENING])
        return @"StartListening";
    if ([type isEqualToString:EV_TYPE_STOP_LISTENING])
        return @"StopListening";
}

- (void)logWallEvents
{
    int i = 0;
    for (WallEvent* w in _wallEvents)
    {
        NSLog(@"(%d) -%@- %@", i, w.type, [w.type isEqualToString:EV_TYPE_MESSAGE] ? w.text : w.song.metadata.name);
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

- (void)askForNextWallEvents
{
    if (_wallEvents.count == 0)
        [[YasoundDataProvider main] wallEventsForRadio:self.radio target:self action:@selector(receiveWallEvents:withInfo:)];
    else
    {
        WallEvent* last = [_wallEvents objectAtIndex:_wallEvents.count - 1];
        [[YasoundDataProvider main] wallEventsForRadio:self.radio afterEvent:last target:self action:@selector(receiveWallEvents:withInfo:)];
    }
}

- (void)didAddWallEvents:(int)count atIndex:(int)index
{
//    NSLog(@"%d events added at index %d", count, index);

    NSMutableArray* indexes = [[NSMutableArray alloc] init];
    for (NSInteger i = index; i < (index+count); i++)
    {
        [indexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];

        WallEvent* ev = [_wallEvents objectAtIndex:i];
        NSString* type = ev.type;
        if ([type isEqualToString:EV_TYPE_MESSAGE])
        {
            [self insertMessageAtIndex:i silent:YES];
        }
        else if ([type isEqualToString:EV_TYPE_SONG])
        {
            [self insertSongAtIndex:i silent:YES];
        }
        else
        {
            assert(0);
        }
    }
    
    [_tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationNone];

//    [_tableView reloadRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationNone];
    

//    [_tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationNone];
    
    
    // todo...
    // add message views
}

- (void)receiveWallEvents:(NSArray*)events withInfo:(NSDictionary*)info
{
    Meta* meta = [info valueForKey:@"meta"];
    NSError* err = [info valueForKey:@"error"];
    
    if (err)
    {
        NSLog(@"receiveWallEvents error!");
        return;
    }
    
    if (!meta)
    {
        NSLog(@"receiveWallEvents : no meta data!");
        return;
    }
    
    if (!events || events.count == 0)
        return;
    
    WallEvent* ev = nil;
    for (int i = [events count] - 1; i >= 0; i--)
    {
        ev  = [events objectAtIndex:i];
        if ([ev.type isEqualToString:EV_TYPE_LOGIN])
        {
            if ([ev.start_date compare:_lastWallEventDate] == NSOrderedDescending)
                [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se connecter", ev.user.name]];
            
        }
        else if ([ev.type isEqualToString:EV_TYPE_LOGOUT])
        {
            if ([ev.start_date compare:_lastWallEventDate] == NSOrderedDescending)
                [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se déconnecter", ev.user.name]];
        }
    }
    
    if (ev != nil)
    {
        NSLog(@"ev.start_date %@ (%@ - %@)", ev.start_date, ev.type, ev.text);
        _lastWallEventDate = ev.start_date;
    }
    else
        _lastWallEventDate = nil;
    
    int addedAtIndex = -1;
    int addedCount = 0;
    for (ev in events)
    {
        if (![ev.type isEqualToString:EV_TYPE_MESSAGE] && ![ev.type isEqualToString:EV_TYPE_SONG])
        {
            continue;
        }

        if (_wallEvents.count != 0 && [ev.start_date compare:((WallEvent*)[_wallEvents objectAtIndex:0]).start_date] == NSOrderedDescending)
        {
            [_wallEvents insertObject:ev atIndex:0];
            
            if ([ev.type isEqualToString:EV_TYPE_MESSAGE])
            {
                [self addMessage];
            }
            else if ([ev.type isEqualToString:EV_TYPE_SONG])
            {
                [self addSong];
            }
        }
        else if (_wallEvents.count == 0 || [ev.start_date compare:((WallEvent*)[_wallEvents objectAtIndex:_wallEvents.count-1]).start_date] == NSOrderedAscending)
        {
            [_wallEvents addObject:ev];
            
            if (addedAtIndex == -1)
                addedAtIndex = _wallEvents.count - 1;
            addedCount++;
        }
    }
    
    if (addedCount)
        [self didAddWallEvents:addedCount atIndex:addedAtIndex];
    
    int minMessageCount = 8;
    if ([self eventMessageCount] < minMessageCount)
        [self askForNextWallEvents];
}




- (void)receiveRadioSongs:(NSArray*)events withInfo:(NSDictionary*)info
{
  Meta* meta = [info valueForKey:@"meta"];
  NSError* err = [info valueForKey:@"error"];
  
  if (err)
  {
    NSLog(@"receiveRadioSongs error!");
    return;
  }
  
  if (!meta)
  {
    NSLog(@"receiveRadioSongs : no meta data!");
    return;
  }
  
  if ([events count] == 0)
    return;
  
  WallEvent* ev = [events objectAtIndex:0];
  if (_lastSongUpdateDate == nil || [ev.start_date compare:_lastSongUpdateDate] == NSOrderedDescending)
  {
    [self setNowPlaying:ev.song];
    _lastSongUpdateDate = ev.start_date;
  }
  
  
}












//.................................................................................................
//
// NOW PLAYING
//


#pragma mark - Now Playing

- (void)setNowPlaying:(Song*)song
{
    if (_gNowPlayingSong != nil)
        [_gNowPlayingSong release];
    
    _gNowPlayingSong = song;
    [_gNowPlayingSong retain];
    
    if (_trackInteractionViewDisplayed)
        return;
    
    //LBDEBUG TODO : get image, likes dislikes from Song
    NowPlayingView* view = [[NowPlayingView alloc] initWithSong:_gNowPlayingSong target:self action:@selector(onNowPlayingTouched)];
    [view.playPauseButton addTarget:self action:@selector(onPlayPause:) forControlEvents:UIControlEventTouchUpInside];

    
    [UIView transitionWithView:_playingNowContainer
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ [_playingNowView removeFromSuperview]; [_playingNowContainer addSubview:view]; _playingNowView = view; }
                    completion:NULL];    
}


- (void)onNowPlayingTouched
{
    CGRect frame, playingNowFrame, viewContainerFrame;
    BOOL callbackWhenStop = NO;

    // open the track interaction view
    if (!_trackInteractionViewDisplayed)
    {
        _trackInteractionViewDisplayed = YES;

        frame = _playingNowContainer.frame;
        playingNowFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height *2);
        viewContainerFrame = CGRectMake(_viewContainer.frame.origin.x, _viewContainer.frame.origin.y + frame.size.height, _viewContainer.frame.size.width, _viewContainer.frame.size.height - frame.size.height);
        
        _trackInteractionView = [[TrackInteractionView alloc] initWithSong:_gNowPlayingSong];
        _trackInteractionView.frame = CGRectMake(0, frame.size.height -1, frame.size.width, frame.size.height);

        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _trackInteractionView.backgroundColor = [UIColor colorWithPatternImage:[sheet image]];
        
        [_playingNowContainer addSubview:_trackInteractionView];

    }

    // close the track interaction view
    else
    {
        _trackInteractionViewDisplayed = NO;
        callbackWhenStop = YES;
        
        frame = _playingNowContainer.frame;
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height /2);
        playingNowFrame = frame;
        viewContainerFrame = CGRectMake(_viewContainer.frame.origin.x, _viewContainer.frame.origin.y - frame.size.height, _viewContainer.frame.size.width, _viewContainer.frame.size.height + frame.size.height);
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.16];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (callbackWhenStop)
    {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(nowPlayingAnimationFinished:finished:context:)];
    }

    
    _playingNowContainer.frame = playingNowFrame;
    _viewContainer.frame = viewContainerFrame;
    
    [UIView commitAnimations];        
}



- (void)nowPlayingAnimationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [_trackInteractionView removeFromSuperview];
    [_trackInteractionView release];
    _trackInteractionView = nil;
}




#define ROW_SONG_HEIGHT 24

//.................................................................................................
//
// MESSAGES
//

//- (void)addMessage:(NSString*)text user:(NSString*)user avatar:(NSURL*)avatarURL date:(NSDate*)date silent:(BOOL)silent
- (void)addMessage
{
    [self insertMessageAtIndex:0 silent:NO];
}
     

- (void)addSong
{
    [self insertSongAtIndex:0 silent:NO];
}



- (void)insertMessageAtIndex:(NSInteger)index  silent:(BOOL)silent
{
    WallEvent* ev = [_wallEvents objectAtIndex:index];
    NSString* text = ev.text;
    
    // compute the size of the text => will allow to update the cell's height dynamically
    CGSize suggestedSize = [text sizeWithFont:_messageFont constrainedToSize:CGSizeMake(_messageWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    [_wallHeights insertObject:[NSNumber numberWithFloat:suggestedSize.height] atIndex:index];
    
    //    [self.messages insertObject:m atIndex:0];
    //    
    //    if (!silent)
    //    {
    
    
    UITableViewRowAnimation anim = (silent) ? UITableViewRowAnimationNone : UITableViewRowAnimationTop;

    if (!silent)
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:anim];
    //    }
}

- (void)insertSongAtIndex:(NSInteger)index silent:(BOOL)silent
{
    [_wallHeights insertObject:[NSNumber numberWithFloat:ROW_SONG_HEIGHT] atIndex:index];
    
    UITableViewRowAnimation anim = (silent) ? UITableViewRowAnimationNone : UITableViewRowAnimationTop;

    if (!silent)
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:anim];
}




//.................................................................................................
//
// TABLE VIEW DELEGATE
//

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
    return [_wallEvents count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSNumber* nb = [_wallHeights objectAtIndex:indexPath.row];
    return [nb floatValue];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"RadioViewCell";
    
    WallEvent* ev = [_wallEvents objectAtIndex:indexPath.row];

    NSNumber* nb = [_wallHeights objectAtIndex:indexPath.row];
    CGFloat height = [nb floatValue];
    
    if ([ev.type isEqualToString:EV_TYPE_MESSAGE])
    {
        RadioViewCell* cell = (RadioViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[RadioViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier event:ev height:height indexPath:indexPath] autorelease];
        }
        else
            [cell update:ev height:height indexPath:indexPath];
        
        return cell;
    }
    else if ([ev.type isEqualToString:EV_TYPE_SONG])
    {
        SongViewCell* cell = (SongViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[SongViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier event:ev height:height indexPath:indexPath] autorelease];
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




//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}
//














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

    [self onUpdate:nil];
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
    [self.navigationController popViewControllerAnimated:YES];
}


//LBDEBUG
//- (IBAction) onEdit:(id)sender
//{
//    
//}


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


- (IBAction) onSearch:(id)sender
{
    RadioTabBarController* tabBarController = [[RadioTabBarController alloc] init];
    [self.navigationController pushViewController:tabBarController animated:YES];    
}


- (IBAction)onStatusBarButtonClicked:(id)sender
{
    BundleStylesheet* sheet = nil;
    
    // downsize status bar : hide users
    if (_statusBarButtonToggled)
    {
        _pageControl.hidden = NO;
        
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
        _pageControl.hidden = YES;
        
        [self cleanStatusMessages];
        
        _statusBarButtonToggled = !_statusBarButtonToggled;

        sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarButtonOn" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [_statusBarButton setImage:[sheet image] forState:UIControlStateNormal];
        
        // create scrollview
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBarUserScrollView" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        _statusUsers = [[UIScrollView alloc] initWithFrame:sheet.frame];
        
        _statusUsers.alpha = 0;
        [_statusBar addSubview:_statusUsers];

        [[ActivityModelessSpinner main] addRef];
        [[YasoundDataProvider main] connectedUsersForRadio:self.radio target:self action:@selector(onRadioUsersReceived:info:)];


        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 0.15];
        _statusBar.frame = CGRectMake(_statusBar.frame.origin.x, _statusBar.frame.origin.y - _statusBar.frame.size.height/2, _statusBar.frame.size.width, _statusBar.frame.size.height);
        _statusUsers.alpha = 1;
        [UIView commitAnimations];        

    }
    
}



- (void)onRadioUsersReceived:(NSArray*)users info:(NSDictionary*)info
{
    [[ActivityModelessSpinner main] removeRef];
    
    BundleStylesheet* imageSheet = [[Theme theme] stylesheetForKey:@"CellAvatar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    BundleStylesheet* nameSheet = [[Theme theme] stylesheetForKey:@"StatusBarUserName" retainStylesheet:YES overwriteStylesheet:NO error:nil];

    CGRect imageRect = imageSheet.frame;
    CGRect nameRect = nameSheet.frame;

    UIFont* font = [nameSheet makeFont];

    // fill scrollview with users
    for (User* user in users)
    {
        WebImageView* imageView ;
        
        CGFloat textWidth = [user.name sizeWithFont:font].width;
        CGFloat greatestWidth = (imageRect.size.width > textWidth) ? imageRect.size.width : textWidth;
        CGRect imageRect2 = CGRectMake(imageRect.origin.x + (greatestWidth / 2.f) - (imageRect.size.width / 2.f), imageRect.origin.y, imageRect.size.width, imageRect.size.height);
        CGRect nameRect2 = CGRectMake(nameRect.origin.x + (greatestWidth / 2.f) - (textWidth / 2.f), nameRect.origin.y, textWidth, nameRect.size.height);
        
        if (user.picture == nil)
        {
            imageView = [[WebImageView alloc] initWithImage:[UIImage imageNamed:@"avatarDummy.png"]];
            imageView.frame = imageRect2;
        }
        else
        {
            NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:user.picture];
            imageView = [[WebImageView alloc] initWithImageAtURL:imageURL];
            imageView.frame = imageRect2;
        }
        
        [_statusUsers addSubview:imageView];
        
        
        // image mask
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarMask" error:nil];
        UIImageView* mask = [[UIImageView alloc] initWithImage:[sheet image]];
        mask.frame = imageRect2;
        [_statusUsers addSubview:mask];
        
        
        UILabel* name = [nameSheet makeLabel];
        name.frame = nameRect2;
        name.text = user.name;
        [_statusUsers addSubview:name];
        
        
        imageRect = CGRectMake(imageRect.origin.x + greatestWidth +8, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
        nameRect = CGRectMake(nameRect.origin.x + greatestWidth +8, nameRect.origin.y, nameRect.size.width, nameRect.size.height);
        
    }
    // set scrollview content size
    //        [_statusUsers setContentSize:CGSizeMake(nameRect.origin.x + nameRect.size.width, _statusBar.frame.size.height)];
    [_statusUsers setContentSize:CGSizeMake(nameRect.origin.x, _statusBar.frame.size.height)];    
}


- (void)onStatusBarClosed:(NSString *)animationId finished:(BOOL)finished context:(void *)context 
{
    [_statusUsers removeFromSuperview];
    [_statusUsers release];
}






#pragma mark - Notifications

- (void)onAudioStreamNotif:(NSNotification *)notification
{
    if ([notification.name isEqualToString:NOTIF_AUDIOSTREAM_ERROR])
    {
      [self setStatusMessage:NSLocalizedString(@"RadioView_status_message_audiostream_error", nil)];
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






@end








