//
//  TabBar.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 20/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

enum TabIndex
{
    TabIndexSelection = 0,
    TabIndexFavorites,
    TabIndexMyRadios,
    TabIndexGifts,
    TabIndexProfil
};



@protocol TabBarDelegate <NSObject>
- (void)tabBarBackDidSelect:(NSInteger)tabIndex;

@end

@interface TabBar : UIView

@property (nonatomic, retain) IBOutlet id<TabBarDelegate> tabBarDelegate;
@property (nonatomic, retain) NSMutableArray* buttons;
@property (nonatomic, retain) UIButton* selectedButton;

- (void)setTabSelected:(NSInteger)tabIndex;

@end
