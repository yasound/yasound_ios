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
    id _userObject;

    id _targetDown;
    SEL _actionDown;
    id _userObjectDown;
}

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;
- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action withObject:(id)userObject;

- (void)setTarget:(id)target action:(SEL)action;
- (void)setTarget:(id)target action:(SEL)action withObject:(id)userObject;
- (void)setTargetOnTouchDown:(id)target action:(SEL)action;
- (void)setTargetOnTouchDown:(id)target action:(SEL)action withObject:(id)userObject;



@end
