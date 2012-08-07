
/*
 DateViewController.h
 http://iphonedevelopment.blogspot.fr/2009/01/better-generic-date-picker.html
 */

#import <UIKit/UIKit.h>

@protocol DateViewDelegate <NSObject>
@required
- (void)takeNewDate:(NSDate *)newDate;
- (UINavigationController *)navController;          // Return the navigation controller
@end

@interface DateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UIDatePicker            *datePicker;
    UITableView             *dateTableView;
    NSDate                  *date;
    
    id <DateViewDelegate>   delegate;   // weak ref
}
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UITableView *dateTableView;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign)  id <DateViewDelegate> delegate;
-(IBAction)dateChanged;
@end