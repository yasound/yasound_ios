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
#import "TrackInteractionView.h"

@interface NowPlayingView (internal)

- (void) onUpdate:(NSTimer*)timer;

@end


@implementation NowPlayingView

@synthesize playPauseButton;
@synthesize song = _song;


//LBDEBUG TODO : use image, likes disklikes from Song

- (id)initWithSong:(Song*)song target:(id)target action:(SEL)action
{
    if (self = [super init])
    {
        _target = target;
        _action = action;
        
        _song = song;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        
        CGRect frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
        self.frame = frame;

        UIImageView* imageView = nil;
        
//        //grabber
//        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarGrabber" error:nil];
//        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
//        imageView.frame = sheet.frame;
//        [self addSubview:imageView];
        
        
        
        
      NSLog(@"now playing song cover '%@'", song.cover);
      if (song.cover)
      {        
        NSURL* url = [[YasoundDataProvider main] urlForPicture:song.cover];
        imageView = [[WebImageView alloc] initWithImageAtURL:url];
      }
      else
      {
        // fake image
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
      }
        
        
        // header now playing bar track image 
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImage" error:nil];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
//        // header now playing bar track image mask
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarMask" error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
        // header now playing bar info (artist - title)
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarInfo" error:nil];
        UILabel* label = [sheet makeLabel];
        label.text = [NSString stringWithFormat:@"%@ - %@", song.artist, song.name];
        [self addSubview:label];
        
        
        // track interaction buttons
        TrackInteractionView* trackInteractionView = [[TrackInteractionView alloc] initWithSong:song];
        trackInteractionView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:trackInteractionView];
        
        // header now playing bar likes
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarLikes" error:nil];
        _likesLabel = [sheet makeLabel];
        _likesLabel.text = @"0";
        
        if (_likesLabel.text.length > 4)
            _likesLabel.font = [_likesLabel.font fontWithSize:9];
        else if (_likesLabel.text.length > 3)
            _likesLabel.font = [_likesLabel.font fontWithSize:10];
        else if (_likesLabel.text.length > 2)
            _likesLabel.font = [_likesLabel.font fontWithSize:11];
        else 
            _likesLabel.font = [_likesLabel.font fontWithSize:13];
        
        
        [self addSubview:_likesLabel];        
        
        
        
        
        
        //play pause button
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingPlayPauseFrame" error:nil];
        frame = sheet.frame;
        self.playPauseButton = [[UIButton alloc] initWithFrame:sheet.frame];
        
        NSString* tmppath = [[Theme theme] pathForResource:@"btnPause" ofType:@"png" inDirectory:@"images/Header/Buttons"];
        UIImage* imageFile = [UIImage imageWithContentsOfFile:tmppath];
        [self.playPauseButton setImage:imageFile forState:UIControlStateNormal];
        
        tmppath = [[Theme theme] pathForResource:@"btnPlay" ofType:@"png" inDirectory:@"images/Header/Buttons"];
        imageFile = [UIImage imageWithContentsOfFile:tmppath];
        [self.playPauseButton setImage:imageFile forState:UIControlStateSelected];
        
        [self addSubview:self.playPauseButton];
    }
    
    return self;
}

- (void)setSongStatus:(SongStatus*)status
{
    _likesLabel.text = [NSString stringWithFormat:@"%d", [status.likes intValue]];

    if (_likesLabel.text.length > 4)
        _likesLabel.font = [_likesLabel.font fontWithSize:9];
    else if (_likesLabel.text.length > 3)
        _likesLabel.font = [_likesLabel.font fontWithSize:10];
    else if (_likesLabel.text.length > 2)
        _likesLabel.font = [_likesLabel.font fontWithSize:11];
    else 
        _likesLabel.font = [_likesLabel.font fontWithSize:13];

//    _dislikesLabel.text = [NSString stringWithFormat:@"%d", [status.dislikes intValue]];
}


#pragma mark - touches actions



//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//    UITouch *aTouch = [touches anyObject];
//    
//    if (aTouch.tapCount == 2) 
//    
//}
//



//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//    
//}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *theTouch = [touches anyObject];
    [_target performSelector:_action];
}




@end




