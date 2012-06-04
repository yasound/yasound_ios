//
//  APNsNotifInfo.m
//  Yasound
//
//  Created by matthieu campion on 4/2/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "APNsNotifInfo.h"

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


#define APS_ATTRIBUTE_NAME @"aps"
#define ALERT_ATTRIBUTE_NAME @"alert"
#define LOC_ARGS_ATTRIBUTE_NAME @"loc-args"
#define LOC_KEY_ATTRIBUTE_NAME @"loc-key"

#define YASOUND_NOTIF_PARAMS_ATTRIBUTE_NAME @"yasound_notif_params"

#define INTERNAL_INFO_ATTRIBUTE_NAME @"internal_info"
#define DATE_ATTRIBUTE_NAME @"date"
#define READ_ATTRIBUTE_NAME @"read"

#define APNS_NOTIF_PARAM_USER_ID @"uID"
#define APNS_NOTIF_PARAM_RADIO_ID @"rID"
#define APNS_NOTIF_PARAM_SONG_ID @"sID"
#define APNS_NOTIF_PARAM_URL @"url"



@implementation APNsNotifInfo

@synthesize dataDict = _data;
@synthesize delegate = _delegate;

- (id)initWithDictionary:(NSDictionary*)dict
{
  self = [super init];
  if (self)
  {
    _delegate = nil;
    _data = [NSMutableDictionary dictionaryWithDictionary:dict];
    [_data retain];
    NSLog(@"notif data: %@", _data);
  }
  
  return self;
}

- (void)dealloc
{
  NSLog(@"APNsNotifInfo dealloc"); 
  [_data release];
}

- (NSDictionary*)internalInfo
{
  if (!_data)
    return nil;
  
  NSDictionary* infoDict = [_data valueForKey:INTERNAL_INFO_ATTRIBUTE_NAME];
  return infoDict;
}

- (NSDate*)date
{
  NSDictionary* infoDict = [self internalInfo];
  if (!infoDict)
    return nil;
  
  NSDate* d = [infoDict valueForKey:DATE_ATTRIBUTE_NAME];
  return d;
}

- (void)setDate:(NSDate *)d
{
  if (!_data)
    return;
  
  NSDictionary* infoDict = [self internalInfo];
  NSMutableDictionary* newInfoDict;
  
  if (infoDict)
    newInfoDict = [NSMutableDictionary dictionaryWithDictionary:infoDict];
  else
    newInfoDict = [NSMutableDictionary dictionary];
  [newInfoDict setValue:d forKey:DATE_ATTRIBUTE_NAME];
  
  [_data setValue:newInfoDict forKey:INTERNAL_INFO_ATTRIBUTE_NAME];
}

- (BOOL)read
{
  NSDictionary* infoDict = [self internalInfo];
  if (!infoDict)
    return NO;
  
  BOOL r = [[infoDict valueForKey:READ_ATTRIBUTE_NAME] boolValue];
  return r;
}

- (void)setRead:(BOOL)r
{
  if (!_data)
    return;
  
  if ([self read] == r)
    return;
  
  NSDictionary* infoDict = [self internalInfo];
  NSMutableDictionary* newInfoDict;
  
  if (infoDict)
    newInfoDict = [NSMutableDictionary dictionaryWithDictionary:infoDict];
  else
    newInfoDict = [NSMutableDictionary dictionary];
  [newInfoDict setValue:[NSNumber numberWithBool:r] forKey:READ_ATTRIBUTE_NAME];
  
  [_data setValue:newInfoDict forKey:INTERNAL_INFO_ATTRIBUTE_NAME];
  
  if (self.delegate)
    [self.delegate notifInfoHasBeenRead:self];
}

- (NSString*)locKey
{
  if (!_data)
    return nil;
  
  NSDictionary* apsDict = [_data valueForKey:APS_ATTRIBUTE_NAME];
  if (!apsDict)
    return nil;
  
  NSDictionary* alertDict = [apsDict valueForKey:ALERT_ATTRIBUTE_NAME];
  if (!alertDict || ![alertDict isKindOfClass:[NSDictionary class]])
    return nil;
  
  NSString* locKey = [alertDict valueForKey:LOC_KEY_ATTRIBUTE_NAME];
  return locKey;
}

- (NSArray*)locArgs
{
  if (!_data)
    return nil;
  
  NSDictionary* apsDict = [_data valueForKey:APS_ATTRIBUTE_NAME];
  if (!apsDict)
    return nil;
  
  NSDictionary* alertDict = [apsDict valueForKey:ALERT_ATTRIBUTE_NAME];
  if (!alertDict || ![alertDict isKindOfClass:[NSDictionary class]])
    return nil;
  
  NSArray* locArgsArray = [alertDict valueForKey:LOC_ARGS_ATTRIBUTE_NAME];
  return locArgsArray;
}

