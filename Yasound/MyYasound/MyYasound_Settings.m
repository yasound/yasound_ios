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
    return 4;
}


- (NSString*)titleInSettingsTableViewForHeaderInSection:(NSInteger)section
{
    switch (section) 
    {
        case 0: return NSLocalizedString(@"myyasound_settings_configuration", nil);
        case 1: return NSLocalizedString(@"myyasound_settings_playlists", nil);
        case 2: return NSLocalizedString(@"myyasound_settings_theme", nil);
        case 3: nil;
    }
    return nil;
}



- (NSInteger)numberOfRowsInSettingsTableViewSection:(NSInteger)section 
{
    switch (section) 
    {
        case 0: return 3;
        case 1: return 4;
        case 2: return 4;
        case 3: 1;
    }
    return 0;
}







- (UITableViewCell *)cellInSettingsTableViewForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"MyIdentifier";
    
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
  
    return cell;
}


- (void)didSelectInSettingsTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{
  RadioViewController* view = [[RadioViewController alloc] init];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
}



@end
