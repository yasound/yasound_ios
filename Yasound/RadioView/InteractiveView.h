//
//  InteractiveView.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InteractiveView : UIView
{
    id _target;
    SEL _action;
}

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

- (void)addTarget:(id)target action:(SEL)action;


@end
