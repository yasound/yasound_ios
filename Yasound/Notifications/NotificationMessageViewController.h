//
//  NotificationMessageViewController.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserNotification.h"

@interface NotificationMessageViewController : YaViewController
{
  IBOutlet UITextView* _textView;
}

@property (nonatomic, retain) UserNotification* notification;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil notification:(UserNotification*)notif;

@end
