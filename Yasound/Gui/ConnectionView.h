//
//  ConnectionView.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 26/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionView : UIView
{
    UIActivityIndicatorView* _indicator;
}

@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL timeout;

+ (ConnectionView*)startWithTarget:(id)target timeout:(SEL)timeout;
+ (ConnectionView*)startWithFrame:(CGRect)frame target:(id)target timeout:(SEL)timeout;
+ (void)stop;


@end
