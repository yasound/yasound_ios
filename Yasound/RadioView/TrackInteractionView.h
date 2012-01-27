//
//  TrackInteractionView.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song2.h"


@interface TrackInteractionView : UIView
{
    Song2* _song;
    
    BOOL _sharing;
}

- (id)initWithSong:(Song2*)song;

@end

