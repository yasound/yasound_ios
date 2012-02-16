//
//  RadioViewCell.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageView.h"


@class WallEvent;

#define THE_REST_OF_THE_CELL_HEIGHT 50

@interface RadioViewCell : UITableViewCell

//@property (nonatomic, retain) UIView* background;
@property (nonatomic, retain) WebImageView* avatar;
@property (nonatomic, retain) UILabel* date;
@property (nonatomic, retain) UILabel* user;
@property (nonatomic, retain) UIView* messageBackground;
@property (nonatomic, retain) UILabel* message;
@property (nonatomic, retain) UIImageView* separator;



- initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier event:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath;

- update:(WallEvent*)ev indexPath:(NSIndexPath*)indexPath;

@end
