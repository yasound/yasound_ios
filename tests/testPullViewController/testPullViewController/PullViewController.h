//
//  PullViewController.h
//  testPullViewController
//
//  Created by LOIC BERTHELOT on 21/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../../testDragCells/testDragCells/DraggableTableView.h"


@interface PullViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
  IBOutlet UITableView* _tableView;
}


@property (retain) DraggableTableView* draggableTableView;



@end
