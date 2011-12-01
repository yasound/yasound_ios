//
//  RadioViewCell.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Message;

@interface RadioViewCell : UITableViewCell

@property (nonatomic, retain) UIView* background;
@property (nonatomic, retain) UIImageView* avatar;
@property (nonatomic, retain) UILabel* date;
@property (nonatomic, retain) UILabel* user;
@property (nonatomic, retain) UILabel* message;

- initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier message:(Message*)m indexPath:(NSIndexPath*)indexPath;

- update:(Message*)m indexPath:(NSIndexPath*)indexPath;

@end
