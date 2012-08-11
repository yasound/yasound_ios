//
//  TopBarBackAndTitle.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TopBarBackAndTitleDelegate <NSObject>
- (void)topBarBack;
- (NSString*)topBarTitle;
- (UIView*)topBarTitleView;
@end


@interface TopBarBackAndTitle : UIToolbar

@property (nonatomic, retain) IBOutlet id<TopBarBackAndTitleDelegate> delegate;
@property (nonatomic, retain) NSMutableArray* customItems;

- (void)showAddItem;

@end
