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
#import "ThemeSelectorViewController.h"
#import "Theme.h"
#import "ActivityAlertView.h"
#import "PlaylistMoulinor.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>


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
    //..................................................................................
    // init GUI
    //
    _settingsGotoLabel.text = NSLocalizedString(@"myyasound_settings_goto_label", nil);
    
    _settingsTitleLabel.text = NSLocalizedString(@"myyasound_settings_config_title_label", nil);

    _settingsTitleTextField.text = [NSString stringWithFormat:@"%@'s Yasound", [[UIDevice currentDevice] name]];
    
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
    
    NSString* themeId = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyYasoundTheme"];
    if (themeId == nil)
    {
        themeId = @"theme_default";
        [[NSUserDefaults standardUserDefaults] setObject:themeId forKey:@"MyYasoundTheme"];
    }
    
    Theme* theme = [[Theme alloc] initWithThemeId:themeId];
    _settingsThemeTitle.text = NSLocalizedString(themeId, nil);
    [_settingsThemeImage setImage:theme.icon];
    [theme release];
    
    

    
    [_settingsThemeImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [_settingsThemeImage.layer setBorderWidth: 1];    
    
    _settingsSubmitTitle.text = NSLocalizedString(@"myyasound_settings_submit_title", nil);
    
    
    //......................................................................................
    // init playlists
    //
    MPMediaQuery *playlistsquery = [MPMediaQuery playlistsQuery];

    _playlistsDesc = [[NSMutableArray alloc] init];
    [_playlistsDesc retain];

    _playlists = [playlistsquery collections];
    [_playlists retain];
    
    for (MPMediaPlaylist* list in _playlists)
    {
        NSString* listname = [list valueForProperty: MPMediaPlaylistPropertyName];
        
        NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];
        [dico setObject:listname forKey:@"name"];
        [dico setObject:[NSNumber numberWithInteger:[list count]] forKey:@"count"];
        [_playlistsDesc addObject:dico];
        
        NSLog (@"playlist : %@", listname);
    }
    
    _selectedPlaylists = [[NSMutableArray alloc] init];
    [_selectedPlaylists retain];
    

}



- (void)deallocInSettingsTableView
{
    [_playlists release];
    [_playlistsDesc release];
    [_selectedPlaylists release];
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
        case SECTION_PLAYLISTS: return [_playlistsDesc count];
        case SECTION_SUBMIT: return 1;
    }
    return 0;
}





- (void)willDisplayCellInSettingsTableView:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if (indexPath.section == SECTION_GOTO)
    {
        float value = 224.f/255.f;
        cell.backgroundColor = [UIColor colorWithRed:value  green:value blue:value alpha:1];
    }
    else
    {
        float value = 246.f/255.f;
        cell.backgroundColor = [UIColor colorWithRed:value  green:value blue:value alpha:1];
    }
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
    
    if (indexPath.section == SECTION_PLAYLISTS)
    {
        // default case (playlists)
        UITableViewCell *cell = [_settingsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        
        NSDictionary* dico = [_playlistsDesc objectAtIndex:indexPath.row];
        cell.textLabel.text = [dico objectForKey:@"name"];
        
        if ([_selectedPlaylists containsObject:[_playlists objectAtIndex:indexPath.row]])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d songs", [[dico objectForKey:@"count"] integerValue]];
        
        return cell;
    }
    
  
    return nil;
}


