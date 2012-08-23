//
//  TopBar.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 18/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TopBarItemId
{
    TopBarItemMenu = 0,
    TopBarItemBack,
    TopBarItemHd,
    TopBarItemNotif,
    TopBarItemSettings,
    TopBarItemTrash,
    TopBarItemAdd,
    TopBarItemNowPlaying,
    TopBarItemNone
} TopBarItemId;

@protocol TopBarDelegate <NSObject>
- (BOOL)topBarItemClicked:(TopBarItemId)itemId;
@end


@interface TopBar : UIToolbar

@property (nonatomic, retain) IBOutlet id<TopBarDelegate> delegate;
@property (nonatomic, retain) NSMutableArray* customItems;

@property (nonatomic, assign) UIButton* itemHdButton;
@property (nonatomic, retain) UIBarButtonItem* itemHd;


- (void)hideBackItem:(BOOL)hide;
- (void)showSettingsItem:(BOOL)enabled;
- (void)showTrashItem;
- (void)showMenuItem;
- (void)showAddItem;

- (void)runItem:(TopBarItemId)itemId;

@end
