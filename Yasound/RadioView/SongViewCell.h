//
//  SongViewCell.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WallEvent;

@interface SongViewCell : UITableViewCell

@property (nonatomic, retain) UILabel* date;
@property (nonatomic, retain) UILabel* message;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier event:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath;

- (void)update:(WallEvent*)ev height:(CGFloat)height indexPath:(NSIndexPath*)indexPath;

@end
