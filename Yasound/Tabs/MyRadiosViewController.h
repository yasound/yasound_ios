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

<<<<<<< HEAD
@property (nonatomic, retain) NSArray* radios;
=======
@property (nonatomic, retain) IBOutlet UITableView* tableview;
>>>>>>> 31c5e45820da1132c02cbc50976b2893bf8ec065
@property (nonatomic, retain) IBOutlet TabBar* tabBar;
@property (nonatomic, retain) NSArray* radios;

@end
