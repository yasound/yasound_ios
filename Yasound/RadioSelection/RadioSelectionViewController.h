//
//  RadioSelectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"
#import "WheelSelector.h"
#import "RadioListTableViewController.h"
#import "TabBar.h"

@interface RadioSelectionViewController : TestflightViewController<RadioListDelegate, TabBarDelegate>

@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) IBOutlet WheelSelector* wheelSelector;
@property (nonatomic, retain) IBOutlet UIView* listContainer;
@property (nonatomic, retain) UITableViewController* tableview;
@property (nonatomic, retain) IBOutlet TabBar* tabBar;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (IBAction)onStyleSelectorClicked:(id)sender;
- (IBAction)onNowPlayingClicked:(id)sender;

@end
