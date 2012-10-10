//
//  WallPostCell.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//
//

#import <UIKit/UIKit.h>



@interface WallPostCell : UITableViewCell

@property (nonatomic) BOOL fixed;
@property (nonatomic, retain) IBOutlet UITextField* textfield;
@property (nonatomic, retain) IBOutlet UIButton* button;
@property (nonatomic, retain) IBOutlet UILabel* label;

@end



