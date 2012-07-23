//
//  InteractiveView.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "InteractiveView.h"


@implementation InteractiveView


- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action
{
    if (self = [super initWithFrame:frame])
    {
        _target = target;
        _action = action;
        _userObject = nil;
        _targetDown = nil;
        _actionDown = nil;
        _userObjectDown = nil;
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action withObject:(id)userObject
{
    if (self = [super initWithFrame:frame])
    {
        _target = target;
        _action = action;
        _userObject = userObject;
        _targetDown = nil;
        _actionDown = nil;
        _userObjectDown = nil;
    }
    
    return self;
}


- (void)setTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    _userObject = nil;
}


- (void)setTarget:(id)target action:(SEL)action withObject:(id)userObject
{
    _target = target;
    _action = action;
    _userObject = userObject;
}


- (void)setTargetOnTouchDown:(id)target action:(SEL)action
{
    _targetDown = target;
    _actionDown = action;
}

- (void)setTargetOnTouchDown:(id)target action:(SEL)action withObject:(id)userObject
{
    _targetDown = target;
    _actionDown = action;
    _userObjectDown = userObject;
}




#pragma mark - touches actions




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
//    UITouch *aTouch = [touches anyObject];
//    
//    if (aTouch.tapCount == 2) 
    
    if (_targetDown == nil)
        return;
    
    if (_userObjectDown == nil)
        [_targetDown performSelector:_actionDown];
    else
        [_targetDown performSelector:_actionDown withObject:_userObjectDown];
}




//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//    
//}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (_target == nil)
        return;
    
    if (_userObject == nil)
        [_target performSelector:_action];
    else
        [_target performSelector:_action withObject:_userObject];
}




@end




