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
}

@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic) BOOL running;

+ (void)showWithTitle:(NSString *)title;
+ (void)close;
+ (BOOL)isRunning;


// initWithTitle from UIAlertView
- (void)close;

@end