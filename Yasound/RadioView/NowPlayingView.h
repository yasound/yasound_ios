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
}

@property (nonatomic, retain) UIButton* playPauseButton;

- (id)initWithSong:(Song*)song target:(id)target action:(SEL)action;

@end
