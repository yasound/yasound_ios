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
#import "RadioTabBarController.h"


#import "YasoundDataProvider.h"
#import "WallEvent.h"

#import "RadioUser.h"


//#define LOCAL 1 // use localhost as the server
#define USE_FAKE_RADIO_URL 1

#define SERVER_DATA_REQUEST_TIMER 5.0f

@implementation RadioViewController

static AudioStreamer* _gAudioStreamer = nil;

static Song* _gNowPlayingSong = nil;


//LBDEBUG
static int _fakeNowPlayingIndex = 0;
static NSTimer* _fakeNowPlayingTimer = nil;


@synthesize radio;
//LBDEBUG
//@synthesize audioStreamer;
@synthesize messages;
@synthesize statusMessages;


- (id)initWithRadio:(Radio *)radio
{
    self = [super init];
    if (self) 
    {
        self.radio = radio;
        
        _trackInteractionViewDisplayed = NO;

        //LBDEBUG
//        [[YasoundDataProvider main] radioWithID:1 target:self action:@selector(receiveRadio:withInfo:)];

        
        _lastWallEventDate = nil;
      _lastConnectionUpdateDate = [NSDate date];
      _lastSongUpdateDate = nil;

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
    _headerView = [[UIView alloc] initWithFrame:sheet.frame];
    _headerView.backgroundColor = sheet.color;
    [self.view addSubview:_headerView];
    
    // header picto image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderPicto" error:nil];
    UIImageView* image = [[UIImageView alloc] initWithImage:[sheet image]];
    CGFloat x = self.view.frame.origin.x + self.view.frame.size.width - sheet.frame.size.width;
    image.frame = CGRectMake(x, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
    [_headerView addSubview:image];
    
    
    // header back arrow
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderBack" error:nil];
    UIButton* btn = [sheet makeButton];
    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:btn];
    
    // header avatar, as a second back button
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderAvatar" error:nil];
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
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderAvatarMask" error:nil];
    btn = [[UIButton alloc] initWithFrame:sheet.frame];
    [btn setImage:[sheet image] forState:UIControlStateNormal]; 
    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:btn];
    
    
    //    [btn.imageView addSubview:_radioImage];
    
    //    [btn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    //    [_headerView addSubview:btn];

    
    // header title
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderTitle" error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = self.radio.name;
    [_headerView addSubview:label];
    
    // header heart image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderHeart" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [_headerView addSubview:image];

    // header likes
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderLikes" error:nil];
    label = [sheet makeLabel];
    label.text = [NSString stringWithFormat:@"%d", [self.radio.likes integerValue]];
    [_headerView addSubview:label];
    
    // header headset image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderHeadSet" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [_headerView addSubview:image];
    
    // header listeners
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderListeners" error:nil];
    label = [sheet makeLabel];
    label.text = [NSString stringWithFormat:@"%d", [self.radio.listeners integerValue]];
    [_headerView addSubview:label];
    
    // header edit settings button
    //LBDEBUG
//    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderEditButton" error:nil];
//    btn = [sheet makeButton];
//    [btn addTarget:self action:@selector(onEdit:) forControlEvents:UIControlEventTouchUpInside];
//    [_headerView addSubview:btn];

    //play pause button
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderPlayPauseFrame" error:nil];
    CGRect frame = sheet.frame;
    _playPauseButton = [[UIButton alloc] initWithFrame:sheet.frame];
    [_playPauseButton addTarget:self action:@selector(onPlayPause:) forControlEvents:UIControlEventTouchUpInside];
    [_playPauseButton setImage:[UIImage imageNamed:@"btnPause.png"] forState:UIControlStateNormal];
    [_playPauseButton setImage:[UIImage imageNamed:@"btnPlay.png"] forState:UIControlStateSelected];
    [_headerView addSubview:_playPauseButton];
    
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

    
    // get the actual data from the server to update the GUI
    [self onUpdate:nil];
    
    [self EXAMPLE_NOWPLAYING];
    
    //Make sure the system follows our playback status
    // <=> Background audio playing
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];  
    [[AVAudioSession sharedInstance] setDelegate: self];
}


#pragma mark - AVAudioSession Delegate

- (void)beginInterruption
{
    [self pauseAudio];
}

- (void) endInterruptionWithFlags: (NSUInteger) flags
{
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume)
    {
        [self playAudio];    
    }
}


