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



+ (ConnectionView*)start
{
    if (_main != nil)
        return _main;
    _main = [[ConnectionView alloc] initWithFrame:CGRectMake(86,278, 138, 90)];
    
    return _main;
}


+ (void)stop
{
    if (_main == nil)
        return;
    
    [_main removeFromSuperview];
    [_main release];
    _main = nil;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
       self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor;
        self.layer.borderWidth = 1.0; 
        self.layer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1].CGColor;
        
        _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(56, 18, 22, 22)];
        [_indicator retain];
		[self addSubview:_indicator];
		_indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		[_indicator startAnimating];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, frame.size.width, 20)];
        label.text = NSLocalizedString(@"Connection", nil);
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        [self addSubview:label];
        
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
