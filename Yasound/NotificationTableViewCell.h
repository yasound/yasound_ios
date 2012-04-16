//
//  NotificationTableViewCell.h
//  Yasound
//
//  Created by matthieu campion on 4/5/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell
{
  UILabel* _unreadCountLabel;
  UIImageView* _badgeBackground;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier unreadCount:(NSInteger)count;
- (void)setUnreadCount:(NSInteger)count;

@end
