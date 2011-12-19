//
//  RadioViewCell.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"


@class WallMessage;

@interface RadioViewCell : UITableViewCell

@property (nonatomic, retain) UIView* background;
@property (nonatomic, retain) WebImageView* avatar;
@property (nonatomic, retain) UILabel* date;
@property (nonatomic, retain) UILabel* user;
@property (nonatomic, retain) UILabel* message;

- initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier message:(WallMessage*)m indexPath:(NSIndexPath*)indexPath;

- update:(WallMessage*)m indexPath:(NSIndexPath*)indexPath;

@end
