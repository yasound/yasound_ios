//
//  NotificationViewCell.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NotificationViewCell : UITableViewCell

//@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UISwitch* notifSwitch;
@property (nonatomic, retain) NSString* notifIdentifier;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)CellIdentifier notifIdentifier:(NSString*)notifIdentifier;

- (void)update:(NSString*)notifIdentifier;

@end