- (void)viewDidAppear:(BOOL)animated
{
#ifdef USE_FAKE_RADIO_URL
    NSURL* radiourl = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net:8000/ubik.mp3"];
#else
    NSURL* radiourl = self.radio.url;
#endif

    //LBDEBUG
    if (_gAudioStreamer != nil)
    {
        [_gAudioStreamer stop];
        [_gAudioStreamer release];
    }
    
    _gAudioStreamer = [[AudioStreamer alloc] initWithURL:radiourl];
    [_gAudioStreamer start];
//  self.audioStreamer = [[AudioStreamer alloc] initWithURL: radiourl];
//    [self.audioStreamer start];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioStreamNotif:) name:NOTIF_AUDIOSTREAM_ERROR object:nil];
    
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    // <=> background audio playing
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];    
    
    //....................................................................................
    //
    // data update timer
    //
    _timerUpdate = [NSTimer scheduledTimerWithTimeInterval:SERVER_DATA_REQUEST_TIMER target:self selector:@selector(onUpdate:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //End recieving events
    // <=> background audio playing
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    if ((_timerUpdate != nil) && [_timerUpdate isValid])
    {
        [_timerUpdate invalidate];
        _timerUpdate = nil;
    }
    
    if ((_timerFake != nil) && [_timerFake isValid])
    {
        [_timerFake invalidate];
        _timerFake = nil;
    }

    if ((_fakeNowPlayingTimer != nil) && [_fakeNowPlayingTimer isValid])
    {
        [_fakeNowPlayingTimer invalidate];
        _fakeNowPlayingTimer = nil;
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
    [_messageFont release];
    [super dealloc];
}







#pragma mark - Background Audio Playing


//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder 
{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event 
{
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) 
    {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) 
            [self playAudio];

        else if (event.subtype == UIEventSubtypeRemoteControlPause) 
            [self pauseAudio];

        else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) 
            [self onPlayPause:nil];
        
    }
}







//.................................................................................................
//
// EXAMPLE
//


- (void)EXAMPLE_NOWPLAYING
{
    //
    // NOW PLAYING
    //
    NSInteger randIndex = (rand() %5)+1;
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
    Song* song = [[Song alloc] init];
    song.metadata = [[SongMetadata alloc] init];
    song.metadata.name = @"Mon Titre à moi super remix de la mort";
    song.metadata.artist_name = @"Mon Artiste";
    
    NSLog(@"SONG '%@'  '%@'  ", song.metadata.name, song.metadata.artist_name);
    
//    song.metadata.image = image;
    [self setNowPlaying:song];
    
    //fake LBDEBUG
    _fakeNowPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onFakeNowPlayingTick:) userInfo:nil repeats:YES];
}

- (void)onFakeNowPlayingTick:(NSTimer*)timer
{
    NSInteger randIndex = (rand() %5)+1;
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
    
    if (_fakeNowPlayingIndex)
    {
        _fakeNowPlayingIndex = 0;
        Song* song = [[Song alloc] init];
        song.metadata = [[SongMetadata alloc] init];
        song.metadata.name = @"Mon Titre à moi super remix de la mort";
        song.metadata.artist_name = @"Mon Artiste";
        [self setNowPlaying:song];
    }
    else
    {
        _fakeNowPlayingIndex = 1;
        Song* song = [[Song alloc] init];
        song.metadata = [[SongMetadata alloc] init];
        song.metadata.name = @"Shabada song (feat. Prince)";
        song.metadata.artist_name = @"Macha Berger";
        [self setNowPlaying:song];
    }
    
    
}



