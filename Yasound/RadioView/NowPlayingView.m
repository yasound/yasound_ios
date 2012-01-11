//
//  NowPlayingView.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "NowPlayingView.h"
#import "BundleFileManager.h"
#import "Theme.h"


@implementation NowPlayingView


//LBDEBUG TODO : use image, likes disklikes from Song

- (id)initWithSong:(Song*)song target:(id)target action:(SEL)action
{
    if (self = [super init])
    {
        _target = target;
        _action = action;
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        
        CGRect frame = CGRectMake(0, 0, sheet.frame.size.width, sheet.frame.size.height);
        self.frame = frame;
        
        UIImageView* imageView = nil;
        
        // header now playing bar track image 
//        sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarImage" error:nil];
//        imageView = [[UIImageView alloc] initWithImage:image];
//        imageView.frame = sheet.frame;
//        [self addSubview:imageView];
        
        // header now playing bar track image mask
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarMask" error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
        
        // header now playing bar label
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarLabel" error:nil];
        UILabel* label = [sheet makeLabel];
        [self addSubview:label];
        
        // header now playing bar artist
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarArtist" error:nil];
        label = [sheet makeLabel];
        label.text = song.metadata.artist_name;
        [self addSubview:label];
        
        // header now playing bar title
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarTitle" error:nil];
        label = [sheet makeLabel];
        label.text = song.metadata.name;
        [self addSubview:label];
        
        // header now playing bar likes image
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarLikesImage" error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
        // header now playing bar likes
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarLikes" error:nil];
        label = [sheet makeLabel];
//        label.text = [NSString stringWithFormat:@"%d", nbLikes];
        label.text = [NSString stringWithFormat:@"%d", 4321];
        [self addSubview:label];
        
        // header now playing bar dislikes image
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarDislikesImage" error:nil];
        imageView = [[UIImageView alloc] initWithImage:[sheet image]];
        imageView.frame = sheet.frame;
        [self addSubview:imageView];
        
        // header now playing bar dislikes
        sheet = [[Theme theme] stylesheetForKey:@"RadioViewHeaderNowPlayingBarDislikes" error:nil];
        label = [sheet makeLabel];
//        label.text = [NSString stringWithFormat:@"%d", nbDislikes];
        label.text = [NSString stringWithFormat:@"%d", 1234];
        [self addSubview:label];
    }
    
    return self;
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




