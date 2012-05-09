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
        _targetDown = nil;
        _actionDown = nil;
    }
    
    return self;
}

- (void)addTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)addTargetOnTouchDown:(id)target action:(SEL)action
{
    _targetDown = target;
    _actionDown = action;
}




#pragma mark - touches actions




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
//    UITouch *aTouch = [touches anyObject];
//    
//    if (aTouch.tapCount == 2) 
    
    if (_targetDown != nil)
        [_targetDown performSelector:_actionDown];
}




//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//    
//}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (_target != nil)
        [_target performSelector:_action];
}




@end




