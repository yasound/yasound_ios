//
//  NotificationCenterTableViewcCell.h
//  Yasound
//
//  Created by matthieu campion on 4/4/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APNsNotifInfo.h"

@interface NotificationCenterTableViewcCell : UITableViewCell
{
  APNsNotifInfo* _notifInfo;
  
  UILabel* _notifTextLabel;
  UILabel* _notifDateLabel;
  UIImageView* _unreadImage;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier notifInfo:(APNsNotifInfo*)notifInfo;

- (void)updateWithNotifInfo:(APNsNotifInfo*)notifInfo;

@end
