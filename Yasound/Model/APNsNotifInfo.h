//
//  APNsNotifInfo.h
//  Yasound
//
//  Created by matthieu campion on 4/2/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum 
{
  eAPNsNotif_UserInRadio = 0,
  eAPNsNotif_FriendInRadio,
  eAPNsNotif_FriendOnline,
  eAPNsNotif_MessagePosted,
  eAPNsNotif_SongLiked,
  eAPNsNotif_RadioInFavorites,
  eAPNsNotif_RadioShared,
  eAPNsNotif_FriendCreatedRadio,
  eAPNsNotif_YasoundMessage,
  eAPNsNotif_None
} APNsNotifType;

@class APNsNotifInfo;

@protocol APNsNotifInfoDelegate <NSObject>

- (void)notifInfoHasBeenRead:(APNsNotifInfo*)notifInfo;

@end

@interface APNsNotifInfo : NSObject
{
  NSMutableDictionary* _data;
  id<APNsNotifInfoDelegate> _delegate;
}

@property (retain, nonatomic) NSMutableDictionary* dataDict;
@property (retain, nonatomic) NSDate* date;
@property (retain) id<APNsNotifInfoDelegate> delegate;

- (id)initWithDictionary:(NSDictionary*)dict;

- (BOOL)read;
- (void)setRead:(BOOL)r;

- (APNsNotifType)type;

- (NSString*)text;

- (NSNumber*)radioID;

- (NSNumber*)userID;
- (NSString*)userName;

- (NSNumber*)songID;
- (NSString*)songName;

- (NSString*)url;

@end
