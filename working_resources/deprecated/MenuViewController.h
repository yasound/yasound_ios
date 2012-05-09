//
//  MenuViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"
#import "NotificationTableViewCell.h"

@interface MenuViewController : TestflightViewController
{
    IBOutlet UITableView* _tableView;
    IBOutlet UIBarButtonItem* _nowPlayingButton;
  
  NotificationTableViewCell* _notificationsCell;
}


- (IBAction)nowPlayingClicked:(id)sender;

@end