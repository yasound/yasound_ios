//
//  NotificationCenterTableViewcCell.m
//  Yasound
//
//  Created by matthieu campion on 4/4/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationCenterTableViewcCell.h"
#import "BundleFileManager.h"
#import "Theme.h"

@implementation NotificationCenterTableViewcCell

- (NSString*) dateToString:(NSDate*)d
{
  NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
  NSDate* now = [NSDate date];
  NSDateComponents* todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:now];
  NSDateComponents* refComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:d];
  
  if (todayComponents.year == refComponents.year && todayComponents.month == refComponents.month && todayComponents.day == refComponents.day)
  {
    // today: show time
    [dateFormat setDateFormat:@"HH:mm"];
  }
  else
  {
    // not today: show date
    [dateFormat setDateFormat:@"dd/MM"];
  }
  
  NSString* s = [dateFormat stringFromDate:d];
  [dateFormat release];
  return s;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier notifInfo:(APNsNotifInfo*)notifInfo
{
  if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
  {
    _notifInfo = notifInfo;
    NSError* error;
    
    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"NotificationText"  retainStylesheet:YES overwriteStylesheet:NO error:&error];
   _notifTextLabel = [sheet makeLabel];
    NSString* t = [_notifInfo text];
    _notifTextLabel.text = t;
    _notifTextLabel.numberOfLines = 0;
    
    BundleFontsheet* fontSheet = [sheet.fontsheets objectForKey:@"default"];
    CGFloat fontSize = fontSheet.size;
    if ([_notifInfo read])
      _notifTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    else
      _notifTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
    
    [self addSubview:_notifTextLabel];
    
    _notifDateLabel = [[[BundleFileManager main] stylesheetForKey:@"NotificationDate"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
    NSString* s = [self dateToString:_notifInfo.date];
    _notifDateLabel.text = s;
    [self addSubview:_notifDateLabel];
    
    
    _unreadImage = [[[Theme theme] stylesheetForKey:@"NotifUnreadIcon" retainStylesheet:YES overwriteStylesheet:NO error:&error] makeImage];
    [self addSubview:_unreadImage];
    if ([_notifInfo read])
      _unreadImage.hidden = YES;
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




- (void)updateWithNotifInfo:(APNsNotifInfo*)notifInfo
{
  _notifInfo = notifInfo;
  BOOL read = [_notifInfo read];
  
  _notifTextLabel.text = [_notifInfo text];
  
  NSError* error;
  BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"NotificationText"  retainStylesheet:YES overwriteStylesheet:NO error:&error];
  BundleFontsheet* fontSheet = [sheet.fontsheets objectForKey:@"default"];
  CGFloat fontSize = fontSheet.size;
  if (read)
    _notifTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
  else
    _notifTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
  
  if (read)
    _unreadImage.hidden = YES;
}

@end