//
//  WheelSelector.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "OrientedTableView.h"

enum WheelItemId
{
    WheelIdFavorites = 0,
    WheelIdGenre,
    WheelIdSelection,
    WheelIdFriends,
    WheelIdTop
};

@protocol WheelSelectorDelegate <NSObject>
- (void)wheelSelectorDidSelect:(NSInteger)index;
@end



@interface WheelSelector : UIScrollView

@property (nonatomic, retain) IBOutlet id<WheelSelectorDelegate> wheelDelegate;
@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic) BOOL needsToStick;

@end
