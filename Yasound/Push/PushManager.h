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

- (void)didConnectToPushServerForRadioId:(NSNumber*)radioId;
- (void)didDisconnectFromPushServerForRadioId:(NSNumber*)radioId;

- (void)didReceiveEventFromRadio:(NSNumber*)radioId data:(NSDictionary*)data;

@end

@interface PushManager : NSObject <SocketIODelegate>
{
    SocketIO* _radioSocket;
    
    NSMutableDictionary* _radioConnections;
}

+ (PushManager*) main;

- (void)subscribeToRadio:(NSNumber*)radioId delegate:(id<PushDelegate>)delegate;
- (void)unsubscribeFromRadio:(NSNumber*)radioId delegate:(id<PushDelegate>)delegate;

@end
