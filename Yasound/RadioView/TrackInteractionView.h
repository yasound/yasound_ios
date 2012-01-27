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
    Song* _song;
    
    BOOL _sharing;
}

- (id)initWithSong:(Song*)song;

@end

