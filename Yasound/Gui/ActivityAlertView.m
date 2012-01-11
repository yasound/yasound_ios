//
//  ActivityAlertView.h
//  astrosurf
//
//  copied from kwigbo
//

#import "ActivityAlertView.h"

@implementation ActivityAlertView

@synthesize activityView;
@synthesize running;

static ActivityAlertView* _alertView = nil;

+ (void)showWithTitle:(NSString *)title 
{
    [ActivityAlertView showWithTitle:title closeAfterTimeInterval:0];
}

+ (void)showWithTitle:(NSString *)title closeAfterTimeInterval:(NSTimeInterval)timeInterval
{
    if (_alertView)
    {
        [_alertView close];
        [_alertView release];
    }
    
    _alertView = [[ActivityAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (title == nil)
        _alertView.activityView.frame = CGRectMake(125, 20, 30, 30);
    
    _alertView.running = YES;
    [_alertView show];
    
    if (timeInterval > 0)
    {
        [NSTimer scheduledTimerWithTimeInterval:timeInterval target:_alertView selector:@selector(onStaticClose:) userInfo:nil repeats:NO];
    }
}


+ (void)close
{
    if (_alertView == nil)
        return;
    [_alertView close];
    _alertView.running = NO;
    
    [_alertView release];
    _alertView = nil;
}

+ (BOOL)isRunning
{
    if (_alertView == nil)
        return NO;
    return _alertView.running;
}


- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame]))
	{
        CGRect activityFrame = CGRectMake(125, 55, 30, 30);
        
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:activityFrame];
		[self addSubview:activityView];
		activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[activityView startAnimating];
        
        self.running = NO;

  }
	
  return self;
}

- (void) close
{
	[self dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)onStaticClose:(NSTimer*)timer
{
    [ActivityAlertView close];
}

- (void) dealloc
{
	[activityView release];
	[super dealloc];
}

@end