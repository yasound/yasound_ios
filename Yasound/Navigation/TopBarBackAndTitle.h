//
//  TopBarBackAndTitle.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TopBarBackAndTitleDelegate <NSObject>
- (BOOL)topBarBackClicked;
- (NSString*)topBarTitle;
- (UIView*)topBarTitleView;
@end


@interface TopBarBackAndTitle : UIToolbar

@property (nonatomic, retain) IBOutlet id<TopBarBackAndTitleDelegate> delegate;
@property (nonatomic, retain) NSMutableArray* customItems;

- (void)showAddItemWithTarget:(id)target action:(SEL)action;
- (void)showEditItemWithTarget:(id)target action:(SEL)action;

@end
