//
//  RadioListTableViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaRadio.h"
#import "WheelSelectorGenre.h"
#import "RefreshIndicatorViewController.h"
#import "TopBar.h"

@protocol RadioListDelegate <NSObject>
- (void)radioListDidSelect:(YaRadio*)radio;
- (void)friendListDidSelect:(User*)aFriend;
- (BOOL)listRequestNextPage;
@end


@interface RadioListTableViewController : RefreshIndicatorViewController {
    CGFloat _contentsHeight;
    BOOL _showRank;
}

@property (nonatomic, retain) NSURL* url;

@property (nonatomic, retain) id<RadioListDelegate> listDelegate;

@property (nonatomic, retain) NSMutableArray* radios;
@property (nonatomic) NSInteger radiosPreviousCount;

@property (nonatomic, retain) NSArray* friends;
@property (nonatomic) BOOL friendsMode;
@property (nonatomic) BOOL listenersMode;
@property (nonatomic) NSInteger delayTokens;
@property (nonatomic) CGFloat delay;


@property (nonatomic, retain) WheelSelectorGenre* genreSelector;
@property (nonatomic) BOOL showGenreSelector;


@property (nonatomic, retain) IBOutlet UITableView* listenersTableview;
@property (nonatomic, retain) IBOutlet TopBar* listenersTopbar;


- (id)initWithFrame:(CGRect)frame url:(NSURL*)url radios:(NSArray*)radios withContentsHeight:(CGFloat)contentsHeight showRefreshIndicator:(BOOL)showRefreshIndicator showGenreSelector:(BOOL)showGenreSelector showRank:(BOOL)showRank;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil listeners:(NSArray*)listeners;

- (void)setRadios:(NSArray*)radios;
- (void)setFriends:(NSArray*)friends;

- (void)setRadios:(NSArray*)radios forUrl:(NSURL*)url;
- (void)appendRadios:(NSArray*)radios;


@end
