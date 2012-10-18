//
//  NotificationManager.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 05/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APNsPreferences.h"

#define NOTIF_USER_ENTERS @"NotifUserEnters"
#define NOTIF_FRIEND_ENTERS @"NotifFriendEnters"
#define NOTIF_FRIEND_ONLINE @"NotifFriendGoesOnline"
#define NOTIF_LIKE @"NotifLikeReceived"

#define NOTIF_SUBSCRIPTION @"NotifSubscriptionReceived"
#define NOTIF_NEW_FRIEND_RADIO @"NotifNewFriendRadio"
#define NOTIF_POST_RECEIVED @"NotifPostReceived"
#define NOTIF_RADIO_SHARED @"NotifRadioShared"


@interface NotificationManager : NSObject

@property (nonatomic, retain) NSMutableDictionary* notifications;

+ (NotificationManager*)main;


- (BOOL)get:(NSString*)notifIdentifier;

- (void)updateWithAPNsPreferences:(APNsPreferences*)prefs;
- (APNsPreferences*)APNsPreferences;

@end
