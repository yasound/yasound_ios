//
//  YasoundNotifCenter.h
//  Yasound
//
//  Created by matthieu campion on 4/3/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APNsNotifInfo.h"

@interface TargetAction : NSObject 
{
  id _target;
  SEL _action;
}

@property (readonly) id target;
@property (readonly) SEL action;

- (id)initWithTarget:(id)t action:(SEL)a;

- (BOOL)isEqualToTargetAction:(TargetAction*)ta;
@end



typedef enum {
  eAPNsNotifAdded = 0,
  eAPNsNotifDeleted = 1,
  eAPNsUnreadNotifCountChanged = 2
} APNsNotifEvent;


@interface YasoundNotifCenter : NSObject <APNsNotifInfoDelegate>
{
  NSMutableArray* _notifInfos;
  NSMutableDictionary* _targetActionDict;
}

@property (readonly) NSMutableArray* notifInfos;

+ (YasoundNotifCenter*)main;

- (id)init;

- (NSInteger)unreadNotifCount;

- (APNsNotifInfo*)addNotifInfoWithDescription:(NSDictionary*)notifDesc;
- (void)addNotifInfo:(APNsNotifInfo*)info;
- (void)deleteNotifInfo:(APNsNotifInfo*)info;

- (void)addTarget:(id)target action:(SEL)action forEvent:(APNsNotifEvent)event;
- (void)removeTarget:(id)target action:(SEL)action forEvent:(APNsNotifEvent)event;
- (void)removeTarget:(id)target;


@end
