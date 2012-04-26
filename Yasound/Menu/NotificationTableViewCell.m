//
//  NotificationTableViewCell.m
//  Yasound
//
//  Created by matthieu campion on 4/5/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "BundleFileManager.h"
#import "Theme.h"

@implementation NotificationTableViewCell

@synthesize name;
@synthesize icon;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier unreadCount:(NSInteger)count
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuViewCell_icon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.icon = [[WebImageView alloc] initWithFrame:sheet.frame];
        [self addSubview:self.icon];
        
        sheet = [[Theme theme] stylesheetForKey:@"MenuViewCell_name" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.name = [sheet makeLabel];
        [self addSubview:self.name];

        
      NSError* error;
      _unreadCountLabel = [[[BundleFileManager main] stylesheetForKey:@"UnreadNotifBadge"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
      [self setUnreadCount:count];
      [self.contentView addSubview:_unreadCountLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUnreadCount:(NSInteger)count
{
  if (count == 0)
  {
    _unreadCountLabel.hidden = YES;
  }
  else
  {
    _unreadCountLabel.hidden = NO;
    _unreadCountLabel.text = [NSString stringWithFormat:@"%d", count];
  }
  
  NSString* key = @"UnreadNotifBadge3";
  if (count < 10)
    key = @"UnreadNotifBadge1";
  else if (count < 100)
    key = @"UnreadNotifBadge2";
  
  if (_badgeBackground)
  {
    [_badgeBackground removeFromSuperview];
    _badgeBackground = nil;
  }
  
  if (count == 0)
    return;
  
  NSError* error;
  _badgeBackground = [[[Theme theme] stylesheetForKey:key retainStylesheet:YES overwriteStylesheet:NO error:&error] makeImage];
  [self.contentView addSubview:_badgeBackground];
  
  [self.contentView bringSubviewToFront:_unreadCountLabel];
}


@end
