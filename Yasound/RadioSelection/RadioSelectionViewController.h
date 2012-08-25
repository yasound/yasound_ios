//
//  RadioSelectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>
#import "YaViewController.h"
#import "WheelSelector.h"
#import "WheelRadiosSelector.h"
#import "RadioListTableViewController.h"
#import "TabBar.h"
#import "TopBar.h"
#import "MenuViewController.h"

@interface RadioSelectionViewController : YaViewController<TopBarDelegate, RadioListDelegate, TabBarDelegate>
{
    TabIndex _tabIndex;
}

@property (nonatomic) BOOL locked;

@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) IBOutlet TopBar* topbar;

//@property (nonatomic) NSInteger nbFriends;
//@property (nonatomic, retain) NSMutableArray* friendsRadios;
@property (nonatomic, retain) NSArray* friends;

@property (nonatomic, retain) IBOutlet WheelSelector* wheelSelector;
@property (nonatomic, retain) IBOutlet UIView* listContainer;
@property (nonatomic, retain) UITableViewController* tableview;
@property (nonatomic, retain) IBOutlet TabBar* tabBar;

@property (nonatomic, retain) MenuViewController* menu;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTabIndex:(TabIndex)tabIndex;


@end
