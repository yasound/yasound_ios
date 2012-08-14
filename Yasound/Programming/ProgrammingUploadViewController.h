//
//  ProgrammingUploadViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 24/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "WheelSelector.h"
#import "Radio.h"

@interface ProgrammingUploadViewController : UITableViewController
{
//    IBOutlet UIBarButtonItem* _backBtn;
//    IBOutlet UILabel* _titleLabel;
//    IBOutlet UITableView* _tableView;
}

@property (nonatomic, retain) Radio* radio;
//@property (nonatomic, retain) WheelSelector* wheelSelector;

- (id)initWithStyle:(UITableViewStyle)style  forRadio:(Radio*)radio;
- (void)setSegment:(NSInteger)index;

@end
