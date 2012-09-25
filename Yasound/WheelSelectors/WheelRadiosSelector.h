//
//  WheelRadiosSelector.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum WheelRadiosItemId
{
    WheelIdFavorites = 0,
    WheelIdSelection,
    WheelIdTop,
    WheelIdMyRadios,
    WheelIdFriends,
    WheelRadiosNbItems
} WheelItemId;


#define WheelIdMyRadiosTitle NSLocalizedString(@"WheelSelector_MyRadios", nil)
#define WheelIdFavoritesTitle NSLocalizedString(@"WheelSelector_Favorites", nil)
#define WheelIdSelectionTitle NSLocalizedString(@"WheelSelector_Selection", nil)
#define WheelIdFriendsTitle NSLocalizedString(@"WheelSelector_Friends", nil)
#define WheelIdTopTitle NSLocalizedString(@"WheelSelector_Top", nil)
