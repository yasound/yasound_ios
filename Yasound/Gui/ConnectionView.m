//
//  ConnectionView.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 26/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ConnectionView.h"

#import "QuartzCore/QuartzCore.h"

@implementation ConnectionView


static ConnectionView* _main = nil;


#define VIEW_HEIGHT 44.f

+ (ConnectionView*)startWithTarget:(id)target timeout:(SEL)timeout
{
    [ConnectionView start];
    [ConnectionView startTimerWithTarget:target timeout:timeout];
    
    return _main;
}


+ (ConnectionView*)start {
    
    if (_main != nil)
        return _main;
    
    _main = [[ConnectionView alloc] initWithFrame:CGRectMake(0,0, 320, VIEW_HEIGHT)];
    
    return _main;
}




+ (ConnectionView*)startWithFrame:(CGRect)frame {
    
    if (_main != nil)
        return _main;
    _main = [[ConnectionView alloc] initWithFrame:frame];
    
    return _main;
}


+ (ConnectionView*)startWithFrame:(CGRect)frame target:(id)target timeout:(SEL)timeout
{
    [ConnectionView startWithFrame:frame];
    [ConnectionView startTimerWithTarget:target timeout:timeout];

    return _main;
}


+ (void)startTimerWithTarget:(id)target timeout:(SEL)timeout {
    
    _main.target = target;
    _main.timeout = timeout;
    _main.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:_main.target selector:_main.timeout userInfo:nil repeats:NO];
}




+ (void)stop
{
    if (_main == nil)
        return;
    
    if (_main.timer != nil) {
        [_main.timer invalidate];
        _main.timer = nil;
    }
    
    [_main.target release];
    
    [_main removeFromSuperview];
    [_main release];
    _main = nil;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.25;
        self.frame = CGRectMake(0, -VIEW_HEIGHT, self.frame.size.width, VIEW_HEIGHT);
        
        _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.frame.size.width/2.f - 22.f/2.f, VIEW_HEIGHT/2.f - 22.f/2.f, 22, 22)];
        [_indicator retain];
		[self addSubview:_indicator];
		_indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[_indicator startAnimating];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        self.frame = CGRectMake(0, 0, self.frame.size.width, VIEW_HEIGHT);
        [UIView commitAnimations];
    }
    return self;
}

- (void)dealloc
{
    [_indicator stopAnimating];
    [_indicator release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
