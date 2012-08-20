//
//  UserListTableViewCell.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"
#import "YasoundDataProvider.h"


@interface UserListTableViewCell : UITableViewCell


@property (nonatomic, retain) NSMutableArray* objects; //array of array [User*, UILabel*, WebImageView*]
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)cellIdentifier users:(NSArray*)users delay:(CGFloat)delay target:(id)target action:(SEL)action;
- (void)updateWithUsers:(NSArray*)users target:(id)target action:(SEL)action;

@end
