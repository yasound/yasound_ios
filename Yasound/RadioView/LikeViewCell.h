//
//  LikeViewCell.h
//  Yasound
//
//  Created by matthieu campion on 2/16/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WallEvent;

@interface LikeViewCell : UITableViewCell

@property (nonatomic, retain) UILabel* date;
@property (nonatomic, retain) UILabel* message;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier event:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath;

- (void)update:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath;


@end
