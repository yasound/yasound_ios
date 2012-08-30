//
//  WheelSelector.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "OrientedTableView.h"

//typedef enum WheelItemId
//{
//    WheelIdFavorites = 0,
//    WheelIdSelection,
//    WheelIdFriends,
//    WheelIdTop
//} WheelItemId;

@class WheelSelector;

@protocol WheelSelectorDelegate <NSObject>
- (NSInteger)numberOfItemsInWheelSelector:(WheelSelector*)wheel;
- (NSString*)wheelSelector:(WheelSelector*)wheel titleForItem:(NSInteger)itemIndex;
- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex;
- (NSInteger)initIndexForWheelSelector:(WheelSelector*)wheel;
@end



@interface WheelSelector : UIScrollView

@property (nonatomic) BOOL locked;
@property (nonatomic, retain) IBOutlet id<WheelSelectorDelegate> wheelDelegate;
@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, retain) NSMutableDictionary* itemToIndex;
@property (nonatomic) BOOL needsToStick;
@property (nonatomic) BOOL tapRegistered;
@property (nonatomic) NSInteger currentIndex;


- (void)stickToItem:(NSString*)itemId silent:(BOOL)silent;


@end
