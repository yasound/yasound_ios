//
//  ActivityAlertView.h
//  astrosurf
//
//  copied from kwigbo
//

#import <UIKit/UIKit.h>

#define ACTIVITYALERT_TIMEINTERVAL 2

@interface ActivityAlertView : UIAlertView
{
	UIActivityIndicatorView *activityView;
    BOOL empty;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic) BOOL running;

+ (void)showWithTitle:(NSString *)title;
+ (void)showWithTitle:(NSString *)title closeAfterTimeInterval:(NSTimeInterval)timeInterval;

+ (void)showWithTitle:(NSString *)title message:(NSString*)message;
+ (void)showWithTitle:(NSString *)title message:(NSString*)message closeAfterTimeInterval:(NSTimeInterval)timeInterval;

+ (void)close;
+ (BOOL)isRunning;

+ (ActivityAlertView*)current;


- (void)close;

@end

