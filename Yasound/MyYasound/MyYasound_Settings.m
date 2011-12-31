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
#import "PlaylistsViewController.h"
#import "SettingsViewController.h"
#import "PlaylistMoulinor.h"
#import <QuartzCore/QuartzCore.h>


@implementation MyYasoundViewController (Settings)


#define SECTION_GOTO 0
#define SECTION_STATS 1
#define SECTION_CONFIG 2
#define SECTION_LEGAL 3

#define ROW_GOTO 0
#define ROW_STATS_BRIEF 0
#define ROW_STATS_ACCESS 1
#define ROW_CONFIG_PLAYLISTS 0
#define ROW_CONFIG_SETTINGS 1
#define ROW_LEGAL 0


#define GRAPH_X 5
#define GRAPH_Y 5
#define GRAPH_WIDTH 290
#define GRAPH_HEIGHT 72

- (void)viewDidLoadInSettingsTableView
{
    _graphView = [[ChartView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    _graphView.dataSource = self;
}



- (void)deallocInSettingsTableView
{
}











#pragma mark - TableView Source and Delegate



- (NSInteger)numberOfSectionsInSettingsTableView
{
    return 4;
}


//- (NSString*)titleInSettingsTableViewForHeaderInSection:(NSInteger)section
//{
//    switch (section) 
//    {
//        case SECTION_GOTO: return nil;
//        case SECTION_CONFIGURATION: return NSLocalizedString(@"myyasound_settings_configuration", nil);
//        case SECTION_THEME: return NSLocalizedString(@"myyasound_settings_theme", nil);
//        case SECTION_PLAYLISTS: return NSLocalizedString(@"myyasound_settings_playlists", nil);
//        case SECTION_SUBMIT: nil;
//    }
//    return nil;
//}



- (NSInteger)numberOfRowsInSettingsTableViewSection:(NSInteger)section 
{
    switch (section) 
    {
        case SECTION_GOTO: return 1;
        case SECTION_STATS: return 2;
        case SECTION_CONFIG: return 2;
        case SECTION_LEGAL: return 1;
    }
    return 0;
}


- (CGFloat) heightInSettingsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_BRIEF))
        return GRAPH_HEIGHT;
    
    return 44;
}



//- (void)willDisplayCellInSettingsTableView:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
//{
//    if (indexPath.section == SECTION_GOTO)
//    {
//        float value = 224.f/255.f;
//        cell.backgroundColor = [UIColor colorWithRed:value  green:value blue:value alpha:1];
//    }
//    else
//    {
//        float value = 246.f/255.f;
//        cell.backgroundColor = [UIColor colorWithRed:value  green:value blue:value alpha:1];
//    }
//}


- (UITableViewCell *)cellInSettingsTableViewForRowAtIndexPath:(NSIndexPath *)indexPath 
{

    static NSString* CellIdentifier = @"Cell";

    UITableViewCell *cell = [_settingsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    if ((indexPath.section == SECTION_GOTO) && (indexPath.row == ROW_GOTO))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setImage:[UIImage imageNamed:@"iconMyRadio.png"]];
        cell.textLabel.text = NSLocalizedString(@"MyYasoundSettings_goto_label", nil);
    }
    else if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_BRIEF))
    {
        CGRect frame = CGRectMake(GRAPH_X, GRAPH_Y, GRAPH_WIDTH, GRAPH_HEIGHT - GRAPH_Y - 2);
        _graphBoundingBox = [[UIView alloc] initWithFrame:frame];
        [cell.contentView addSubview:_graphBoundingBox];

        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _graphView.frame = frame;
        [_graphBoundingBox addSubview:_graphView];
        _graphView.clipsToBounds = YES;

        
    }
    else if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_ACCESS))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setImage:[UIImage imageNamed:@"iconStats.png"]];
        cell.textLabel.text = NSLocalizedString(@"MyYasoundSettings_stats_label", nil);
    }
    else if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_PLAYLISTS))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setImage:[UIImage imageNamed:@"iconPlaylists.png"]];
        cell.textLabel.text = NSLocalizedString(@"MyYasoundSettings_config_playlists_label", nil);
    }
    else if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_SETTINGS))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setImage:[UIImage imageNamed:@"iconSettings.png"]];
        cell.textLabel.text = NSLocalizedString(@"MyYasoundSettings_config_settings_label", nil);
    }
    else if ((indexPath.section == SECTION_LEGAL) && (indexPath.row == ROW_LEGAL))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setImage:[UIImage imageNamed:@"iconLegal.png"]];
        cell.textLabel.text = NSLocalizedString(@"MyYasoundSettings_legal_label", nil);
    }

    
  
    return cell;
}


- (void)didSelectInSettingsTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{
     if ((indexPath.section == SECTION_GOTO) && (indexPath.row == ROW_GOTO))
    {
        RadioViewController* view = [[RadioViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    
    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_PLAYLISTS))
    {
        PlaylistsViewController* view = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil wizard:NO];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    

    if ((indexPath.section == SECTION_CONFIG) && (indexPath.row == ROW_CONFIG_SETTINGS))
    {
        SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:NO];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }


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
