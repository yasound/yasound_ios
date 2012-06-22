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

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier notification:(UserNotification*)notif
{
  if (self = [super initWithFrame:frame reuseIdentifier:cellIdentifier]) 
  {
    _notification = notif;
    NSError* error;
    
    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"NotificationText"  retainStylesheet:YES overwriteStylesheet:NO error:&error];
   _notifTextLabel = [sheet makeLabel];

      if (_notification.from_user_id != nil)
      {
          _notifTextLabel.text = [NSString stringWithFormat:@"%@:\n%@", _notification.from_user_name, _notification.text];
      }
      else
      {
          _notifTextLabel.text = _notification.text;
      }
    _notifTextLabel.numberOfLines = 0;
      
      //LBDEBUG
      NSLog(@"notif : %@", _notifTextLabel.text);

      
      
    
    BundleFontsheet* fontSheet = [sheet.fontsheets objectForKey:@"default"];
    CGFloat fontSize = fontSheet.size;
    if ([_notification isReadBool])
      _notifTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    else
      _notifTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
    
    [self addSubview:_notifTextLabel];
    
    _notifDateLabel = [[[BundleFileManager main] stylesheetForKey:@"NotificationDate"  retainStylesheet:YES overwriteStylesheet:NO error:&error] makeLabel];
    NSString* s = [self dateToString:_notification.date];
    _notifDateLabel.text = s;
    [self addSubview:_notifDateLabel];

      
    if ([_notification isReadBool])
    {
        _unreadImage = [[[Theme theme] stylesheetForKey:@"NotifReadIcon" retainStylesheet:YES overwriteStylesheet:NO error:&error] makeImage];
    }
      else
      {
          _unreadImage = [[[Theme theme] stylesheetForKey:@"NotifUnreadIcon" retainStylesheet:YES overwriteStylesheet:NO error:&error] makeImage];
      }
    [self addSubview:_unreadImage];
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




- (void)updateWithNotification:(UserNotification*)notif
{
    _notification = notif;
  
    if (_notification.from_user_id != nil)
    {
        _notifTextLabel.text = [NSString stringWithFormat:@"%@:\n%@", _notification.from_user_name, _notification.text];
    }
    else
    {
        _notifTextLabel.text = _notification.text;
    }
    
    
    //LBDEBUG
    NSLog(@"notif : %@", _notifTextLabel.text);
  
  NSError* error;
  BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"NotificationText"  retainStylesheet:YES overwriteStylesheet:NO error:&error];
  BundleFontsheet* fontSheet = [sheet.fontsheets objectForKey:@"default"];
  CGFloat fontSize = fontSheet.size;

   if ([_notification isReadBool])
    _notifTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
  else
    _notifTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
  
  NSString* s = [self dateToString:_notification.date];
  _notifDateLabel.text = s;

    if ([_notification isReadBool])
    {
         sheet = [[Theme theme] stylesheetForKey:@"NotifReadIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    }
    else
    {
        sheet = [[Theme theme] stylesheetForKey:@"NotifUnreadIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    }
    [_unreadImage setImage:[sheet image]];
}

@end
