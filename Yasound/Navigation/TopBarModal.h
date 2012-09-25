//
//  TopBarModal.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TopBarModalDelegate <NSObject>
- (BOOL)topBarSave;
- (BOOL)topBarCancel;

- (BOOL)shouldShowActionButton;
- (NSString*)titleForActionButton;
- (NSString*)titleForCancelButton;
- (UIColor*)tintForActionButton;

- (NSString*)topBarModalTitle;
@end


@interface TopBarModal : UIToolbar

@property (nonatomic, retain) IBOutlet id<TopBarModalDelegate> delegate;
@property (nonatomic, retain) UIBarButtonItem* actionButton;

- (void)hideCancelButton;

@end
