//
//  NotificationCenterTableViewcCell.h
//  Yasound
//
//  Created by matthieu campion on 4/4/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserNotification.h"

@interface NotificationCenterTableViewcCell : UITableViewCell
{
  UserNotification* _notification;
  
  UILabel* _notifTextLabel;
  UILabel* _notifDateLabel;
  UIImageView* _unreadImage;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier notification:(UserNotification*)notif;

- (void)updateWithNotification:(UserNotification*)notif;

@end
