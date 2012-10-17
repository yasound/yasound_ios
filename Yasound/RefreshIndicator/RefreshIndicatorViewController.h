//
//  RefreshIndicatorViewController.h
//  Yasound
//
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshIndicator.h"



@interface RefreshIndicatorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL dragging;
@property (nonatomic) BOOL loadingNextPage;
@property (nonatomic, retain) RefreshIndicator* refreshIndicator;
@property (nonatomic) BOOL showRefreshIndicator;

@property (nonatomic, retain) NSDate* freezeDate;
@property (nonatomic, retain) NSTimer* freezeTimeout;

@property (nonatomic, retain) UIView* tableViewContainer;
@property (nonatomic, retain) UITableView* tableView;




- (BOOL)refreshIndicatorRequest;
- (void)refreshIndicatorDidFreeze;
- (void)refreshIndicatorDidUnfreeze;



@end
