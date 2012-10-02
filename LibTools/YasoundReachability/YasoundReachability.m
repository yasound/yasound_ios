//
//  YasoundReachability.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YasoundReachability.h"
#import "RootViewController.h"


@implementation YasoundReachability

@synthesize hasNetwork;
@synthesize isReachable;
@synthesize networkStatus = _networkStatus;



static YasoundReachability* _main = nil;

+ (YasoundReachability*)main
{
    if (_main == nil)
    {
        _main = [[YasoundReachability alloc] init];
    }
    
    return _main;
}



- (void)dealloc
{
    [_reachHost release];
//    [_reachConnection release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


- (void)startWithTargetForChange:(id)target action:(SEL)action
{
    self.hasNetwork = YR_PENDING;
    self.isReachable = YR_PENDING;
    _connectionIsBack = NO;
    
    _target = target;
    _action = action;
    
    // CONNECTION REACHABILITY
    _reachConnection = [Reachability reachabilityForInternetConnection];
    [_reachConnection retain];

    _networkStatus = _reachConnection.currentReachabilityStatus;
    
    if (_networkStatus == NotReachable)
    {
        self.hasNetwork = YR_NO;

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REACHABILITY_CHANGED object:nil];
        
        if (_target != nil)
            [_target performSelector:_action withObject:nil];
    }

        
    // HOST REACHABILITY
    _reachHost = [Reachability reachabilityWithHostName:@"yasound.com"];
    [_reachHost retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(internalChanged:)
//                                                 name:kInternetConnection
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(localWifiChanged:)
//                                                 name:kLocalWiFiConnection
//                                               object:nil];

    
    [_reachConnection startNotifier];
    [_reachHost startNotifier];
}

- (void)removeTarget
{
    _target = nil;
    _action = nil;
}


// These are the status tests.
//- (NetworkStatus) currentReachabilityStatus;





//- (void)internalChanged
//{
//    DLog(@"internalChanged");
//    
//}
//
//
//- (void)localWifiChanged
//{
//    DLog(@"localWifiChanged");
//    
//}
//



- (void) reachabilityChanged:(NSNotification*)note
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    DLog(@"reachabilityChanged");
    
    Reachability* r = [note object];

    if (r == _reachConnection)
    {
        _networkStatus = r.currentReachabilityStatus;

        if (_networkStatus != NotReachable)
        {
            self.hasNetwork = YR_YES;
            _connectionIsBack = YES;
            
            if (_networkStatus == ReachableViaWiFi)
                DLog(@"_connectionIsBack in WIFI");
            else
                DLog(@"_connectionIsBack in WWAN");

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REACHABILITY_CHANGED object:nil];
        } 
        else
        {
            self.hasNetwork = YR_NO;
            
            DLog(@"no _connection");
            
            // network connection is back
            if (_target != nil)
                [_target performSelector:_action withObject:nil];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REACHABILITY_CHANGED object:nil];
            
        }
        
        return;
    }

    
    
    if ((r == _reachHost) && (self.hasNetwork != YR_NO))
    {
        _networkStatus = r.currentReachabilityStatus;

        NSString* message = nil;
    
        if (_networkStatus != NotReachable)
        {
            DLog(@"_host is reachable");

            self.isReachable = YR_YES;
            self.hasNetwork = YR_YES; 
        } 
        else
        {
            DLog(@"_host is not reachable");

            if (_connectionIsBack)
            {
                _connectionIsBack = NO;
                return;
            }
            
            self.isReachable = YR_NO;

            message = NSLocalizedString(@"YasoundReachability_host_no", nil);
//            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_host", nil) message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [av show];
//            [av release];  
        }
            
            if (_target != nil)
                [_target performSelector:_action withObject:message];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REACHABILITY_CHANGED object:nil];
        
            return;
    }
}






@end

