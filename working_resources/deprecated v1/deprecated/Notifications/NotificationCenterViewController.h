//
//  NotificationCenterViewController.h
//  Yasound
//
//  Created by matthieu campion on 4/4/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCenterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
  IBOutlet UILabel* _topBarTitle;
  IBOutlet UIBarButtonItem* _nowPlayingButton;
  IBOutlet UITableView* _tableView;
}

- (IBAction)onNowPlayingClicked:(id)sender;
- (IBAction)onMenuBarItemClicked:(id)sender;

@end
