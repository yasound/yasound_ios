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
      
      self.selectionStyle = UITableViewCellSelectionStyleGray;
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Notifications.text"  retainStylesheet:YES overwriteStylesheet:NO error:nil];
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
      
      
     
//    BundleFontsheet* fontSheet = [sheet.fontsheets objectForKey:@"default"];
//    CGFloat fontSize = fontSheet.size;
      _notifDateLabel = [[[Theme theme] stylesheetForKey:@"Notifications.date"  retainStylesheet:YES overwriteStylesheet:NO error:nil] makeLabel];
      NSString* s = [self dateToString:_notification.date];
      _notifDateLabel.text = s;
    
      
      if ([_notification isReadBool])
      {
          [sheet applyToLabel:_notifTextLabel class:@"default"];
          [sheet applyToLabel:_notifDateLabel class:@"default"];
          //        _notifTextLabel.alpha = 0.5;
          //        _notifDateLabel.alpha = 0.5;
      }
      else
      {
          [sheet applyToLabel:_notifTextLabel class:@"highlighted"];
          [sheet applyToLabel:_notifDateLabel class:@"highlighted"];
          //        _notifTextLabel.alpha = 1;
          //        _notifDateLabel.alpha = 1;
      }

      
    [self addSubview:_notifTextLabel];
    
    [self addSubview:_notifDateLabel];

      NSString* iconKey = [self iconKeyForType:_notification];
      
      sheet = [[Theme theme] stylesheetForKey:iconKey retainStylesheet:YES overwriteStylesheet:NO error:nil];
      _image = [sheet makeImage];
      [self addSubview:_image];
      
      if ([_notification isReadBool])
          _image.alpha = 0.4;
      else
          _image.alpha = 1;
      
      

//    if ([_notification isReadBool])
//    {
//        _unreadImage = [[[Theme theme] stylesheetForKey:@"Notifications.readIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil] makeImage];
//    }
//      else
//      {
//          _unreadImage = [[[Theme theme] stylesheetForKey:@"Notifications.unreadIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil] makeImage];
//      }
//    [self addSubview:_unreadImage];
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




- (NSString*)iconKeyForType:(UserNotification*)notif {

    NSString* iconKey = [NSString string];
    
    if ([notif.type isEqualToString:APNS_NOTIF_FRIEND_ONLINE]
        || [notif.type isEqualToString:APNS_NOTIF_USER_IN_RADIO]
        || [notif.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]) {
        
        iconKey = [NSString stringWithFormat:@"Notifications.iconFriends"];
    }
    
    else if ([notif.type isEqualToString:APNS_NOTIF_SONG_LIKED]){
        
        iconKey = [NSString stringWithFormat:@"Notifications.iconLike"];
    }
    
    else if ([notif.type isEqualToString:APNS_NOTIF_RADIO_IN_FAVORITES]){
        
        iconKey = [NSString stringWithFormat:@"Notifications.iconFavorites"];
    }
    
    else if ([notif.type isEqualToString:APNS_NOTIF_RADIO_SHARED]) {
        
        iconKey = [NSString stringWithFormat:@"Notifications.iconShare"];
    }
    
    else if ([notif.type isEqualToString:APNS_NOTIF_FRIEND_CREATED_RADIO]){
        
        iconKey = [NSString stringWithFormat:@"Notifications.iconRadio"];
    }
    
    else if ([notif.type isEqualToString:APNS_NOTIF_YASOUND_MESSAGE]
             || [notif.type isEqualToString:APNS_NOTIF_USER_MESSAGE]
             || [notif.type isEqualToString:APNS_NOTIF_MESSAGE_POSTED]) {
        
        iconKey = [NSString stringWithFormat:@"Notifications.iconMessage"];
    }
    
    else {
        
        iconKey = [NSString stringWithFormat:@"Notifications.iconNotifications"];
        
    }
    
    return iconKey;
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

    NSString* s = [self dateToString:_notification.date];
    _notifDateLabel.text = s;

    
  NSError* error;
  BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Notifications.text"  retainStylesheet:YES overwriteStylesheet:NO error:&error];
//  BundleFontsheet* fontSheet = [sheet.fontsheets objectForKey:@"default"];
//  CGFloat fontSize = fontSheet.size;

   if ([_notification isReadBool])
   {
//       _notifTextLabel.alpha = 0.5;
//       _notifDateLabel.alpha = 0.5;
       [sheet applyToLabel:_notifTextLabel class:@"default"];
       [sheet applyToLabel:_notifDateLabel class:@"default"];
   }
  else
  {
//      _notifTextLabel.alpha = 1;
//      _notifDateLabel.alpha = 1;
      [sheet applyToLabel:_notifTextLabel class:@"highlighted"];
      [sheet applyToLabel:_notifDateLabel class:@"highlighted"];
  }
    
    if ([_notification isReadBool])
        _image.alpha = 0.4;
    else
        _image.alpha = 1;
    
    NSString* iconKey = [self iconKeyForType:_notification];
    sheet = [[Theme theme] stylesheetForKey:iconKey retainStylesheet:YES overwriteStylesheet:NO error:nil];
    _image.image  =[sheet image];


//    if ([_notification isReadBool])
//    {
//         sheet = [[Theme theme] stylesheetForKey:@"Notifications.readIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    }
//    else
//    {
//        sheet = [[Theme theme] stylesheetForKey:@"Notifications.unreadIcon" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    }
//    [_unreadImage setImage:[sheet image]];
}


- (BOOL)isInteractive
{
    return YES;
//    if ([_notification.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]
//        || [_notification.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]
//        || [_notification.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]
//        || [_notification.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]
//        || [_notification.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]
//        || [_notification.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]
//        || [_notification.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]
//        || [_notification.type isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO]
//        
//        
//#define APNS_NOTIF_USER_IN_RADIO @"type_notif_user_in_radio"
//#define APNS_NOTIF_FRIEND_ONLINE @"type_notif_friend_online"
//#define APNS_NOTIF_MESSAGE_POSTED @"type_notif_message_in_wall"
//#define APNS_NOTIF_SONG_LIKED @"type_notif_song_liked"
//#define APNS_NOTIF_RADIO_IN_FAVORITES @"type_notif_radio_in_favorites"
//#define APNS_NOTIF_RADIO_SHARED @"type_notif_radio_shared"
//#define APNS_NOTIF_FRIEND_CREATED_RADIO @"type_notif_friend_created_radio"
//         
//#define APNS_NOTIF_YASOUND_MESSAGE @"type_notif_message_from_yasound"
//#define APNS_NOTIF_USER_MESSAGE @"type_notif_message_from_user"

}


@end
