//
//  UserNotification.h
//  Yasound
//
//  Created by matthieu campion on 5/16/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>




#define APNS_NOTIF_FRIEND_IN_RADIO @"type_notif_friend_in_radio"
#define APNS_NOTIF_USER_IN_RADIO @"type_notif_user_in_radio"
#define APNS_NOTIF_FRIEND_ONLINE @"type_notif_friend_online"
#define APNS_NOTIF_MESSAGE_POSTED @"type_notif_message_in_wall"
#define APNS_NOTIF_SONG_LIKED @"type_notif_song_liked"
#define APNS_NOTIF_RADIO_IN_FAVORITES @"type_notif_radio_in_favorites"
#define APNS_NOTIF_RADIO_SHARED @"type_notif_radio_shared"
#define APNS_NOTIF_FRIEND_CREATED_RADIO @"type_notif_friend_created_radio"

#define APNS_NOTIF_YASOUND_MESSAGE @"type_notif_message_from_yasound"
#define APNS_NOTIF_USER_MESSAGE @"type_notif_message_from_user"



@interface UserNotification : NSObject

@property (retain, nonatomic) NSString* _id;
@property (retain, nonatomic) NSString* type;
@property (retain, nonatomic) NSString* text;
@property (retain, nonatomic) NSDate* date;
@property (retain, nonatomic) NSNumber* dest_user_id;
@property (retain, nonatomic) NSNumber* from_user_id;
@property (retain, nonatomic) NSNumber* read;
@property (retain, nonatomic) NSDictionary* params;

- (BOOL)isReadBool;
- (void)setReadBool:(BOOL)r;

@end
