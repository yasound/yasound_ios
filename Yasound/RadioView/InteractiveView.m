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
    UITouch *theTouch = [touches anyObject];
    [_target performSelector:_action];
}




@end