- (void)EXAMPLE
{

    
    //
    // MESSAGES
    //
    NSInteger randIndex = (rand() %5)+1;
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
//    [self addMessage:@"Vivamus sodales adipiscing sapien." user:@"Tancrède" avatar:image date:@"2011-07-09 20h30" silent:YES];
    
    randIndex = (rand() %5)+1;
    image = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
//    [self addMessage:@"Vivamus auctor leo vel dui. Aliquam erat volutpat. Phasellus nibh. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Cras tempor." user:@"Gertrude"  avatar:image date:@"2011-07-09 19h30" silent:YES];
    
    randIndex = (rand() %5)+1;
    image = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
//    [self addMessage:@"Quisque facilisis erat a dui. Nam malesuada ornare dolor. Cras gravida, diam sit amet rhoncus ornare." user:@"Argeavielle"  avatar:image date:@"2011-07-09 18h30" silent:YES];
    
    randIndex = (rand() %5)+1;
    image = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
//    [self addMessage:@"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Morbi commodo, ipsum sed pharetra gravida, orci magna rhoncus neque, id pulvinar odio lorem non turpis. Nullam sit amet enim. Suspendisse id velit vitae ligula volutpat condimentum. Aliquam erat volutpat." user:@"Anthèlme"  avatar:image date:@"2011-07-09 20h30" silent:YES];

    [_tableView reloadData];
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onEXAMPLE_DELAYED:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(onEXAMPLE_DELAYED:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(onEXAMPLE_DELAYED:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(onEXAMPLE_DELAYED:) userInfo:nil repeats:NO];

    
    //
    // STATUS BAR
    //
    [self setStatusMessage:@"Mon message de status..."];
}


- (void)onEXAMPLE_DELAYED:(NSTimer*)timer
{
    NSInteger randIndex = (rand() %5)+1;
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
//    [self addMessage:@"Pellentesque sit amet sem et purus pretium consectetuer." user:@"Tancrède"  avatar:image date:@"2011-07-09 20h30" silent:NO];
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
    
  WallEvent* ev = nil;
  for (int i = [events count] - 1; i >= 0; i--)
  {
    ev  = [events objectAtIndex:i];
    
    if ([ev.type isEqualToString:@"M"])
    {
      if ((!_lastWallEventDate || [ev.start_date compare:_lastWallEventDate] == NSOrderedDescending))
      {
//        NSString* picturePath = ev.user.picture;
//        NSString* url = nil;
//        if (picturePath)
//        {
//          url = @"https://dev.yasound.com/";
//          url = [url stringByAppendingString:picturePath];
//        }
//        [self addMessage:ev.text user:ev.user.username avatar:url date:ev.start_date silent:YES];
        NSURL* url = [[YasoundDataProvider main] urlForPicture:ev.user.picture];
        [self addMessage:ev.text user:ev.user.name avatar:url date:ev.start_date silent:NO];
      }
    }
    else if ([ev.type isEqualToString:@"J"])
    {
      if ([ev.start_date compare:_lastWallEventDate] == NSOrderedDescending)
        [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se connecter", ev.user.name]];
        
    }
    else if ([ev.type isEqualToString:@"L"])
    {
      if ([ev.start_date compare:_lastWallEventDate] == NSOrderedDescending)
        [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se déconnecter", ev.user.name]];
    }
  }
  
  _lastWallEventDate = (ev != nil) ? ev.start_date : nil;
  _lastConnectionUpdateDate = [NSDate date];
  
//  [_tableView reloadData];
}

//LBDEBUG
//- (void)receiveRadio:(Radio*)r withInfo:(NSDictionary*)info
//{
//  NSError* error = [info valueForKey:@"error"];
//  if (!r)
//    return;
//  if (error)
//  {
//    NSLog(@"can't receive radio: %@", error.domain);
//    return;
//  }
//  
//  self.radio = r;
//  
//  // radio header picture
//  // header avatar
//
//  [self onUpdate:nil]; 
//}

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
    
    [UIView transitionWithView:_playingNowContainer
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ [_playingNowView removeFromSuperview]; [_playingNowContainer addSubview:view]; _playingNowView = view; }
                    completion:NULL];    
}


- (void)onNowPlayingTouched
{
    _trackInteractionViewDisplayed = YES;
    
    //LBDEBUG
    [_fakeNowPlayingTimer invalidate];
    _fakeNowPlayingTimer = nil;
    
    TrackInteractionView* view = [[TrackInteractionView alloc] initWithSong:_gNowPlayingSong target:self action:@selector(onTrackInteractionTouched)];

    [UIView transitionWithView:_playingNowContainer
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ [_playingNowView removeFromSuperview]; [_playingNowContainer addSubview:view]; _trackInteractionView = view; }
                    completion:NULL];    
}


- (void)onTrackInteractionTouched
{
    _trackInteractionViewDisplayed = NO;
    
    NowPlayingView* view = [[NowPlayingView alloc] initWithSong:_gNowPlayingSong target:self action:@selector(onNowPlayingTouched)];
    
    [UIView transitionWithView:_playingNowContainer
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ [_trackInteractionView removeFromSuperview]; [_playingNowContainer addSubview:view]; _playingNowView = view; }
                    completion:NULL];    
  
    //LBDEBUG
     _fakeNowPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onFakeNowPlayingTick:) userInfo:nil repeats:YES];
}





//.................................................................................................
//
// MESSAGES
//

