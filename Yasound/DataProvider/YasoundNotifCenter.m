//
//  YasoundNotifCenter.m
//  Yasound
//
//  Created by matthieu campion on 4/3/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YasoundNotifCenter.h"

#define APNS_NOTIFS_DEFAULTS_ENTRY_NAME @"APNsNotifs"

#define EVENT_NOTIF_ADDED @"notifAdded"
#define EVENT_NOTIF_DELETED @"notifDeleted"
#define EVENT_NOTIF_UNREAD_CHANGED @"unreadChanged"

@implementation YasoundNotifCenter

@synthesize notifInfos = _notifInfos;

static YasoundNotifCenter* _main = nil;


+ (YasoundNotifCenter*)main
{
  if (_main == nil)
  {
    _main = [[YasoundNotifCenter alloc] init];
  }
  
  return _main;
}



- (BOOL)load
{
//  //MAtTest
//  {
//    NSString* src = @"{\"aps\":{\"alert\":{\"loc-args\":[\"matthieu.campion\"],\"loc-key\":\"APNs_Msg\"},\"sound\":\"chime\"},\"yasound_notif_params\":{\"rID\":108,\"uID\":134}}";
//    NSDictionary* dict = [src JSONValue];
//    [self addNotifInfoWithDescription:dict];
//  }
//  
//  {
//    NSString* src = @"{\"aps\":{\"alert\":{\"loc-args\":[\"prout\"],\"loc-key\":\"APNs_Msg\"},\"sound\":\"chime\"},\"yasound_notif_params\":{\"rID\":2,\"uID\":12}}";
//    NSDictionary* dict = [src JSONValue];
//    [self addNotifInfoWithDescription:dict];
//  }

  
  NSArray* storedNotifDesc = [[NSUserDefaults standardUserDefaults] arrayForKey:APNS_NOTIFS_DEFAULTS_ENTRY_NAME];
  for (NSDictionary* storedNotifDict in storedNotifDesc) 
  {
    APNsNotifInfo* info = [[APNsNotifInfo alloc] initWithDictionary:storedNotifDict];
    info.delegate = self;
    [_notifInfos addObject:info];
  }
  
  
  return YES;
}

- (BOOL)save
{
  NSMutableArray* infoDict = [NSMutableArray arrayWithCapacity:_notifInfos.count];
  for (APNsNotifInfo* info in _notifInfos) 
  {
    [infoDict addObject:info.dataDict];
  }
  
  [[NSUserDefaults standardUserDefaults] setObject:infoDict forKey:APNS_NOTIFS_DEFAULTS_ENTRY_NAME];
  [[NSUserDefaults standardUserDefaults] synchronize];
  return YES;
}


- (id)init
{
  self = [super init];
  if (self)
  {
    _notifInfos = [[NSMutableArray alloc] init];
    [self load];
    
    _targetActionDict = [[NSMutableDictionary alloc] init];
    NSMutableArray* addTargetActions = [NSMutableArray array];
    [_targetActionDict setValue:addTargetActions forKey:EVENT_NOTIF_ADDED];
    NSMutableArray* deleteTargetActions = [NSMutableArray array];
    [_targetActionDict setValue:deleteTargetActions forKey:EVENT_NOTIF_DELETED];
    NSMutableArray* changeTargetActions = [NSMutableArray array];
    [_targetActionDict setValue:changeTargetActions forKey:EVENT_NOTIF_UNREAD_CHANGED];
  }
  
  return self;
}

- (void)dealloc
{
  [self save];
  for (APNsNotifInfo* info in _notifInfos) 
  {
    [info release];
  }
  [_notifInfos release];
  
  for (NSMutableArray* array in _targetActionDict) 
  {
    for (TargetAction* ta in array) 
    {
      [ta release];
    }
    [array release];
  }
  [_targetActionDict release];
}

- (NSInteger)unreadNotifCount
{
  NSInteger unread = 0;
  for (APNsNotifInfo* info in _notifInfos) 
  {
    BOOL read = [info read];
    if (!read)
      unread++;
  }
  
  return unread;
}



