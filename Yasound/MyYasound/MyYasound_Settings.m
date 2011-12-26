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
#import "ActivityAlertView.h"
#import "PlaylistMoulinor.h"
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
    /*
    //..................................................................................
    // init GUI
    //
    _settingsGotoLabel.text = NSLocalizedString(@"myyasound_settings_goto_label", nil);
    
    
    _settingsSubmitTitle.text = NSLocalizedString(@"myyasound_settings_submit_title", nil);
    
    
     */
    

}



- (void)deallocInSettingsTableView
{
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
//        case SECTION_PLAYLISTS: return [_playlistsDesc count];
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
    /*
    static NSString* CellIdentifier = @"Cell";
    
    if ((indexPath.section == SECTION_GOTO) && (indexPath.row == 0))
        return _settingsGotoCell;


    if ((indexPath.section == SECTION_SUBMIT) && (indexPath.row == 0))
    {
        UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        _settingsSubmitCell.backgroundColor = [UIColor clearColor];
        _settingsSubmitCell.backgroundView = backView;
        
        return _settingsSubmitCell;
    }
    
     */
    
  
    return nil;
}


- (void)didSelectInSettingsTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     if ((indexPath.section == SECTION_GOTO) && (indexPath.row == 0))
    {
        _settingsGotoLabel.textColor = [UIColor whiteColor];
        
        RadioViewController* view = [[RadioViewController alloc] init];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    


    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(unselect:) userInfo:indexPath repeats:NO];
     */
}



- (void)unselect:(NSTimer*)timer
{
    /*
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
     */
    
}





#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:TRUE];
    return FALSE;
}







#pragma mark - IBActions

- (IBAction)onSubmitClicked:(id)sender
{    
//    //fake commnunication
//    [ActivityAlertView showWithTitle:NSLocalizedString(@"msg_submit_title", nil) message:NSLocalizedString(@"msg_submit_body", nil)];
//
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    [[PlaylistMoulinor main] buildDataWithPlaylists:_selectedPlaylists binary:NO compressed:YES target:self action:@selector(didBuildDataWithPlaylist:)];
}



- (void) didBuildDataWithPlaylist:(NSData*)data
{
    //LBDEBUG email playlist file
      //  [[PlaylistMoulinor main] emailData:data to:@"neywen@neywen.net" mimetype:@"application/octet-stream" filename:@"yasound_playlist.bin" controller:self];

    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onFakeSubmitAction:) userInfo:nil repeats:NO];
}


//LBDEBUG
- (void)onFakeSubmitAction:(NSTimer*)timer
{
    [ActivityAlertView close];
}


@end