- (void)addMessage:(NSString*)text user:(NSString*)user avatar:(NSURL*)avatarURL date:(NSDate*)date silent:(BOOL)silent
{
    WallMessage* m = [[WallMessage alloc] init];
    m.user = user;
    m.avatarURL = avatarURL;
    m.date = date;
    m.text = text;

    // compute the size of the text => will allow to update the cell's height dynamically
    CGSize suggestedSize = [m.text sizeWithFont:_messageFont constrainedToSize:CGSizeMake(_messageWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    m.textHeight = suggestedSize.height;

    [self.messages insertObject:m atIndex:0];
    
    if (!silent)
    {
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
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
    //    NSLog(@"number messages %d", [self.messages count]);
    return [self.messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    WallMessage* m = [self.messages objectAtIndex:indexPath.row];
    
    return m.textHeight + _cellMinHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"RadioViewCell";
    
    WallMessage* m = [self.messages objectAtIndex:indexPath.row];
    
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
    [self sendMessage:textField.text];
    textField.text = nil;
    return FALSE;
}


- (void)sendMessage:(NSString *)message
{
    [[YasoundDataProvider main] postWallMessage:message toRadio:self.radio target:self action:@selector(wallMessagePosted:withInfo:)];
}

- (void)wallMessagePosted:(NSString*)eventURL withInfo:(NSDictionary*)info
{
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

- (IBAction) onPlayPause:(id)sender
{
    if (!_playPauseButton.selected)
        [self pauseAudio];
    else
        [self playAudio];
}


- (void)playAudio
{
    _playPauseButton.selected = NO;
//    [self.audioStreamer start];
    [_gAudioStreamer start];

}

- (void)pauseAudio
{
    _playPauseButton.selected = YES;
//    [self.audioStreamer stop];
    [_gAudioStreamer stop];
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






#pragma mark - Notifications

- (void)onAudioStreamNotif:(NSNotification *)notification
{
    if ([notification.name isEqualToString:NOTIF_AUDIOSTREAM_ERROR])
    {
        [self setStatusMessage:NSLocalizedString(@"RadioView_status_message_audiostream_error", nil)];
        return;
    }
}






@end







//.................................................................................................
//
// DEPRECATED CODE
//









//- (void)requestStarted:(ASIHTTPRequest *)request
//{
//    NSLog(@"requestStarted");
//}

//- (void)requestFailed:(ASIHTTPRequest *)request
//{
//    NSLog(@"RadioViewController update requestFailed");
//}


//- (void)requestFinished:(ASIHTTPRequest *)request
//{
//    NSLog(@"Request sent, response we got: \n%@\n\n", request.responseString);
//    NSLog(@"status message: %@\n\n", request.responseStatusMessage);
//    NSLog(@"cookies: %@\n\n", request.responseCookies);
//    
//    //clean message arrays
//    [self.messages removeAllObjects];
//    
//    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:request.responseData];
//    [parser setDelegate:self];
//    [parser parse];
//    
//    [_tableView reloadData];    
//}








//
//#pragma mark - NSXLMParser Delegate
//
//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
//{
//    //NSLog(@"XML start element: %@", elementName);
//    
//    if ( [elementName isEqualToString:@"post"]) 
//        _currentMessage = [[Message alloc] init];
//        }
//
//
//- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
//{
//    if (!_currentXMLString)
//        _currentXMLString = [[NSMutableString alloc] initWithCapacity:50];
//        
//        [_currentXMLString appendString:string];
//}
//
//
//
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
//{
//    NSString* str = [_currentXMLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    //NSLog(@"XML end element: %@", elementName);
//    
//    if ([elementName isEqualToString:@"post"]) 
//    {
//        if ([self.messages count] < _currentMessage.identifier - 1)
//        {
//            //NSLog(@"New post: %d\n", _currentMessage.identifier);
//            
//            WallMessage* m = [[Message alloc] init];
//            m.user = _currentMessage.user;
//            m.date = _currentMessage.date;
//            m.text = _currentMessage.text;
//            
//            // compute the size of the text => will allow to update the cell's height dynamically
//            CGSize suggestedSize = [m.text sizeWithFont:_messageFont constrainedToSize:CGSizeMake(_messageWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
//            m.textHeight = suggestedSize.height;
//            
//            
//            [self.messages insertObject:m atIndex:0];
//        }
//        else
//            [_currentMessage release];
//        _currentMessage = nil;
//    }
//    else if ([elementName isEqualToString:@"id"]) 
//    {
//        _currentMessage.identifier = str.intValue;
//    }
//    else if ([elementName isEqualToString:@"kind"]) 
//    {
//        _currentMessage.kind = str;
//    }
//    else if ([elementName isEqualToString:@"author"]) 
//    {
//        _currentMessage.user = str;
//    }
//    else if ([elementName isEqualToString:@"date"]) 
//    {
//        _currentMessage.date = str;
//    }
//    else if ([elementName isEqualToString:@"message"]) 
//    {
//        _currentMessage.text = str;
//    }
//    
//    [_currentXMLString release];
//    _currentXMLString = nil;
//}







