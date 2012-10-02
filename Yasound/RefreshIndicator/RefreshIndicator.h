//
//  RefreshIndicator.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    eStatusClosed = 0,
    eStatusWaitingToClose,
    eStatusPulled,
    eStatusOpened
    
} RefreshIndicatorStatus;


@interface RefreshIndicator : UIView
{
    NSTimer* _timer;
    UIActivityIndicatorViewStyle _style;
}

@property (nonatomic, retain) UILabel* label;
@property (nonatomic) CGFloat height;
@property (nonatomic, retain) UIImageView* icon;
@property (nonatomic, retain) UIActivityIndicatorView* indicator;
@property (nonatomic) RefreshIndicatorStatus status;

- (id)initWithFrame:(CGRect)frame withStyle:(UIActivityIndicatorViewStyle)style;

- (void)pull;
- (void)open;
- (void)openedAndRelease;
- (void)close;

@end
