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

    NetworkStatus ns = _reachConnection.currentReachabilityStatus;
    
    if (ns == NotReachable)
    {
        self.hasNetwork = YR_NO;

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_CONNECTION_NO object:nil];
        
        if (_target != nil)
            [_target performSelector:_action];
    }

        
    // HOST REACHABILITY
    _reachHost = [Reachability reachabilityWithHostName:@"yasound.com"];
    [_reachHost retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    [_reachConnection startNotifier];
    [_reachHost startNotifier];
}

- (void)removeTarget
{
    _target = nil;
    _action = nil;
}




- (void) reachabilityChanged:(NSNotification*)note
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    Reachability* r = [note object];

    if (r == _reachConnection)
    {
        NetworkStatus ns = r.currentReachabilityStatus;

        if (ns != NotReachable)
        {
            self.hasNetwork = YR_YES;
            _connectionIsBack = YES;
        } 
        else
        {
            self.hasNetwork = YR_NO;
            
            // network connection is back
            // LBDEBUG TODO ?
            if (_target != nil)
                [_target performSelector:_action];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_CONNECTION_LOST object:nil];
            
        }
        
        return;
    }

    
    if ((r == _reachHost) && (self.hasNetwork != YR_NO))
    {
        NetworkStatus ns = r.currentReachabilityStatus;
    
        if (ns != NotReachable)
        {
            self.isReachable = YR_YES;
            self.hasNetwork = YR_YES; 
        } 
        else
        {
            if (_connectionIsBack)
            {
                _connectionIsBack = NO;
                return;
            }
            
            self.isReachable = YR_NO;

            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_host", nil) message:NSLocalizedString(@"YasoundReachability_host_no", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [av release];  
        }
            
            if (_target != nil)
                [_target performSelector:_action];
            
            return;
    }
}






@end

