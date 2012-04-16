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
    }
    
    return self;
}

- (void)addTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}




#pragma mark - touches actions




//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//    UITouch *aTouch = [touches anyObject];
//    
//    if (aTouch.tapCount == 2) 
//    
//}
//



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




