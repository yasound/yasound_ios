//
//  MyYasoundSettingsTableView.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "MyYasoundViewController.h"
#import "RadioSelectionTableViewCell.h"
#import "BundleFileManager.h"
#import "RadioViewController.h"


@implementation MyYasoundViewController (Settings)



#pragma mark - TableView Source and Delegate



- (NSInteger)numberOfSectionsInSettingsTableView
{
  return 1;
}



- (NSInteger)numberOfRowsInSettingsTableViewSection:(NSInteger)section 
{
  // Number of rows is the number of time zones in the region for the specified section.
  if (_segmentControl.selectedSegmentIndex == 1)
    return 24;
  else if (_segmentControl.selectedSegmentIndex == 2)
    return 16;
  
  return 0;
}







- (UITableViewCell *)cellInSettingsTableViewForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  
  static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
  
  //LBDEBUG
  NSDictionary* data = (_segmentControl.selectedSegmentIndex == 1)? [gFakeUsersFriends objectAtIndex:(indexPath.row % 3)] : [gFakeUsersFavorites objectAtIndex:(indexPath.row % 3)];
  
  RadioSelectionTableViewCell* cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:indexPath.row data:data];
  
  
  return cell;
}

- (void)didSelectInSettingsTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{
  RadioViewController* view = [[RadioViewController alloc] init];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}



@end