- (APNsNotifType)type
{
  NSString* locKey = [self locKey];
  if (!locKey)
    return eAPNsNotif_None;
  
  if ([locKey isEqualToString:APNS_NOTIF_FRIEND_IN_RADIO])
    return eAPNsNotif_FriendInRadio;
  
  if ([locKey isEqualToString:APNS_NOTIF_USER_IN_RADIO])
    return eAPNsNotif_UserInRadio;
  
  if ([locKey isEqualToString:APNS_NOTIF_FRIEND_ONLINE])
    return eAPNsNotif_FriendOnline;
  
  if ([locKey isEqualToString:APNS_NOTIF_MESSAGE_POSTED])
    return eAPNsNotif_MessagePosted;
  
  if ([locKey isEqualToString:APNS_NOTIF_SONG_LIKED])
    return eAPNsNotif_SongLiked;
  
  if ([locKey isEqualToString:APNS_NOTIF_RADIO_IN_FAVORITES])
    return eAPNsNotif_RadioInFavorites;
  
  if ([locKey isEqualToString:APNS_NOTIF_RADIO_SHARED])
    return eAPNsNotif_RadioShared;
  
  if ([locKey isEqualToString:APNS_NOTIF_FRIEND_CREATED_RADIO])
    return eAPNsNotif_FriendCreatedRadio;
  
  if ([locKey isEqualToString:APNS_NOTIF_YASOUND_MESSAGE])
    return eAPNsNotif_YasoundMessage;

    if ([locKey isEqualToString:APNS_NOTIF_USER_MESSAGE])
        return eAPNsNotif_UserMessage;

  return eAPNsNotif_None;
}


- (NSString*)text
{
  NSString* locKey = [self locKey];
  if (!locKey)
    return nil;
  
  NSArray* locArgs = [self locArgs];
  
  int nbArgs = [locArgs count];
  id args[nbArgs];
	NSUInteger index = 0;
	for (id item in locArgs) 
  {
    args[index++] = item;
	}
  
  NSString* rawString = NSLocalizedString(locKey, nil);
  NSString* formattedString = [[[NSString alloc] initWithFormat:rawString arguments:args] autorelease];
  return formattedString;
}

- (NSNumber*)radioID
{
  if (!_data)
    return nil;
  
  NSDictionary* yasoundParams = [_data valueForKey:YASOUND_NOTIF_PARAMS_ATTRIBUTE_NAME];
  if (!yasoundParams)
    return nil;
  
  NSNumber* radioID = [yasoundParams valueForKey:APNS_NOTIF_PARAM_RADIO_ID];
  return radioID;
}

- (NSNumber*)userID
{
  if (!_data)
    return nil;
  
  NSDictionary* yasoundParams = [_data valueForKey:YASOUND_NOTIF_PARAMS_ATTRIBUTE_NAME];
  if (!yasoundParams)
    return nil;
  
  NSNumber* userID = [yasoundParams valueForKey:APNS_NOTIF_PARAM_USER_ID];
  return userID;
}

- (NSNumber*)songID
{
  if (!_data)
    return nil;
  
  NSDictionary* yasoundParams = [_data valueForKey:YASOUND_NOTIF_PARAMS_ATTRIBUTE_NAME];
  if (!yasoundParams)
    return nil;
  
  NSNumber* songID = [yasoundParams valueForKey:APNS_NOTIF_PARAM_SONG_ID];
  return songID;
}

- (NSString*)userName
{
  NSArray* locArgsArray = [self locArgs];
  if (!locArgsArray)
    return nil;
  if (locArgsArray.count == 0)
    return nil;
  
  NSString* userName = [locArgsArray objectAtIndex:0];
  return userName;
}

- (NSString*)songName
{
  NSArray* locArgsArray = [self locArgs];
  if (!locArgsArray)
    return nil;
  
  if (locArgsArray.count < 2)
    return nil;
  
  NSString* songName = [locArgsArray objectAtIndex:1];
  return songName;
}

- (NSString*)url
{
  if (!_data)
    return nil;
  
  NSDictionary* yasoundParams = [_data valueForKey:YASOUND_NOTIF_PARAMS_ATTRIBUTE_NAME];
  if (!yasoundParams)
    return nil;
  
  NSString* url = [yasoundParams valueForKey:APNS_NOTIF_PARAM_URL];
  return url;
}


@end
