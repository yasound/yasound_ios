//
//  MyRadiosViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBar.h"
#import "TopBar.h"


@interface MyRadiosViewController : UIViewController<TopBarDelegate, TabBarDelegate>

@property (nonatomic, retain) NSArray* radios;
@property (nonatomic, retain) IBOutlet UITableView* tableview;
@property (nonatomic, retain) IBOutlet TabBar* tabBar;

@end
