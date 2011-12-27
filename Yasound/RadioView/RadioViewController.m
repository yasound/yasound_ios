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

//#define LOCAL 1 // use localhost as the server

#define SERVER_DATA_REQUEST_TIMER 5.0f

@implementation RadioViewController

@synthesize radio;
@synthesize audioStreamer;
@synthesize messages;
@synthesize statusMessages;


- (id)init
{
    self = [super init];
    if (self) 
    {
//        self.radio = [[Radio alloc] init];
//        self.radio.id = [NSNumber numberWithInt:1];
      
      _lastWallEventDate = nil;
      _lastConnectionUpdateDate = [NSDate date];
      _lastSongUpdateDate = nil;
      [[YasoundDataProvider main] radioWithID:1 target:self action:@selector(receiveRadio:withInfo:)];

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

- (void)userLogged:(User*)u withInfo:(NSDictionary*)info
{
  NSError* error = [info valueForKey:@"error"];
  NSLog(@"logged user '%@'", u.username);
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
    
    // header avatar
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderAvatar" error:nil];
    _radioImage = [[WebImageView alloc] initWithImageFrame:sheet.frame];
    [_headerView addSubview:_radioImage];
    
    // header avatar mask
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderAvatarMask" error:nil];
    UIImageView* avatarMask = [[UIImageView alloc] initWithImage:[sheet image]];
    avatarMask.frame = sheet.frame;
    [_headerView addSubview:avatarMask];
    
    // header title
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderTitle" error:nil];
    UILabel* label = [sheet makeLabel];
    [_headerView addSubview:label];
    
    // header heart image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderHeart" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [_headerView addSubview:image];

    // header likes
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderLikes" error:nil];
    label = [sheet makeLabel];
    [_headerView addSubview:label];
    
    // header headset image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderHeadSet" error:nil];
    image = [[UIImageView alloc] initWithImage:[sheet image]];
    image.frame = sheet.frame;
    [_headerView addSubview:image];
    
    // header listeners
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderListeners" error:nil];
    label = [sheet makeLabel];
    [_headerView addSubview:label];
    
    // header edit settings button
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderEditButton" error:nil];
    btn = [sheet makeButton];
    [btn addTarget:self action:@selector(onEdit:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:btn];

    
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
    
//    [self EXAMPLE];
}



- (void)viewDidAppear:(BOOL)animated
{
    
  NSURL* radiourl = [NSURL URLWithString:@"http://ys-web01-vbo.alionis.net:8000/ubik.mp3"];
  self.audioStreamer = [[AudioStreamer alloc] initWithURL: radiourl];
  [self.audioStreamer start];
    
    //....................................................................................
    //
    // data update timer
    //
    _timerUpdate = [NSTimer scheduledTimerWithTimeInterval:SERVER_DATA_REQUEST_TIMER target:self selector:@selector(onUpdate:) userInfo:nil repeats:YES];    

    // LBDEBUG fake timer for status messages
//    [self onFakeUpdateStatus:nil];
//    _timerFake = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(onFakeUpdateStatus:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [audioStreamer stop];
    
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
















//.................................................................................................
//
// EXAMPLE
//

- (void)EXAMPLE
{
    //
    // NOW PLAYING
    //
    NSInteger randIndex = (rand() %5)+1;
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
    [self setNowPlaying:@"Mon Titre à moi super remix de la mort" artist:@"Mon Artiste" image:image nbLikes:1234 nbDislikes:12345];
    
    
    //
    // MESSAGES
    //
    randIndex = (rand() %5)+1;
    image = [UIImage imageNamed:[NSString stringWithFormat:@"avatarDummy%d.png", randIndex]];
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
        [self addMessage:ev.text user:ev.user.username avatar:url date:ev.start_date silent:NO];
      }
    }
    else if ([ev.type isEqualToString:@"J"])
    {
      if ([ev.start_date compare:_lastWallEventDate] == NSOrderedDescending)
        [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se connecter", ev.user.username]];
        
    }
    else if ([ev.type isEqualToString:@"L"])
    {
      if ([ev.start_date compare:_lastWallEventDate] == NSOrderedDescending)
        [self setStatusMessage:[NSString stringWithFormat:@"%@ vient de se déconnecter", ev.user.username]];
    }
  }
  
  _lastWallEventDate = (ev != nil) ? ev.start_date : nil;
  _lastConnectionUpdateDate = [NSDate date];
  
//  [_tableView reloadData];
}

- (void)receiveRadio:(Radio*)r withInfo:(NSDictionary*)info
{
  NSError* error = [info valueForKey:@"error"];
  if (!r)
    return;
  if (error)
  {
    NSLog(@"can't receive radio: %@", error.domain);
    return;
  }
  
  self.radio = r;
  
  
  // radio header picture
  // header avatar
  
  NSURL* imageURL = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
  [_radioImage setUrl:imageURL];

  [self onUpdate:nil]; 
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
    [self setNowPlaying:ev.song.metadata.name artist:ev.song.metadata.artist_name image:nil nbLikes:0 nbDislikes:0];
    _lastSongUpdateDate = ev.start_date;
  }
  
  
}












//.................................................................................................
//
// NOW PLAYING
//


#pragma mark - Now Playing

- (void)setNowPlaying:(NSString*)title artist:(NSString*)artist image:(UIImage*)image nbLikes:(NSInteger)nbLikes nbDislikes:(NSInteger)nbDislikes
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];

    CGRect frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
    UIView* view = [[UIView alloc] initWithFrame:frame];
                    
    // header now playing bar track image 
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarImage" error:nil];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = sheet.frame;
    [view addSubview:imageView];
    
    // header now playing bar track image mask
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarMask" error:nil];
    imageView = [[UIImageView alloc] initWithImage:[sheet image]];
    imageView.frame = sheet.frame;
    [view addSubview:imageView];
    
    
    // header now playing bar label
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarLabel" error:nil];
    UILabel* label = [sheet makeLabel];
    [view addSubview:label];
    
    // header now playing bar artist
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarArtist" error:nil];
    label = [sheet makeLabel];
    label.text = artist;
    [view addSubview:label];
    
    // header now playing bar title
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarTitle" error:nil];
    label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    // header now playing bar likes image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarLikesImage" error:nil];
    imageView = [[UIImageView alloc] initWithImage:[sheet image]];
    imageView.frame = sheet.frame;
    [view addSubview:imageView];
    
    // header now playing bar likes
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarLikes" error:nil];
    label = [sheet makeLabel];
    label.text = [NSString stringWithFormat:@"%d", nbLikes];
    [view addSubview:label];
    
    // header now playing bar dislikes image
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarDislikesImage" error:nil];
    imageView = [[UIImageView alloc] initWithImage:[sheet image]];
    imageView.frame = sheet.frame;
    [view addSubview:imageView];
    
    // header now playing bar dislikes
    sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarDislikes" error:nil];
    label = [sheet makeLabel];
    label.text = [NSString stringWithFormat:@"%d", nbDislikes];
    [view addSubview:label];
    
    [UIView transitionWithView:_playingNowContainer
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ [_playingNowView removeFromSuperview]; [_playingNowContainer addSubview:view]; }
                    completion:NULL];
    
    _playingNowView = view;
    
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
  User* user = [[User alloc] init];
  user.id = [NSNumber numberWithInt:1];
  
  WallEvent* msg = [[WallEvent alloc] init];
  msg.user = user;
  msg.radio = self.radio;
  msg.start_date = [NSDate date];
  msg.end_date = [NSDate date];
  msg.type = @"M";
  msg.text = message;
  
  [[YasoundDataProvider main] postNewWallMessage:msg target:self action:@selector(wallMessagePosted:withInfo:)];
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


- (IBAction) onEdit:(id)sender
{
    
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







