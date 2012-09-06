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


@interface GiftsViewController : UIViewController<TopBarDelegate, TabBarDelegate>

@property (nonatomic, retain) IBOutlet TabBar* tabBar;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property(nonatomic, retain) NSArray* gifts;

@end
