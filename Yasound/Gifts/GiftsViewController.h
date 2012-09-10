//
//  GiftsViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBar.h"
#import "TopBar.h"


@interface GiftsViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIImageView* iconHd;
@property (nonatomic, retain) IBOutlet UILabel* labelHd;
@property (nonatomic, retain) IBOutlet UISwitch* switchHd;

@property(nonatomic, retain) NSArray* gifts;

- (IBAction)hdSwitchChanged:(id)sender;

@end
