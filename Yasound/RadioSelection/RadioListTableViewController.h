//
//  RadioListTableViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"
#import "RefreshIndicator.h"

@protocol RadioListDelegate <NSObject>
- (void)radioListDidSelect:(Radio*)radio;
- (void)friendListDidSelect:(User*)aFriend;
- (BOOL)listRequestNextPage;
@end


@interface RadioListTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    BOOL _loadingNextPage;
    CGFloat _contentsHeight;
    BOOL _dragging;
    NSDate* _freezeDate;
    NSTimer* _freezeTimeout;
}

@property (nonatomic, retain) id<RadioListDelegate> listDelegate;
@property (nonatomic, retain) UITableView* tableView;

@property (nonatomic, retain) NSArray* radios;
@property (nonatomic, retain) NSArray* friends;
@property (nonatomic) BOOL friendsMode;
@property (nonatomic) NSInteger delayTokens;
@property (nonatomic) CGFloat delay;

@property (nonatomic, retain) RefreshIndicator* refreshIndicator;
@property (nonatomic) BOOL showRefreshIndicator;


- (id)initWithFrame:(CGRect)frame radios:(NSArray*)radios withContentsHeight:(CGFloat)contentsHeight showRefreshIndicator:(BOOL)showRefreshIndicator;
- (void)setRadios:(NSArray*)radios;
- (void)setFriends:(NSArray*)friends;

- (void)appendRadios:(NSArray*)radios;


@end
