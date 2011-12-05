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
#import "StyleSelectorViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation MyYasoundViewController (Settings)


#define SECTION_GOTO 0
#define SECTION_CONFIGURATION 1
#define SECTION_THEME 2
#define SECTION_PLAYLISTS 3
#define SECTION_SUBMIT 4

#define ROW_CONFIG_TITLE 0
#define ROW_CONFIG_IMAGE 1
#define ROW_CONFIG_GENRE 2


- (void)viewDidLoadInSettingsTableView
{
    _settingsGotoLabel.text = NSLocalizedString(@"myyasound_settings_goto_label", nil);
    
    _settingsTitleLabel.text = NSLocalizedString(@"myyasound_settings_config_title_label", nil);

    _settingsTitleTextField.text = @"User's Yasound";
    
    _settingsImageLabel.text = NSLocalizedString(@"myyasound_settings_config_image_label", nil);
//    _settingsImageImage;

    [_settingsImageImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [_settingsImageImage.layer setBorderWidth: 1];    
    
    _settingsGenreLabel.text = NSLocalizedString(@"myyasound_settings_config_genre_label", nil);
    NSString* style = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyYasoundGenre"];
    _settingsGenreTitle.text = NSLocalizedString(style, nil);
    
//    _settingsGenreTitle;
    
//    _settingsThemeTitle = @"";
//    _settingsThemeImage;
    [_settingsThemeImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [_settingsThemeImage.layer setBorderWidth: 1];    
    
    _settingsSubmitTitle.text = NSLocalizedString(@"myyasound_settings_submit_title", nil);
}



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
    if ((indexPath.section == SECTION_GOTO) && (indexPath.row == 0))
    {
        _settingsGotoLabel.textColor = [UIColor whiteColor];
        return;
    }
    
    if ((indexPath.section == SECTION_CONFIGURATION) && (indexPath.row == ROW_CONFIG_GENRE))
    {
        [self openStyleSelector];
        return;
    }
    
    
    
//  RadioViewController* view = [[RadioViewController alloc] init];
//  [self.navigationController pushViewController:view animated:YES];
//  [view release];
}




#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:TRUE];
    return FALSE;
}




#pragma mark - StyleSelectorDelegate


- (void)openStyleSelector
{
    StyleSelectorViewController* view = [[StyleSelectorViewController alloc] initWithNibName:@"StyleSelectorViewController" bundle:nil target:self];
    //  self.navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentModalViewController:view animated:YES];
}


- (void)didSelectStyle:(NSString*)style
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:style forKey:@"MyYasoundGenre"];
    
    _settingsGenreTitle.text = NSLocalizedString(style, nil);
}

- (void)cancelSelectStyle
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



@end
