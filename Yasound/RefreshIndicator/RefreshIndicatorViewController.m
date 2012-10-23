//
//  RefreshIndicatorViewController.m
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RefreshIndicatorViewController.h"




@implementation RefreshIndicatorViewController


@synthesize dragging;
@synthesize loadingNextPage;
@synthesize refreshIndicator;
@synthesize showRefreshIndicator;

@synthesize freezeDate;
@synthesize freezeTimeout;

@synthesize tableView;



#pragma mark - UIScrollViewDelegate



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //
    // Refresh Indicator
    //
    if (self.showRefreshIndicator && (self.refreshIndicator.status != eStatusOpened)) {
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        
        // close it
        if (bottomEdge < (scrollView.contentSize.height + self.refreshIndicator.height/2.f)) {
            
            if (self.refreshIndicator.status == eStatusPulled)
                [self.refreshIndicator close];
        }
        
        // pull it out
        else if (self.dragging && (self.refreshIndicator.status == eStatusClosed) && (bottomEdge >= (scrollView.contentSize.height + self.refreshIndicator.height/2.f))) {
            
            [self.refreshIndicator pull];
        }
        
        // open it entirely
        else if (self.dragging && (self.refreshIndicator.status == eStatusPulled) &&  (bottomEdge >= (scrollView.contentSize.height + self.refreshIndicator.height))) {
            
            [self.refreshIndicator open];
        }
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.dragging = YES;
    
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    self.dragging = NO;

        if (self.refreshIndicator.status == eStatusWaitingToClose) {
            [self unfreeze];
        }
        
        else if ((self.refreshIndicator.status == eStatusOpened) && !self.loadingNextPage) {
            
            [self.refreshIndicator openedAndRelease];
            
            [self refreshIndicatorDidFreeze];
            
            
            BOOL res = [self refreshIndicatorRequest];
            
            
            if (!res)
                [self unfreeze];
            
        }
}




- (BOOL) refreshIndicatorRequest {
    
}





- (void)refreshIndicatorDidFreeze {
    
    if (!self.showRefreshIndicator)
        return;
    
    
    self.loadingNextPage = YES;
    
    self.freezeDate = [NSDate date];
    [self.freezeDate retain];
    
    self.freezeTimeout = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(freezeTimeout:) userInfo:nil repeats:NO];
}


- (void)freezeTimeout:(NSTimer*)timer {
    
    self.freezeTimeout = nil;
    
    [self unfreeze];
}


- (void)unfreeze {
    
    if (!self.showRefreshIndicator)
        return;
    
    [self.freezeTimeout invalidate];
    self.freezeTimeout = nil;
    
    if (self.dragging) {
        self.refreshIndicator.status = eStatusWaitingToClose;
        return;
    }
    
    if (!self.loadingNextPage)
        return;
    
    self.dragging = NO;
    self.loadingNextPage = NO;
    
    NSDate* now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:self.freezeDate];
    
    if (interval < 1)
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(unfreezeFinish) userInfo:nil repeats:NO];
    else
        [self unfreezeFinish];
}

- (void)unfreezeFinish {
    
    if (!self.showRefreshIndicator)
        return;
    
    [self.refreshIndicator close];
    
    [self refreshIndicatorDidUnfreeze];
}

- (void)refreshIndicatorDidUnfreeze {
}




@end
