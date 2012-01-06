//
//  MyYasoundSelectionTableView.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "MyYasoundViewController.h"
#import "RadioSelectionTableViewCell.h"
#import "BundleFileManager.h"
#import "RadioViewController.h"


@implementation MyYasoundViewController (RadioSelection)



- (void)deallocInRadioSelection
{

}


#pragma mark - TableView Source and Delegate



- (NSInteger)numberOfSectionsInSelectionTableView
{
  return 1;
}



- (NSInteger)numberOfRowsInSelectionTableViewSection:(NSInteger)section 
{
  // Number of rows is the number of time zones in the region for the specified section.
  if (_segmentControl.selectedSegmentIndex == 1)
    return 24;
  else if (_segmentControl.selectedSegmentIndex == 2)
    return 16;
  
  return 0;
}





- (UITableViewCell *)cellInSelectionTableViewForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  
  static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
  
  //LBDEBUG
//  NSDictionary* data = (_segmentControl.selectedSegmentIndex == 1)? [gFakeUsersFriends objectAtIndex:(indexPath.row % 3)] : [gFakeUsersFavorites objectAtIndex:(indexPath.row % 3)];

    NSInteger rowIndex = indexPath.row;
    
    Radio* radio = [_radios objectAtIndex:rowIndex];
    
    RadioSelectionTableViewCell* cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];
  
  return cell;
}


- (void)didSelectInSelectionTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioViewController* view = [[RadioViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}



@end
