//
//  UserViewCell.h
//  Yasound
//
//  Created by matthieu campion on 2/3/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "WebImageView.h"

#define USER_VIEW_CELL_BORDER 4

@interface UserViewCell : UITableViewCell
{
  User* _user;
  WebImageView* _avatarView;
  UIImageView* _maskView;
  UILabel* _nameLabel;
}

@property (retain, nonatomic) User* user;

@end

