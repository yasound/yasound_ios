//
//  RadioListTableViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"


@protocol RadioListDelegate <NSObject>
- (void)radioListDidSelect:(Radio*)radio;
- (void)friendListDidSelect:(User*)aFriend;
@end


@interface RadioListTableViewController : UITableViewController

@property (nonatomic, retain) id<RadioListDelegate> listDelegate;
@property (nonatomic, retain) NSArray* radios;
@property (nonatomic, retain) NSArray* friends;
@property (nonatomic) BOOL friendsMode;
@property (nonatomic) NSInteger delayTokens;
@property (nonatomic) CGFloat delay;


- (id)initWithStyle:(UITableViewStyle)style radios:(NSArray*)radios;
- (void)setRadios:(NSArray*)radios;
- (void)setFriends:(NSArray*)friends;

- (void)appendRadios:(NSArray*)radios;


@end