- (void)didSelectInSettingsTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{
     if ((indexPath.section == SECTION_GOTO) && (indexPath.row == 0))
    {
        _settingsGotoLabel.textColor = [UIColor whiteColor];
        
        RadioViewController* view = [[RadioViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
    else if ((indexPath.section == SECTION_CONFIGURATION) && (indexPath.row == ROW_CONFIG_IMAGE))
    {
      _settingsImageLabel.textColor = [UIColor whiteColor];
      UIImagePickerController* picker =  [[UIImagePickerController alloc] init];
      
      picker.delegate = self;
      
//      if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//      {
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//      }
//      else
      {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      }
      
      [self presentModalViewController:picker animated:YES];
    }
    
    else if ((indexPath.section == SECTION_CONFIGURATION) && (indexPath.row == ROW_CONFIG_GENRE))
    {
        _settingsGenreLabel.textColor = [UIColor whiteColor];
        [self openStyleSelector];
    }
    
    else if (indexPath.section == SECTION_THEME)
    {
        _settingsThemeTitle.textColor = [UIColor whiteColor];
        [self openThemeSelector];
    }

    else if (indexPath.section == SECTION_PLAYLISTS)
    {
        UITableViewCell *cell = [_settingsTableView cellForRowAtIndexPath:indexPath];
        MPMediaPlaylist* list = [_playlists objectAtIndex:indexPath.row];
        
        if ([_selectedPlaylists containsObject:list] == YES)
        {
            NSLog(@"deselect\n");
            [_selectedPlaylists removeObject:list];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            NSLog(@"select\n");
            [_selectedPlaylists addObject:list];
            cell.accessoryType = UITableViewCellAccessoryCheckmark; 
        }
        
        cell.selected = FALSE;
    }

    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(unselect:) userInfo:indexPath repeats:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker
{
  [self dismissModalViewControllerAnimated:YES];
  [Picker release];
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  _settingsImageImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
  [self dismissModalViewControllerAnimated:YES];
  [Picker release];
}


- (void)unselect:(NSTimer*)timer
{
    NSIndexPath* indexPath = timer.userInfo;
    UITableViewCell* cell = [_settingsTableView cellForRowAtIndexPath:indexPath];
    cell.selected = FALSE;
    
    if ((indexPath.section == SECTION_GOTO) && (indexPath.row == 0))
    {
        _settingsGotoLabel.textColor = [UIColor blackColor];
    }
    
    else if ((indexPath.section == SECTION_CONFIGURATION) && (indexPath.row == ROW_CONFIG_IMAGE))
    {
        _settingsImageLabel.textColor = [UIColor blackColor];
    }
    
    else if ((indexPath.section == SECTION_CONFIGURATION) && (indexPath.row == ROW_CONFIG_GENRE))
    {
        _settingsGenreLabel.textColor = [UIColor blackColor];
    }
    
    else if (indexPath.section == SECTION_THEME)
    {
        _settingsThemeTitle.textColor = [UIColor blackColor];
    }
    
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



#pragma mark - ThemeSelectorDelegate

- (void)openThemeSelector
{
    ThemeSelectorViewController* view = [[ThemeSelectorViewController alloc] initWithNibName:@"ThemeSelectorViewController" bundle:nil];
    view.delegate = self;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)themeSelected:(NSString*)themeId
{
    [self.navigationController popViewControllerAnimated:YES];

    // set user defaults
    [[NSUserDefaults standardUserDefaults] setObject:themeId forKey:@"MyYasoundTheme"];
    
    // set GUI cell for selected theme
    Theme* theme = [[Theme alloc] initWithThemeId:themeId];
    _settingsThemeTitle.text = NSLocalizedString(themeId, nil);
    [_settingsThemeImage setImage:theme.icon];
    [theme release];
    
    // set the global theme object
    [Theme setTheme:themeId];
}

- (void)themeSelectionCanceled
{
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - IBActions

- (IBAction)onSubmitClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //LBDEBUG
    NSData* data = [[PlaylistMoulinor main] dataWithPlaylists:_selectedPlaylists binary:NO compressed:YES];
    
    //LBDEBUG email playlist file
//    [[PlaylistMoulinor main] emailData:data to:@"neywen@neywen.net" mimetype:@"application/octet-stream" filename:@"yasound_playlist.bin" controller:self];
    
    //fake commnunication
    [ActivityAlertView showWithTitle:NSLocalizedString(@"msg_submit_title", nil) message:NSLocalizedString(@"msg_submit_body", nil)];
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onFakeSubmitAction:) userInfo:nil repeats:NO];
}

//LBDEBUG
- (void)onFakeSubmitAction:(NSTimer*)timer
{
    [ActivityAlertView close];
}


@end
