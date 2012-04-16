//
//  APNsPreferences.m
//  Yasound
//
//  Created by matthieu campion on 4/2/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "APNsPreferences.h"

@implementation APNsPreferences

@synthesize user_in_radio;
@synthesize friend_in_radio;
@synthesize friend_online;
@synthesize message_posted;
@synthesize song_liked;
@synthesize radio_in_favorites;
@synthesize radio_shared;
@synthesize friend_created_radio;

- (BOOL)isUserInRadioNotifEnabled
{ 
  BOOL enabled = [self.user_in_radio boolValue];
  return enabled;
}

- (BOOL)isFriendInRadioNotifEnabled
{ 
  BOOL enabled = [self.friend_in_radio boolValue];
  return enabled;
}

- (BOOL)isFriendOnlineNotifEnabled
{ 
  BOOL enabled = [self.friend_online boolValue];
  return enabled;
}

- (BOOL)isMessagePostedNotifEnabled
{ 
  BOOL enabled = [self.message_posted boolValue];
  return enabled;
}

- (BOOL)isSongLikedNotifEnabled
{ 
  BOOL enabled = [self.song_liked boolValue];
  return enabled;
}

- (BOOL)isRadioInFavoritesNotifEnabled
{ 
  BOOL enabled = [self.radio_in_favorites boolValue];
  return enabled;
}

- (BOOL)isRadioSharedNotifEnabled
{ 
  BOOL enabled = [self.radio_shared boolValue];
  return enabled;
}

- (BOOL)isFriendRadioCreationNotifEnabled
{ 
  BOOL enabled = [self.friend_created_radio boolValue];
  return enabled;
}


- (void)enableUserInRadioNotif:(BOOL)enabled
{
  self.user_in_radio = [NSNumber numberWithBool:enabled];
}

- (void)enableFriendInRadioNotif:(BOOL)enabled
{
  self.friend_in_radio = [NSNumber numberWithBool:enabled];
}

- (void)enableFriendOnlineNotif:(BOOL)enabled
{
  self.friend_online = [NSNumber numberWithBool:enabled];
}

- (void)enableMessagePostedNotif:(BOOL)enabled
{
  self.message_posted = [NSNumber numberWithBool:enabled];
}

- (void)enableSongLikedNotif:(BOOL)enabled
{
  self.song_liked = [NSNumber numberWithBool:enabled];
}

- (void)enableRadioInFavoritesNotif:(BOOL)enabled
{
  self.radio_in_favorites = [NSNumber numberWithBool:enabled];
}

- (void)enableRadioSharedNotif:(BOOL)enabled
{
  self.radio_shared = [NSNumber numberWithBool:enabled];
}

- (void)enableFriendRadioCreationNotif:(BOOL)enabled
{
  self.friend_created_radio = [NSNumber numberWithBool:enabled];
}


@end
