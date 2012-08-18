//
//  SchedulingViewController.h
//  Yasound
//
//  Created by neywen on 11/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"
#import "TopBarBackAndTitle.h"

@interface SchedulingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,TopBarBackAndTitleDelegate>

@property (nonatomic, retain) IBOutlet TopBarBackAndTitle* topBar;
@property (nonatomic, retain) IBOutlet UITableView* tableview;

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) NSArray* shows;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(Radio*)radio;

@end
