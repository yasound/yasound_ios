//
//  NowPlayingView.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "Song.h"
#import "TrackInteractionView.h"

@interface NowPlayingView : UIView
{
    Song* _song;
    UILabel* _likesLabel;
  NSTimer* _timer;
  BOOL _userLikesSong;
    WebImageView* _webImageView;
    TrackInteractionView* _trackInteractionView;
}

//@property (nonatomic, retain) UIButton* playPauseButton;
@property (nonatomic, retain) Song* song;

- (id)initWithSong:(Song*)song;

- (void)setSongStatus:(SongStatus*)status;

@end
