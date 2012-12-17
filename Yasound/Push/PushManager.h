//
//  PushManager.h
//  Yasound
//
//  Created by mat on 13/12/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"

@protocol PushDelegate <NSObject>

- (void)didConnectToPushServerForRadioUuuid:(NSString*)radioUuid;
- (void)didDisconnectFromPushServerForRadioUuid:(NSString*)radioUuid;

- (void)didReceiveEventFromRadio:(NSString*)radioUuid data:(NSDictionary*)data;

@end

@interface PushManager : NSObject <SocketIODelegate>
{
    SocketIO* _radioSocket;
    
    NSMutableDictionary* _radioConnections;
}

+ (PushManager*) main;

- (void)subscribeToRadio:(NSString*)radioUuid delegate:(id<PushDelegate>)delegate;
- (void)unsubscribeFromRadio:(NSString*)radioUuid delegate:(id<PushDelegate>)delegate;

@end
