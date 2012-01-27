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

@interface NowPlayingView (internal)

- (void) onUpdate:(NSTimer*)timer;

@end


@implementation NowPlayingView

@synthesize playPauseButton;


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
        
        //grabber
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarGrabber" error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
        
        
        // fake image
        UIImage* image = [UIImage imageNamed:@"TrackImageDummy.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
        
        // header now playing bar track image 
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImage" error:nil];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
//        // header now playing bar track image mask
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarMask" error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
        // header now playing bar label
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarLabel" error:nil];
        UILabel* label = [sheet makeLabel];
        [self addSubview:label];
        
        // header now playing bar artist
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarArtist" error:nil];
        label = [sheet makeLabel];
        label.text = song.artist;
        [self addSubview:label];
        
        // header now playing bar title
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarTitle" error:nil];
        label = [sheet makeLabel];
        label.text = song.name;
        [self addSubview:label];
        
        // header now playing bar likes image
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarLikesImage" error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
        // header now playing bar likes
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarLikes" error:nil];
        _likesLabel = [sheet makeLabel];
        _likesLabel.text = @"0";
        [self addSubview:_likesLabel];
        
        // header now playing bar dislikes image
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarDislikesImage" error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
        // header now playing bar dislikes
        sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarDislikes" error:nil];
        _dislikesLabel = [sheet makeLabel];
        _dislikesLabel.text = @"0";
        [self addSubview:_dislikesLabel];
        
        
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
        
      [self onUpdate:nil];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onUpdate:) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void) onUpdate:(NSTimer*)timer
{
  [[YasoundDataProvider main] statusForSongId:_song.id target:self action:@selector(receiveStatus:withInfo:)];
}

- (void)receiveStatus:(SongStatus*)status withInfo:(NSDictionary*)info
{
    _likesLabel.text = [NSString stringWithFormat:@"%d", [status.likes intValue]];
    _dislikesLabel.text = [NSString stringWithFormat:@"%d", [status.dislikes intValue]];
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




