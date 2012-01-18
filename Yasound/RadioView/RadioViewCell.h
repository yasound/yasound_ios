//
//  RadioViewCell.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"


@class WallEvent;

@interface RadioViewCell : UITableViewCell

@property (nonatomic, retain) UIView* background;
@property (nonatomic, retain) WebImageView* avatar;
@property (nonatomic, retain) UILabel* date;
@property (nonatomic, retain) UILabel* user;
@property (nonatomic, retain) UILabel* message;

- initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier event:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath;

- update:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath;

@end
