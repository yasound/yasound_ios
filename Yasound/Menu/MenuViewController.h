//
//  MenuViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaViewController.h"
#import "TopBar.h"

@interface MenuViewController : YaViewController
{
    IBOutlet UITableView* _tableView;
}

@property (nonatomic, retain) IBOutlet TopBar* topBar;


@end
