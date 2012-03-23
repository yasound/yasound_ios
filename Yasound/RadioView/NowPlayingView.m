//
//  NowPlayingView.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "NowPlayingView.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "YasoundDataProvider.h"
#import "ScrollingLabel.h"

@interface NowPlayingView (internal)

- (void) onUpdate:(NSTimer*)timer;

@end


@implementation NowPlayingView

//@synthesize playPauseButton;
@synthesize song = _song;


//LBDEBUG TODO : use image, likes disklikes from Song

- (id)initWithSong:(Song*)song
{
    if (self = [super init])
    {
        _song = song;
      _userLikesSong = NO;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        
        CGRect frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
        self.frame = frame;

        UIImageView* imageView = nil;
        
//        //grabber
//        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarGrabber" error:nil];
//        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
//        imageView.frame = sheet.frame;
//        [self addSubview:imageView];
        
        _webImageView = nil;
        
        
      NSLog(@"now playing song cover '%@'", song.cover);
      if (song.cover)
      {        
        NSURL* url = [[YasoundDataProvider main] urlForPicture:song.cover];
        _webImageView = [[WebImageView alloc] initWithImageAtURL:url];
          imageView = _webImageView;
      }
      else
      {
        // fake image
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
      }
        
        
        // header now playing bar track image 
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImage" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
//        // header now playing bar track image mask
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
        // header now playing bar info (artist - title)
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarInfo" error:nil];
        ScrollingLabel* title = [[ScrollingLabel alloc] initWithStyle:@"NowPlayingBarInfo"];
        title.text = [NSString stringWithFormat:@"%@ - %@", song.artist, song.name];
        title.frame = sheet.frame;
        [self addSubview:title];
                                 
        
//        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarInfo" error:nil];
//        UILabel* label = [sheet makeLabel];
//        label.text = [NSString stringWithFormat:@"%@ - %@", song.artist, song.name];
//        [self addSubview:label];
        
        
        // track interaction buttons
        _trackInteractionView = [[TrackInteractionView alloc] initWithSong:song];
        _trackInteractionView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [_trackInteractionView setButtonLikeClickedTarget:self action:@selector(trackInteractionViewLikeButtonCliked)];
        [self addSubview:_trackInteractionView];
        
        // header now playing bar likes
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarLikes" error:nil];
        _likesLabel = [sheet makeLabel];
        [self setNbLikes:0];

        _likesLabel.adjustsFontSizeToFitWidth = YES;
        _likesLabel.minimumFontSize = 8.0;

        
        [self addSubview:_likesLabel];  
      
      [[YasoundDataProvider main] songUserForSong:_song target:self action:@selector(receivedSongUser:withInfo:)];
        
        
        
        
        
//        //play pause button
//        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingPlayPauseFrame" error:nil];
//        frame = sheet.frame;
//        self.playPauseButton = [[UIButton alloc] initWithFrame:sheet.frame];
//        
//        NSString* tmppath = [[Theme theme] pathForResource:@"btnPauseUp" ofType:@"png" inDirectory:@"images/Header/Buttons"];
//        UIImage* imageFile = [UIImage imageWithContentsOfFile:tmppath];
//        [self.playPauseButton setImage:imageFile forState:UIControlStateNormal];
//
//        tmppath = [[Theme theme] pathForResource:@"btnPauseDown" ofType:@"png" inDirectory:@"images/Header/Buttons"];
//        imageFile = [UIImage imageWithContentsOfFile:tmppath];
//        [self.playPauseButton setImage:imageFile forState:UIControlStateNormal|UIControlStateHighlighted];
//        
//        tmppath = [[Theme theme] pathForResource:@"btnPlayUp" ofType:@"png" inDirectory:@"images/Header/Buttons"];
//        imageFile = [UIImage imageWithContentsOfFile:tmppath];
//        [self.playPauseButton setImage:imageFile forState:UIControlStateSelected];
//
//        tmppath = [[Theme theme] pathForResource:@"btnPlayDown" ofType:@"png" inDirectory:@"images/Header/Buttons"];
//        imageFile = [UIImage imageWithContentsOfFile:tmppath];
//        [self.playPauseButton setImage:imageFile forState:UIControlStateSelected|UIControlStateHighlighted];
//        
//        [self addSubview:self.playPauseButton];
    }
    
    return self;
}

- (void)dealloc
{
    if (_webImageView)
        [_webImageView release];
    [_trackInteractionView release];
    [super dealloc];
}

- (void)setNbLikes:(int)nbLikes
{
    _likesLabel.text = [NSString stringWithFormat:@"%d", nbLikes];
}

- (void)setSongStatus:(SongStatus*)status
{
  [self setNbLikes:[status.likes intValue]];

//    _dislikesLabel.text = [NSString stringWithFormat:@"%d", [status.dislikes intValue]];
}

- (void)trackInteractionViewLikeButtonCliked
{
  if (_userLikesSong)
    return; // already likes this song
  
  int nbLikes = [_likesLabel.text intValue];
  nbLikes++;
  [self setNbLikes:nbLikes];
  _userLikesSong = YES;
}

- (void)receivedSongUser:(SongUser*)songUser withInfo:(NSDictionary*)info
{
  if (!songUser)
    return;
  
  _userLikesSong = ([songUser userMood] == eMoodLike);
}



@end




