//
//  ActivityAlertView.h
//  astrosurf
//
//  copied from kwigbo
//

#import <UIKit/UIKit.h>

@interface ActivityAlertView : UIAlertView
{
	UIActivityIndicatorView *activityView;
    BOOL empty;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic) BOOL running;

+ (void)showWithTitle:(NSString *)title;
+ (void)close;
+ (BOOL)isRunning;


// initWithTitle from UIAlertView
- (void)close;

@end