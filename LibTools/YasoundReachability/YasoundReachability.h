//
//  YasoundReachability.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"


#define NOTIF_REACHABILITY_CHANGED @"NOTIF_ReachabilityChanged"


typedef enum
{
    YR_PENDING = 0,
    YR_YES,
    YR_NO
} YasoundReachabilityBOOL;

@interface YasoundReachability : NSObject
{
    id _target;
    SEL _action;
    
    Reachability* _reachHost;
    Reachability* _reachConnection;
    
    BOOL _connectionIsBack;
}

@property (readwrite) YasoundReachabilityBOOL hasNetwork;
@property (readwrite) YasoundReachabilityBOOL isReachable;
@property (readonly) NetworkStatus networkStatus;

+ (YasoundReachability*)main;


- (void)startWithTargetForChange:(id)target action:(SEL)action;
- (void)removeTarget;

@end