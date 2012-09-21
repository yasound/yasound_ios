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
}

@property (nonatomic, retain) UILabel* label;
@property (nonatomic) CGFloat height;
@property (nonatomic) RefreshIndicatorStatus status;

- (id)initWithFrame:(CGRect)frame;

- (void)pull;
- (void)open;
- (void)close;

@end
