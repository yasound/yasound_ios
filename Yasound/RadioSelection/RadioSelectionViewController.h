//
//  RadioSelectionViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 23/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"


@interface RadioSelectionViewController : TestflightViewController

@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) UITableView* tableview;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUrl:(NSURL*)url;

- (IBAction)onStyleSelectorClicked:(id)sender;
- (IBAction)onNowPlayingClicked:(id)sender;

@end