- (NSMutableArray*)targetActionsForEvent:(APNsNotifEvent)event
{
  if (event == eAPNsNotifAdded)
  {
    return [_targetActionDict valueForKey:EVENT_NOTIF_ADDED];
  }
  else if (event == eAPNsNotifDeleted)
  {
    return [_targetActionDict valueForKey:EVENT_NOTIF_DELETED];
  }
  else if (event == eAPNsUnreadNotifCountChanged)
  {
    return [_targetActionDict valueForKey:EVENT_NOTIF_UNREAD_CHANGED];
  }
  
  return nil;
}

- (void)addTarget:(id)target action:(SEL)action forEvent:(APNsNotifEvent)event
{
  TargetAction* ta = [[TargetAction alloc] initWithTarget:target action:action];
  NSMutableArray* array = [self targetActionsForEvent:event];
  for (TargetAction* i in array)
  {
    if ([ta isEqualToTargetAction:i])
      return;
  }
  
  [array addObject:ta];
}

- (void)removeTarget:(id)target action:(SEL)action forEvent:(APNsNotifEvent)event
{
  TargetAction* ta = [[TargetAction alloc] initWithTarget:target action:action];
  NSMutableArray* array = [self targetActionsForEvent:event];
  for (TargetAction* i in array)
  {
    if ([i isEqualToTargetAction:ta])
    {
      [i release];
      [array removeObject:i];
    }
  }
  
  [ta release];
}

- (void)removeTarget:(id)target
{
  NSMutableArray* array = [self targetActionsForEvent:eAPNsNotifAdded];
  for (TargetAction* i in array)
  {
    if (i.target == target)
    {
      [i release];
      [array removeObject:i];
    }
  }
  
  array = [self targetActionsForEvent:eAPNsNotifDeleted];
  for (TargetAction* i in array)
  {
    if (i.target == target)
    {
      [i release];    
      [array removeObject:i];
    }
  }
  
  array = [self targetActionsForEvent:eAPNsUnreadNotifCountChanged];
  for (TargetAction* i in array)
  {
    if (i.target == target)
    {
      [i release];
      [array removeObject:i];
    }
  }
}

- (void)sendNotifAddedEvent:(APNsNotifInfo*)notif
{
  NSMutableArray* array = [self targetActionsForEvent:eAPNsNotifAdded];
  for (TargetAction* ta in array)
  {
    [ta.target performSelector:ta.action withObject:notif];
  }
}

- (void)sendNotifDeletedEvent:(APNsNotifInfo*)notif
{
  NSMutableArray* array = [self targetActionsForEvent:eAPNsNotifDeleted];
  for (TargetAction* ta in array)
  {
    [ta.target performSelector:ta.action withObject:notif];
  }
}

- (void)sendUnreadCountChangedEvent
{
  NSMutableArray* array = [self targetActionsForEvent:eAPNsUnreadNotifCountChanged];
  for (TargetAction* ta in array)
  {
    [ta.target performSelector:ta.action];
  }
}







- (APNsNotifInfo*)addNotifInfoWithDescription:(NSDictionary*)notifDesc
{
  APNsNotifInfo* info = [[APNsNotifInfo alloc] initWithDictionary:notifDesc];
  info.date = [NSDate date];
  [self addNotifInfo:info];
  [info release]; // retained in addNotifInfo
  return info;
}

- (void)addNotifInfo:(APNsNotifInfo*)info
{
  [info retain];
  [_notifInfos addObject:info];
  info.delegate = self;
  [self save];
  
  [self sendNotifAddedEvent:info];
  [self sendUnreadCountChangedEvent];
}

- (void)deleteNotifInfo:(APNsNotifInfo*)info
{
  BOOL read = [info read];
  [self sendNotifDeletedEvent:info];
  [_notifInfos removeObject:info];
  [info release];
  [self save];
  
  if (!read)
    [self sendUnreadCountChangedEvent];
}




#pragma mark - APNsNotifInfoDelegate

- (void)notifInfoHasBeenRead:(APNsNotifInfo *)notifInfo
{
  [self save];
  [self sendUnreadCountChangedEvent];
}

@end



@implementation TargetAction

@synthesize target = _target;
@synthesize action = _action;

- (id)initWithTarget:(id)t action:(SEL)a
{
  self = [super init];
  if (self)
  {
    _target = t;
    [_target retain];
    _action = a;
  }
  return self;
}

- (void)dealloc
{
  [_target release];
}

- (BOOL)isEqualToTargetAction:(TargetAction*)ta
{
  if (self.target != ta.target)
    return NO;
  if (self.action != ta.action)
    return NO;
  
  return YES;
}

@end
