//
//  NotificationCenterViewController.h
//  Yasound
//
//  Created by matthieu campion on 4/4/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBar.h"

@interface NotificationCenterViewController : YaViewController <UITableViewDataSource, UITableViewDelegate>
{
  IBOutlet UITableView* _tableView;
    
    BOOL _waitingForPreviousEvents;
    UIAlertView* _alertTrash;
    UIAlertView* _alertGoToLogin;
}

@property (nonatomic, retain) IBOutlet TopBar* topBar;

@property (nonatomic, retain) NSMutableArray* notifications;
@property (nonatomic, retain) NSMutableDictionary* notificationsDictionary;


@end
