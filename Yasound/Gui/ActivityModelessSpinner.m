//
//  ActivityModelessSpinner.m
//
//  Created by Loïc Berthelot on 01/13/2012
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "ActivityModelessSpinner.h"
#import "BundleFileManager.h"
#import "YasoundAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

@implementation ActivityModelessSpinner

@synthesize refcount;
@synthesize hidden;

static ActivityModelessSpinner* _main = nil;

+ (ActivityModelessSpinner*) main
{
    if (_main == nil)
    {
        _main = [[ActivityModelessSpinner alloc] init];
    }
    
    return _main;
}


-(id)init
{
    self = [super init];
    if (self)
    {
        self.refcount = 0;
        self.hidden = YES;
    }
    
    return self;
}


- (void)addRef
{
    self.refcount++;
// meeloo: we decided to disable this for now.
//    if (self.hidden)
//        [self show];
}


- (void)addRefForTimeInterval:(NSTimeInterval)timeInterval
{
    [self addRef];
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(delayedRemoveRef:) userInfo:nil repeats:NO];
}

- (void)delayedRemoveRef:(NSTimer*)timer
{
    [self removeRef];
}

- (void)removeRef
{
    assert(self.refcount > 0);
    
    self.refcount--;
// meeloo: we decided to disable this for now.
//    if (self.refcount == 0)
//        [self hide];
}


- (void)show
{
    self.hidden = NO;

    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"ActivityModelessSpinner" error:nil];
    CGRect initFrame = CGRectMake(sheet.frame.origin.x + sheet.frame.size.width, sheet.frame.origin.y, sheet.frame.size.width, sheet.frame.size.height);
    
    _view = [[UIView alloc] initWithFrame:initFrame];
    
    _view.layer.masksToBounds = YES;
    _view.layer.cornerRadius = 6;
    _view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _view.layer.borderWidth = 1.0; 
    _view.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    
    _view.alpha = 0.75;
    
    CGFloat size = 22.f;
    
    CGRect frame = CGRectMake(3, (sheet.frame.size.height / 2.f) - (size / 2.f), size, size);
    _ai = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    _ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [_view addSubview:_ai];
    [_ai startAnimating];
    
    // show the view
    YasoundAppDelegate* myDelegate = (((YasoundAppDelegate*) [UIApplication sharedApplication].delegate));
    [myDelegate.window addSubview:_view];
    
    // anim the view to make appear on the screen
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.33];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    _view.frame = sheet.frame;
    
    [UIView commitAnimations];        

}



- (void)hide
{
    CGRect dstFrame = CGRectMake(_view.frame.origin.x + _view.frame.size.width, _view.frame.origin.y, _view.frame.size.width, _view.frame.size.height);

    // anim the view to make appear on the screen
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.33];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideAnimationFinished:finished:context:)];
    
    _view.frame = dstFrame;
    
    [UIView commitAnimations];        
}


- (void)hideAnimationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    self.hidden = YES;
    
    [_ai stopAnimating];
    [_ai release];
    [_view removeFromSuperview];
    [_view release];
    
    [UIView setAnimationDelegate:nil];

    _ai = nil;
    _view = nil;
}


@end