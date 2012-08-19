//
//  TopBarSaveOrCancel.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TopBarSaveOrCancelDelegate <NSObject>
- (BOOL)topBarSave;
- (BOOL)topBarCancel;
@end


@interface TopBarSaveOrCancel : UIToolbar

@property (nonatomic, retain) IBOutlet id<TopBarSaveOrCancelDelegate> delegate;

@end
