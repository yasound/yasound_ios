//
//  TabBar.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 20/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TabBarDelegate <NSObject>
- (void)tabBarBackDidSelect:(NSInteger)tabIndex;
@end

@interface TabBar : UIView

@property (nonatomic, retain) IBOutlet id<TabBarDelegate> delegate;
@property (nonatomic, retain) NSMutableArray* buttons;

@end
