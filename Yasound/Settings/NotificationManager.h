//
//  NotificationManager.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 05/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APNsPreferences.h"


//#define NOTIF_FriendGoesOnline @"NotifFriendGoesOnline"
//#define NOTIF_FriendEnters @"NotifFriendEnters"
//#define NOTIF_UserEnters @"NotifUserEnters"
//#define NOTIF_PostReceived @"NotifPostReceived"
//#define NOTIF_LikeReceived @"NotifLikeReceived"
//#define NOTIF_SubscriptionReceived @"NotifSubscriptionReceived"
//#define NOTIF_RadioShared @"NotifRadioShared"
//#define NOTIF_NewFriendRadio @"NotifNewFriendRadio"



@interface NotificationManager : NSObject

@property (nonatomic, retain) NSMutableDictionary* notifications;

+ (NotificationManager*)main;


- (BOOL)get:(NSString*)notifIdentifier;
//- (void)save;

- (void)updateWithAPNsPreferences:(APNsPreferences*)prefs;
- (APNsPreferences*)APNsPreferences;

@end
