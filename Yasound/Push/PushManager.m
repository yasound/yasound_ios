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

- (void)subscribeToRadio:(NSNumber*)radioId delegate:(id<PushDelegate>)delegate
{
    if (!radioId || !delegate)
        return;
    
    BOOL needSubscribe = NO;
    NSString* key = [radioId stringValue];
    NSMutableArray* delegates = [_radioConnections valueForKey:key];
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
    [_radioConnections setValue:delegates forKey:key];
    
    
    if (_radioSocket.isConnected)
    {
        if (needSubscribe)
            [self subscribeToRadio:radioId];
        
        // socket is already connected
        if ([delegate respondsToSelector:@selector(didConnectToPushServerForRadioId:)])
            [delegate performSelector:@selector(didConnectToPushServerForRadioId:) withObject:radioId];
    }
    else if (!_radioSocket.isConnecting)
    {
        // delegate will be notified when socket connection result will be received
        [self connectRadioSocket];
    }
}

- (void)unsubscribeFromRadio:(NSNumber*)radioId delegate:(id<PushDelegate>)delegate
{
    if (!radioId || !delegate)
        return;
    
    NSString* key = [radioId stringValue];
    NSMutableArray* delegates = [_radioConnections valueForKey:key];
    [delegates removeObject:delegate];
    [_radioConnections setValue:delegates forKey:key];
    
    if (delegates.count == 0)
    {
        [_radioConnections removeObjectForKey:key];
        [self unsubscribeFromRadio:radioId];
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

- (void)subscribeToRadio:(NSNumber*)radioId
{
    [_radioSocket sendEvent:@"subscribe" withData:[NSDictionary dictionaryWithObject:radioId forKey:@"radio_id"]];
}

- (void)unsubscribeFromRadio:(NSNumber*)radioId
{
    [_radioSocket sendEvent:@"unsubscribe" withData:[NSDictionary dictionaryWithObject:radioId forKey:@"radio_id"]];
}

- (void)radioSocketConnected
{
    for (NSString* key in _radioConnections)
    {
        NSNumber* radioId = [NSNumber numberWithInt:[key intValue]];
        [self subscribeToRadio:radioId];
        
        NSMutableArray* delegates = [_radioConnections valueForKey:key];
        for (id<PushDelegate> delegate in delegates)
        {
            if ([delegate respondsToSelector:@selector(didConnectToPushServerForRadioId:)])
                [delegate performSelector:@selector(didConnectToPushServerForRadioId:) withObject:radioId];
        }
    }
}

- (void)radioSocketDisconnected
{
    for (NSString* key in _radioConnections)
    {
        NSNumber* radioId = [NSNumber numberWithInt:[key intValue]];
        
        NSMutableArray* delegates = [_radioConnections valueForKey:key];
        for (id<PushDelegate> delegate in delegates)
        {
            if ([delegate respondsToSelector:@selector(didDisconnectFromPushServerForRadioId:)])
                [delegate performSelector:@selector(didDisconnectFromPushServerForRadioId:) withObject:radioId];
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
    
    NSString* descStr = [data valueForKey:@"data"];
    if (!descStr)
        return;

    NSNumber* radioId = [[descStr JSONValue] valueForKey:@"radio_id"];
    if (!radioId)
        return;
    
    for (id<PushDelegate> delegate in [_radioConnections valueForKey:[radioId stringValue]])
    {
        if ([delegate respondsToSelector:@selector(didReceiveEventFromRadio:data:)])
            [delegate performSelector:@selector(didReceiveEventFromRadio:data:) withObject:radioId withObject:data];
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
