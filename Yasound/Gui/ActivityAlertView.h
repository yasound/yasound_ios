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

+ (void)showWithTitle:(NSString *)title message:(NSString *)message;
+ (void)close;


// initWithTitle from UIAlertView
- (void)close;

@end