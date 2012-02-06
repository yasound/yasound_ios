//
//  NowPlayingView.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "Song.h"

@interface NowPlayingView : UIView
{
    id _target;
    SEL _action;
    Song* _song;
    UILabel* _likesLabel;
  NSTimer* _timer;
}

@property (nonatomic, retain) UIButton* playPauseButton;
@property (nonatomic, retain) Song* song;

- (id)initWithSong:(Song*)song target:(id)target action:(SEL)action;

- (void)setSongStatus:(SongStatus*)status;

@end
