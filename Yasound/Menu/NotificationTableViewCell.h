//
//  NotificationTableViewCell.h
//  Yasound
//
//  Created by matthieu campion on 4/5/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"

@interface NotificationTableViewCell : UITableViewCell
{
  UILabel* _unreadCountLabel;
  UIImageView* _badgeBackground;
}

@property (nonatomic, retain) UILabel* name;
@property (nonatomic, retain) WebImageView* icon;
@property (nonatomic) BOOL enabled;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier unreadCount:(NSInteger)count;
- (void)setUnreadCount:(NSInteger)count;

@end
