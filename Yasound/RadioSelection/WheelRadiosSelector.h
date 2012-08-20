//
//  WheelRadiosSelector.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum WheelRadiosItemId
{
    WheelIdSelection = 0,
    WheelIdTop,
    WheelIdFavorites,
    WheelIdFriends,
    WheelRadiosNbItems
} WheelItemId;


#define WheelIdFavoritesTitle NSLocalizedString(@"WheelSelector_Favorites", nil)
#define WheelIdSelectionTitle NSLocalizedString(@"WheelSelector_Selection", nil)
#define WheelIdFriendsTitle NSLocalizedString(@"WheelSelector_Friends", nil)
#define WheelIdTopTitle NSLocalizedString(@"WheelSelector_Top", nil)

