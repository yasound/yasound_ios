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

+ (ConnectionView*)start;
+ (ConnectionView*)startWithFrame:(CGRect)frame;
+ (void)stop;


@end
