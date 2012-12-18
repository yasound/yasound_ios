//
//  PushManager.m
//  Yasound
//
//  Created by mat on 13/12/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "PushManager.h"
#import "YasoundAppDelegate.h"
#import "NSObject+SBJson.h"

@implementation PushManager

static PushManager* _main = nil;

+ (PushManager*) main
{
    if (_main == nil)
    {
        _main = [[PushManager alloc] init];
    }
    
    return _main;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _radioSocket = [[SocketIO alloc] initWithDelegate:self];
        
        _radioConnections = [[NSMutableDictionary alloc] init];
        
        [self connectRadioSocket];
    }
    return self;
}

- (void)dealloc
{
    [_radioSocket disconnect];
    [_radioSocket release];
    _radioSocket = nil;
    
    [_radioConnections release];
    _radioConnections = nil;
    
    [super dealloc];
}

- (void)subscribeToRadio:(NSString*)radioUuid delegate:(id<PushDelegate>)delegate
{
    if (!radioUuid || !delegate)
        return;
    
    BOOL needSubscribe = NO;
    NSMutableArray* delegates = [_radioConnections valueForKey:radioUuid];
    if (delegates == nil)
    {
        delegates = [NSMutableArray arrayWithObject:delegate];
        needSubscribe = YES;
    }
    else
    {
        if ([delegates containsObject:delegate] == NO)
        {
            NSMutableArray* temp = [NSMutableArray arrayWithArray:delegates];
            [temp addObject:delegate];
            delegates = temp;
        }
        needSubscribe = NO;
    }
    [_radioConnections setValue:delegates forKey:radioUuid];
    
    
    if (_radioSocket.isConnected)
    {
        if (needSubscribe)
            [self subscribeToRadio:radioUuid];
        
        // socket is already connected
        if ([delegate respondsToSelector:@selector(didConnectToPushServerForRadioUuid:)])
            [delegate performSelector:@selector(didConnectToPushServerForRadioUuid:) withObject:radioUuid];
    }
    else if (!_radioSocket.isConnecting)
    {
        // delegate will be notified when socket connection result will be received
        [self connectRadioSocket];
    }
}

- (void)unsubscribeFromRadio:(NSString*)radioUuid delegate:(id<PushDelegate>)delegate
{
    if (!radioUuid || !delegate)
        return;
    
    NSMutableArray* delegates = [_radioConnections valueForKey:radioUuid];
    [delegates removeObject:delegate];
    [_radioConnections setValue:delegates forKey:radioUuid];
    
    if (delegates.count == 0)
    {
        [_radioConnections removeObjectForKey:radioUuid];
        [self unsubscribeFromRadio:radioUuid];
    }
    
}

- (NSString*)host
{
    NSString* host;
#if USE_YASOUND_LOCAL_SERVER
    host = @"localhost";
#else
    NSArray* components = [APPDELEGATE.serverURL componentsSeparatedByString:@"://"];
    if (components.count == 2)
    {
        host = [components objectAtIndex:1];
        if ([host hasSuffix:@"/"])
            host = [host substringToIndex:host.length - 1];
    }
#endif
    return host;
}

- (void)connectRadioSocket
{
    NSString* scheme;
#if USE_YASOUND_LOCAL_SERVER
    scheme = @"http";
#elif USE_DEV_SERVER
    scheme = @"http";
#else
    scheme = @"https";
#endif
    [_radioSocket connectToHost:[self host] onPort:9000 withScheme:scheme withParams:nil withNamespace:@"/radio"];
}

- (void)subscribeToRadio:(NSString*)radioUuid
{
    [_radioSocket sendEvent:@"subscribe" withData:[NSDictionary dictionaryWithObject:radioUuid forKey:@"radio_uuid"]];
}

- (void)unsubscribeFromRadio:(NSString*)radioUuid
{
    [_radioSocket sendEvent:@"unsubscribe" withData:[NSDictionary dictionaryWithObject:radioUuid forKey:@"radio_uuid"]];
}

- (void)radioSocketConnected
{
    for (NSString* key in _radioConnections)
    {
        NSString* radioUuid = key;
        [self subscribeToRadio:radioUuid];
        
        NSMutableArray* delegates = [_radioConnections valueForKey:key];
        for (id<PushDelegate> delegate in delegates)
        {
            if ([delegate respondsToSelector:@selector(didConnectToPushServerForRadioUuid:)])
                [delegate performSelector:@selector(didConnectToPushServerForRadioUuid:) withObject:radioUuid];
        }
    }
}

- (void)radioSocketDisconnected
{
    for (NSString* key in _radioConnections)
    {
        NSString* radioUuid = key;
        NSMutableArray* delegates = [_radioConnections valueForKey:key];
        for (id<PushDelegate> delegate in delegates)
        {
            if ([delegate respondsToSelector:@selector(didDisconnectFromPushServerForRadioUuid:)])
                [delegate performSelector:@selector(didDisconnectFromPushServerForRadioUuid:) withObject:radioUuid];
        }
    }
}

- (void)radioSocketDidReceiveEvent:(NSDictionary*)eventData
{
    NSString* eventName = [eventData valueForKey:@"name"];
    if ([eventName isEqualToString:@"radio_event"] == NO)
        return;
    
    NSArray* args = [eventData valueForKey:@"args"];
    if (!args || [args isKindOfClass:[NSArray class]] == NO || args.count == 0)
        return;
    
    NSDictionary* arg0 = [args objectAtIndex:0];
    if (!arg0)
        return;
    
    NSString* dataStr = [arg0 valueForKey:@"data"];
    if (!dataStr)
        return;
    
    NSDictionary* data = [dataStr JSONValue];
    if (!data)
        return;
    
    NSString* radioUuid = [data valueForKey:@"radio_uuid"];
    if (!radioUuid)
        return;
    
    for (id<PushDelegate> delegate in [_radioConnections valueForKey:radioUuid])
    {
        if ([delegate respondsToSelector:@selector(didReceiveEventFromRadio:data:)])
            [delegate performSelector:@selector(didReceiveEventFromRadio:data:) withObject:radioUuid withObject:data];
    }
}

#pragma mark - SocketIODelegate

- (void) socketIODidConnect:(SocketIO*)socket
{
    DLog(@"socketIODidConnect");
    if (socket == _radioSocket)
        [self radioSocketConnected];
}

- (void) socketIODidDisconnect:(SocketIO*)socket
{
    DLog(@"socketIODidDisconnect");
    if (socket == _radioSocket)
        [self radioSocketDisconnected];
}

- (void) socketIO:(SocketIO*)socket didReceiveMessage:(SocketIOPacket*)packet
{
    DLog(@"socketIO: didReceiveMessage");
}

- (void) socketIO:(SocketIO*)socket didReceiveJSON:(SocketIOPacket*)packet
{
    DLog(@"socketIO: didReceiveJSON");
}

- (void) socketIO:(SocketIO*)socket didReceiveEvent:(SocketIOPacket*)packet
{
    DLog(@"socketIO: didReceiveEvent");
    
    if (!packet.data)
        return;
    
    NSDictionary* packetDataDict = [packet.data JSONValue];
    if (!packetDataDict)
        return;
    
    if (socket == _radioSocket)
        [self radioSocketDidReceiveEvent:packetDataDict];
}

- (void) socketIO:(SocketIO*)socket didSendMessage:(SocketIOPacket*)packet
{
}

- (void) socketIOHandshakeFailed:(SocketIO*)socket
{
    DLog(@"socketIOHandshakeFailed");
    if (socket == _radioSocket)
        [self radioSocketDisconnected];
}


@end
