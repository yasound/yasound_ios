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
#import "WheelSelectorGenre.h"

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

@property (nonatomic, retain) NSURL* url;

@property (nonatomic, retain) id<RadioListDelegate> listDelegate;
@property (nonatomic, retain) UITableView* tableView;

@property (nonatomic, retain) NSMutableArray* radios;
@property (nonatomic) NSInteger radiosPreviousCount;

@property (nonatomic, retain) NSArray* friends;
@property (nonatomic) BOOL friendsMode;
@property (nonatomic) NSInteger delayTokens;
@property (nonatomic) CGFloat delay;

@property (nonatomic, retain) RefreshIndicator* refreshIndicator;
@property (nonatomic) BOOL showRefreshIndicator;

@property (nonatomic, retain) WheelSelectorGenre* genreSelector;
@property (nonatomic) BOOL showGenreSelector;


- (id)initWithFrame:(CGRect)frame url:(NSURL*)url radios:(NSArray*)radios withContentsHeight:(CGFloat)contentsHeight showRefreshIndicator:(BOOL)showRefreshIndicator showGenreSelector:(BOOL)showGenreSelector;
- (void)setRadios:(NSArray*)radios;
- (void)setFriends:(NSArray*)friends;

- (void)setRadios:(NSArray*)radios forUrl:(NSURL*)url;
- (void)appendRadios:(NSArray*)radios;


@end
