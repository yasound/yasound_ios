//
//  WheelSelector.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "OrientedTableView.h"

typedef enum WheelItemId
{
    WheelIdFavorites = 0,
    WheelIdSelection,
    WheelIdFriends,
    WheelIdTop
} WheelItemId;

@protocol WheelSelectorDelegate <NSObject>
- (void)wheelSelectorDidSelect:(NSInteger)index;
@end



@interface WheelSelector : UIScrollView

@property (nonatomic, retain) IBOutlet id<WheelSelectorDelegate> wheelDelegate;
@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic) BOOL needsToStick;

- (void)init;
- (void)stickToItem:(NSInteger)itemIndex;


@end
