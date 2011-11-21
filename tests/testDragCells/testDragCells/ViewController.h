//
//  ViewController.h
//  testDragCells
//
//  Created by LOIC BERTHELOT on 21/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
  IBOutlet UITableView* _tableView;
  NSIndexPath* _selectedRow;
//  BOOL _gestureBegan;
//  BOOL _gestureEnded;
}

- (IBAction)onButtonClicked:(id)sender;

@end
