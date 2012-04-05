//
//  APNsPreferences.h
//  Yasound
//
//  Created by matthieu campion on 4/2/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"

//
//
//  Preferences for Apple Push Notification service
//  store which notifications are enabled by the user
//

@interface APNsPreferences : Model

@property (retain, nonatomic) NSNumber* user_in_radio;
@property (retain, nonatomic) NSNumber* friend_in_radio;
@property (retain, nonatomic) NSNumber* friend_online;
@property (retain, nonatomic) NSNumber* message_posted;
@property (retain, nonatomic) NSNumber* song_liked;
@property (retain, nonatomic) NSNumber* radio_in_favorites;
@property (retain, nonatomic) NSNumber* radio_shared;
@property (retain, nonatomic) NSNumber* friend_created_radio;

- (BOOL)isUserInRadioNotifEnabled;          // notif when a user enters in his radio
- (BOOL)isFriendInRadioNotifEnabled;        // notif when a friend enters in his radio
- (BOOL)isFriendOnlineNotifEnabled;         // notif when a friend goes online
- (BOOL)isMessagePostedNotifEnabled;        // notif when a message is posted in his radio
- (BOOL)isSongLikedNotifEnabled;            // notif when a song is liked in his radio
- (BOOL)isRadioInFavoritesNotifEnabled;     // notif when his radio is added to a user's favorites
- (BOOL)isRadioSharedNotifEnabled;          // notif when his radio is shared
- (BOOL)isFriendRadioCreationNotifEnabled;  // notif when a friend has created a radio

- (void)enableUserInRadioNotif:(BOOL)enabled;
- (void)enableFriendInRadioNotif:(BOOL)enabled;
- (void)enableFriendOnlineNotif:(BOOL)enabled;
- (void)enableMessagePostedNotif:(BOOL)enabled;
- (void)enableSongLikedNotif:(BOOL)enabled;
- (void)enableRadioInFavoritesNotif:(BOOL)enabled;
- (void)enableRadioSharedNotif:(BOOL)enabled;
- (void)enableFriendRadioCreationNotif:(BOOL)enabled;

@end
