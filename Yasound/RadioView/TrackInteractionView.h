//
//  TrackInteractionView.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"


@interface TrackInteractionView : UIView
{
    id _target;
    SEL _action;
    Song* _song;
}

- (id)initWithSong:(Song*)song target:(id)target action:(SEL)action;

@end

