//
//  NotificationViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 05/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarModal.h"

@interface NotificationViewController : YaViewController<TopBarModalDelegate>
{
    IBOutlet UITableView* _tableView;
}

@property (nonatomic, retain) IBOutlet TopBarModal* topbar;



@end
