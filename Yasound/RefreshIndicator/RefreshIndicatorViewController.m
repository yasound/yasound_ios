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
    
    //    if (!self.showRefreshIndicator)
    //        return;
    
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

//    if (self.showRefreshIndicator)
//        [self refreshIndicator_scrollViewDidEndDragging:scrollView];

//    if ((self.refreshIndicator.status == eStatusOpened) && !self.loadingNextPage) {
//
//
//        // request next page to the server
//        self.loadingNextPage = [self.listDelegate listRequestNextPage];
//    }
    

    
        if (self.refreshIndicator.status == eStatusWaitingToClose) {
            [self unfreeze];
        }
        
        else if ((self.refreshIndicator.status == eStatusOpened) && !self.loadingNextPage) {
            
            [self.refreshIndicator openedAndRelease];
            
            [self refreshIndicatorDidFreeze];
            
            
            BOOL res = [self refreshIndicatorRequest];
            
            // request next page to the server
//            self.loadingNextPage = [self.listDelegate listRequestNextPage];
            
            //LBDEBUG
            NSLog(@"loadingNextPage %d : listRequestNextPage", self.loadingNextPage);
            
            
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
    
//    [self.refreshIndicatorDelegate refreshIndicatorFreeze];
//    [self.tableView setContentSize: CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height + self.refreshIndicator.height)];
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
    
//    [self.refreshIndicatorDelegate refreshIndicatorUnfreeze];
    [self refreshIndicatorDidUnfreeze];
}

- (void)refreshIndicatorDidUnfreeze {
}


//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(unfreezeAnimationStoped:finished:context:)];
//    
//    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height - self.refreshIndicator.height);
//    [UIView commitAnimations];
//    
//}
//
//
//- (void)unfreezeAnimationStoped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
//    
//    if (!self.showRefreshIndicator)
//        return;
//    
//    [self.tableView reloadData];
//    
//    NSLog(@"contentOffset.y  %.2f     rame.size.height %.2f => offset %.2f     (contentSize %.2f x %.2f)", self.tableView.contentOffset.y , self.tableView.frame.size.height, self.tableView.contentOffset.y + self.tableView.frame.size.height, self.tableView.contentSize.width, self.tableView.contentSize.height);
//    
//    
//    //    CGFloat newY = self.tableView.contentOffset.y + self.tableView.frame.size.height;
//    CGFloat newY = self.tableView.contentSize.height - self.tableView.frame.size.height;
//    
//    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, newY) animated:YES];
//}
//



@end
