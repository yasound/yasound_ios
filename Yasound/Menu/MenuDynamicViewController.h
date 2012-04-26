//
//  MenuDynamicViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"
#import "NotificationTableViewCell.h"

@interface MenuDynamicViewController : TestflightViewController
{
    IBOutlet UITableView* _tableView;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
  
  NotificationTableViewCell* _notificationsCell;
}


@property (nonatomic, retain) NSArray* sections;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSections:(NSArray*)sections;


- (IBAction)nowPlayingClicked:(id)sender;

@end
