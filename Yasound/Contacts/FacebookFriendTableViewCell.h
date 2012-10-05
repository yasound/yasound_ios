//
//  FacebookFriendTableViewCell.h
//  Yasound
//
//  Created by mat on 25/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookFriend.h"
#import "WebImageView.h"

@interface FacebookFriendTableViewCell : UITableViewCell

@property (nonatomic, retain) FacebookFriend* ffriend;
@property (nonatomic, retain) WebImageView* image;
@property (nonatomic, retain) UILabel* nameLabel;


- (void)updateWithFacebookFriend:(FacebookFriend*)facebookFriend;

@end
