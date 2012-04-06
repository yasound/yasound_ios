//
//  TrackInteractionView.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"


@interface TrackInteractionView : UIView <UIAlertViewDelegate>
{
    Song* _song;
    
    BOOL _sharingFacebook;
    BOOL _sharingTwitter;
  
  id _buttonLikedClickedTarget;
  SEL _buttonLikedClickedAction;
}

@property (nonatomic, retain) NSString* shareFullMessage;

- (id)initWithSong:(Song*)song;
- (void)setButtonLikeClickedTarget:(id)target action:(SEL)action;

@end

