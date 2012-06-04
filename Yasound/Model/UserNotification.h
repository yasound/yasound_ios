//
//  UserNotification.h
//  Yasound
//
//  Created by matthieu campion on 5/16/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APNS_NOTIF_FRIEND_IN_RADIO @"APNs_FIR"
#define APNS_NOTIF_USER_IN_RADIO @"APNs_UIR"
#define APNS_NOTIF_FRIEND_ONLINE @"APNs_FOn"
#define APNS_NOTIF_MESSAGE_POSTED @"APNs_Msg"
#define APNS_NOTIF_SONG_LIKED @"APNs_Sng"
#define APNS_NOTIF_RADIO_IN_FAVORITES @"APNs_RIF"
#define APNS_NOTIF_RADIO_SHARED @"APNs_RSh"
#define APNS_NOTIF_FRIEND_CREATED_RADIO @"APNs_FCR"

#define APNS_NOTIF_YASOUND_MESSAGE @"APNs_YAS"
#define APNS_NOTIF_USER_MESSAGE @"APNs_USR"



@interface UserNotification : NSObject

@property (retain, nonatomic) NSString* _id;
@property (retain, nonatomic) NSString* type;
@property (retain, nonatomic) NSString* text;
@property (retain, nonatomic) NSDate* date;
@property (retain, nonatomic) NSNumber* dest_user_id;
@property (retain, nonatomic) NSNumber* read;
@property (retain, nonatomic) NSDictionary* params;

- (BOOL)isReadBool;
- (void)setReadBool:(BOOL)r;

@end
