//
//  WheelSelector.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "OrientedTableView.h"

#define WHEEL_ID_FAVORITES 0
#define WHEEL_ID_GENRE 1
#define WHEEL_ID_SELECTION 2
#define WHEEL_ID_FRIENDS 3
#define WHEEL_ID_TOP 4

@protocol WheelSelectorDelegate <NSObject>
- (void)wheelSelectorDidSelect:(NSInteger)index;
@end



@interface WheelSelector : UIScrollView

@property (nonatomic, retain) IBOutlet id<WheelSelectorDelegate> wheelDelegate;
@property (nonatomic, retain) NSMutableArray* items;

@end
