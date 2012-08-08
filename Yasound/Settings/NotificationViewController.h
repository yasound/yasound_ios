//
//  NotificationViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 05/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBar.h"

@interface NotificationViewController : UIViewController<TopBarDelegate>
{
    IBOutlet UITableView* _tableView;
}




@end
