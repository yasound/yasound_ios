//
//  NotificationMessageViewController.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserNotification.h"

@interface NotificationMessageViewController : UIViewController
{
  IBOutlet UIBarButtonItem* _topBarTitle;
  IBOutlet UIBarButtonItem* _nowPlayingButton;
  IBOutlet UITextView* _textView;
}

@property (nonatomic, retain) UserNotification* notification;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil notification:(UserNotification*)notif;


- (IBAction)onNowPlayingClicked:(id)sender;
- (IBAction)onMenuBarItemClicked:(id)sender;

@end
