//
//  NotificationManager.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 05/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationManager.h"

@implementation NotificationManager

@synthesize notifications;





static NotificationManager* _main = nil;

+ (NotificationManager*)main
{
    if (_main == nil)
    {
        _main = [[NotificationManager alloc] init];
    }
    
    return _main;
}



- (id)init
{
    if (self = [super init])
    {
        self.notifications = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
  [self.notifications release];
}


- (void)updateWithAPNsPreferences:(APNsPreferences*)prefs
{
  [self.notifications removeAllObjects];
  
  [self.notifications setObject:prefs.friend_in_radio forKey:NOTIF_FRIEND_ENTERS];
  [self.notifications setObject:prefs.user_in_radio forKey:NOTIF_USER_ENTERS];
  [self.notifications setObject:prefs.friend_online forKey:NOTIF_FRIEND_ONLINE];
  [self.notifications setObject:prefs.message_posted forKey:NOTIF_POST_RECEIVED];
  [self.notifications setObject:prefs.song_liked forKey:NOTIF_LIKE];
  [self.notifications setObject:prefs.radio_in_favorites forKey:NOTIF_SUBSCRIPTION];
  [self.notifications setObject:prefs.radio_shared forKey:NOTIF_RADIO_SHARED];
  [self.notifications setObject:prefs.friend_created_radio forKey:NOTIF_NEW_FRIEND_RADIO];
}

- (APNsPreferences*)APNsPreferences
{
  APNsPreferences* prefs = [[APNsPreferences alloc] init];
  prefs.friend_in_radio = [self.notifications objectForKey:NOTIF_FRIEND_ENTERS];
  prefs.user_in_radio = [self.notifications objectForKey:NOTIF_USER_ENTERS];
  prefs.friend_online = [self.notifications objectForKey:NOTIF_FRIEND_ONLINE];
  prefs.message_posted = [self.notifications objectForKey:NOTIF_POST_RECEIVED];
  prefs.song_liked = [self.notifications objectForKey:NOTIF_LIKE];
  prefs.radio_in_favorites = [self.notifications objectForKey:NOTIF_SUBSCRIPTION];
  prefs.radio_shared = [self.notifications objectForKey:NOTIF_RADIO_SHARED];
  prefs.friend_created_radio = [self.notifications objectForKey:NOTIF_NEW_FRIEND_RADIO];
  
  return prefs;
}



- (BOOL)get:(NSString*)notifIdentifier
{
    DLog(@"NotificationManager::get %@", notifIdentifier);
    NSNumber* numb = [self.notifications objectForKey:notifIdentifier];
    DLog(@"value : %@", numb);
    return [numb boolValue];
}





@end
