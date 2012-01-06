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
    if (_radios == nil)
        return 0;
    
  return 1;
}



- (NSInteger)numberOfRowsInSelectionTableViewSection:(NSInteger)section 
{
    if (_radios == nil)
        return 0;
    
    return _radios.count;
}





- (UITableViewCell *)cellInSelectionTableViewForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  
  static NSString *cellIdentifier = @"RadioSelectionTableViewCell";
  
    NSInteger rowIndex = indexPath.row;
    
    Radio* radio = [_radios objectAtIndex:rowIndex];
    
    RadioSelectionTableViewCell* cell = [[RadioSelectionTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier rowIndex:rowIndex radio:radio];
  
  return cell;
}


- (void)didSelectInSelectionTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{    
    RadioSelectionTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:cell.radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}



@end
