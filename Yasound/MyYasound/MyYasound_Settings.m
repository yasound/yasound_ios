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


#define SECTION_GOTO 0
#define SECTION_CONFIGURATION 1
#define SECTION_THEME 2
#define SECTION_PLAYLISTS 3
#define SECTION_SUBMIT 4

#define ROW_CONFIG_TITLE 0
#define ROW_CONFIG_IMAGE 1
#define ROW_CONFIG_GENRE 2


#pragma mark - TableView Source and Delegate



- (NSInteger)numberOfSectionsInSettingsTableView
{
    return 5;
}


- (NSString*)titleInSettingsTableViewForHeaderInSection:(NSInteger)section
{
    switch (section) 
    {
        case SECTION_GOTO: return nil;
        case SECTION_CONFIGURATION: return NSLocalizedString(@"myyasound_settings_configuration", nil);
        case SECTION_THEME: return NSLocalizedString(@"myyasound_settings_theme", nil);
        case SECTION_PLAYLISTS: return NSLocalizedString(@"myyasound_settings_playlists", nil);
        case SECTION_SUBMIT: nil;
    }
    return nil;
}



- (NSInteger)numberOfRowsInSettingsTableViewSection:(NSInteger)section 
{
    switch (section) 
    {
        case SECTION_GOTO: return 1;
        case SECTION_CONFIGURATION: return 3;
        case SECTION_THEME: return 1;
        case SECTION_PLAYLISTS: return 4;
        case SECTION_SUBMIT: return 1;
    }
    return 0;
}







- (UITableViewCell *)cellInSettingsTableViewForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    if ((indexPath.section == SECTION_GOTO) && (indexPath.row == 0))
        return _settingsGotoCell;

    if ((indexPath.section == SECTION_CONFIGURATION) && (indexPath.row == ROW_CONFIG_TITLE))
        return _settingsTitleCell;

    if ((indexPath.section == SECTION_CONFIGURATION) && (indexPath.row == ROW_CONFIG_IMAGE))
        return _settingsImageCell;
    
    if ((indexPath.section == SECTION_CONFIGURATION) && (indexPath.row == ROW_CONFIG_GENRE))
        return _settingsGenreCell;
    
    if ((indexPath.section == SECTION_THEME) && (indexPath.row == 0))
        return _settingsThemeCell;

    if ((indexPath.section == SECTION_SUBMIT) && (indexPath.row == 0))
    {
        UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        _settingsSubmitCell.backgroundColor = [UIColor clearColor];
        _settingsSubmitCell.backgroundView = backView;
        
        return _settingsSubmitCell;
    }

    
    // default case (playlists)
	UITableViewCell *cell = [_settingsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
  
    return cell;
}


- (void)didSelectInSettingsTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{
//  RadioViewController* view = [[RadioViewController alloc] init];
//  [self.navigationController pushViewController:view animated:YES];
//  [view release];
}



@end
