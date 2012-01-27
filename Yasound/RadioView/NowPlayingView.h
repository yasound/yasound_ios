//
//  NowPlayingView.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "Song2.h"

@interface NowPlayingView : UIView
{
    id _target;
    SEL _action;
    Song2* _song;
    UILabel* _likesLabel;
    UILabel* _dislikesLabel;
}

@property (nonatomic, retain) UIButton* playPauseButton;

- (id)initWithSong:(Song2*)song target:(id)target action:(SEL)action;

@end
