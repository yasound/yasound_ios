//
//  MyYasoundViewController.m
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
#import "Theme.h"

#import "PlaylistsViewController.h"
#import "SettingsViewController.h"
#import "StatsViewController.h"
#import "PlaylistMoulinor.h"
#import "LegalViewController.h"
#import "S7Macros.h"
#import <QuartzCore/QuartzCore.h>
#import "YasoundSessionManager.h"
#import "RootViewController.h"
#import "AudioStreamManager.h"


#define SECTION_GOTO 0
#define SECTION_STATS 1
#define SECTION_CONFIG 2
#define SECTION_DIVERS 3

#define ROW_GOTO 0
#define ROW_STATS_BRIEF 0
#define ROW_STATS_ACCESS 1
#define ROW_CONFIG_PLAYLISTS 0
#define ROW_CONFIG_SETTINGS 1
#define ROW_LEGAL 0
#define ROW_LOGOUT 1


#define GRAPH_X 5
#define GRAPH_Y 5
#define GRAPH_WIDTH 290
#define GRAPH_HEIGHT 72


@implementation MyYasoundViewController

//@synthesize viewContainer;
//@synthesize viewMyYasound;
//@synthesize viewSelection;





- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title tabIcon:(NSString*)tabIcon
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _myRadio = nil;
        
      UIImage* tabImage = [UIImage imageNamed:tabIcon];
      UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:title image:tabImage tag:0];
      self.tabBarItem = theItem;
      [theItem release];   

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    if (_radios != nil)
        [_radios release];

    [_thisWeekDates release];
    [_thisWeekValues release];
    [_thisMonthDates release];
    [_thisMonthValues release];
    [_graphView release];
    
//    [self deallocInSettingsTableView];
//    [self deallocInRadioSelection];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _toolbarTitle.text = NSLocalizedString(@"MyYasound_title", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    //ICI
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"RadioViewStatusBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    [_toolbar insertSubview:[[[UIImageView alloc] initWithImage:[sheet image]] autorelease] atIndex:1];
    
    
//    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    [self.view addSubview:_tableView];


    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MyYasoundBackground.png"]];


    _graphView = [[ChartView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) minimalDisplay:YES];
    [_graphView retain];
    //    _graphView.dataSource = self;
    
    
    
    
    // fake data for graph, waiting for the server request to be implemented
    _thisMonthDates = [[NSMutableArray alloc] initWithCapacity:31];
    _thisMonthValues = [[NSMutableArray alloc] initWithCapacity:31];
    
    [_thisMonthDates retain];
    [_thisMonthValues retain];
    
    NSCalendar*       calendar = [[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar] autorelease];
    NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
    components.day = 0;
    NSDate* today = [NSDate date];
    
    srand(time(NULL));
    NSInteger previousValue = 0;
    for (int i = 0; i < 31; i++)
    {
        components.day = i - 31;
        NSDate* newDate = [calendar dateByAddingComponents:components toDate:today options:0];
        
        
        NSInteger incr = (rand() % 500)+1;
        NSInteger delta = rand() % incr;
        if (rand() & 1) delta *= (-1);
        NSInteger value = previousValue + delta;
        if (value < 0)
            value = 0;
        
        [_thisMonthDates addObject:newDate];
        [_thisMonthValues addObject:[NSNumber numberWithInteger:value]];
        
        previousValue = value;
    }
    
    
    // now, get "this week" data
    _thisWeekDates = [[NSMutableArray alloc] initWithCapacity:7];
    _thisWeekValues = [[NSMutableArray alloc] initWithCapacity:7];
    [_thisWeekDates retain];
    [_thisWeekValues retain];
    for (int i = 0; i < 7; i++)
    {
        NSInteger index = 31 - 7 + i;
        [_thisWeekDates insertObject:[_thisMonthDates objectAtIndex:index] atIndex:i];
        [_thisWeekValues insertObject:[_thisMonthValues objectAtIndex:index] atIndex:i];
    }
    
    _graphView.dates = _thisWeekDates;
    _graphView.values = _thisWeekValues;
    [_graphView reloadData];
    
//    BundleStylesheet* stylesheet = [[BundleFileManager main] stylesheetForKey:@"GuiTintColor" error:nil];
//    _toolbar.tintColor = stylesheet.color;
//
//
//    _viewCurrent = self.viewMyYasound;
//    [self.viewContainer addSubview:_viewCurrent];
//
//    _segmentControl = (UISegmentedControl *) [_segmentBarButtonItem customView];
//
//    [_segmentControl setTitle:NSLocalizedString(@"myyasound_tab_myyasound", nil) forSegmentAtIndex:0];
//    [_segmentControl setTitle:NSLocalizedString(@"myyasound_tab_friends", nil) forSegmentAtIndex:1];
//    [_segmentControl setTitle:NSLocalizedString(@"myyasound_tab_favorites", nil) forSegmentAtIndex:2];
//
//    [_segmentControl addTarget:self action:@selector(onmSegmentClicked:) forControlEvents:UIControlEventValueChanged];
//    
//    [self viewDidLoadInSettingsTableView];    
}





- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
    
    if ([AudioStreamManager main].currentRadio == nil)
        _nowPlayingButton.enabled = NO;
    
    // update radio
    [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(onGetRadio:info:)];
}


#pragma mark - YasoundDataProvider

- (void)onGetRadio:(Radio*)radio info:(NSDictionary*)info
{
    _myRadio = radio;

    // automatic launch
    BOOL _automaticLaunch =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"automaticLaunch"] boolValue];
    
    if (_automaticLaunch)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"automaticLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // display radio automatically
        RadioViewController* view = [[RadioViewController alloc] initWithRadio:_myRadio];
        
        // TAG ACTIVITY ALERT
        [ActivityAlertView close];
        
        [self.navigationController pushViewController:view animated:NO];
        [view release];
        return;
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
//    [_settingsTableView deselectRowAtIndexPath:[_settingsTableView indexPathForSelectedRow] animated:NO];    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}









#pragma mark - IBActions

- (IBAction)nowPlayingClicked:(id)sender
{
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:[AudioStreamManager main].currentRadio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


//- (IBAction)onmSegmentClicked:(id)sender
//{
//  switch (_segmentControl.selectedSegmentIndex)
//  {
//    case 0:
//      [_viewCurrent removeFromSuperview];
//      _viewCurrent = self.viewMyYasound;
//      [self.viewContainer addSubview:_viewCurrent];
//      break;
//      
//    case 1:
//          [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioSelection_update", nil)];
//        [_viewCurrent removeFromSuperview];
//        _viewCurrent = self.viewSelection;
//        [self.viewContainer addSubview:_viewCurrent];
//        [[YasoundDataProvider main] friendsRadiosWithGenre:nil withTarget:self action:@selector(onRadioSelectionReceived:)];
//        break;
//      
//    case 2:
//          [ActivityAlertView showWithTitle:NSLocalizedString(@"RadioSelection_update", nil)];
//      [_viewCurrent removeFromSuperview];
//      _viewCurrent = self.viewSelection;
//      [self.viewContainer addSubview:_viewCurrent];
//      [[YasoundDataProvider main] favoriteRadiosWithGenre:nil withTarget:self action:@selector(onRadioSelectionReceived:)];
//      break;
//  }
//  
//
//}



- (void)onRadioSelectionReceived:(NSArray*)radios
{
    if (_radios != nil)
        [_radios release];
    
    _radios = radios;
    [_radios retain];
    
    [_tableView reloadData];
    [ActivityAlertView close];
}



#pragma mark - TableView Source and Delegate


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
//{
//    if (tableView == _settingsTableView)
//        return [self titleInSettingsTableViewForHeaderInSection:section];
//    
//    return nil;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;

//    if (tableView == _settingsTableView)
//        return [self numberOfSectionsInSettingsTableView];
//    
//    return [self numberOfSectionsInSelectionTableView];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    switch (section) 
    {
        case SECTION_GOTO: return 1;
        case SECTION_STATS: return 2;
        case SECTION_CONFIG: return 2;
        case SECTION_DIVERS: return 2;
    }
    return 0;

    
    //    if (tableView == _settingsTableView)
//        return [self numberOfRowsInSettingsTableViewSection:section];
//        
//    return [self numberOfRowsInSelectionTableViewSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_BRIEF))
        return GRAPH_HEIGHT;
    
    return 44;

    //    if (tableView == _settingsTableView)
//        return [self heightInSettingsForRowAtIndexPath:indexPath];
//    
//    return 55;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_BRIEF))
    {
        cell.backgroundColor = COLOR_CHART_BACKGROUND;
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }

    //    if (tableView == _settingsTableView)
//        [self willDisplayCellInSettingsTableView:cell forRowAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect frame = CGRectMake(GRAPH_X, GRAPH_Y, GRAPH_WIDTH, GRAPH_HEIGHT - GRAPH_Y - 2);
        _graphBoundingBox = [[UIView alloc] initWithFrame:frame];
        _graphBoundingBox.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:_graphBoundingBox];
        
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _graphView.frame = frame;
        _graphView.backgroundColor = COLOR_CHART_BACKGROUND;
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
    else if ((indexPath.section == SECTION_DIVERS) && (indexPath.row == ROW_LEGAL))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setImage:[UIImage imageNamed:@"iconLegal.png"]];
        cell.textLabel.text = NSLocalizedString(@"MyYasoundSettings_legal_label", nil);
    }
    else if ((indexPath.section == SECTION_DIVERS) && (indexPath.row == ROW_LOGOUT))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setImage:[UIImage imageNamed:@"iconLogout.png"]];
        cell.textLabel.text = NSLocalizedString(@"MyYasoundSettings_logout_label", nil);
    }
    
    
    
    return cell;

    //    if (tableView == _tableView)
//        return [self cellInSettingsTableViewForRowAtIndexPath:indexPath];
//    
//    return [self cellInSelectionTableViewForRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_GOTO) && (indexPath.row == ROW_GOTO))
    {
        RadioViewController* view = [[RadioViewController alloc] initWithRadio:_myRadio];
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
        SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:NO radio:_myRadio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    if ((indexPath.section == SECTION_STATS) && (indexPath.row == ROW_STATS_ACCESS))
    {
        StatsViewController* view = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil];
        view.weekGraphView.dates = _thisWeekDates;
        view.weekGraphView.values = _thisWeekValues;
        view.monthGraphView.dates = _thisMonthDates;
        view.monthGraphView.values = _thisMonthValues;
        [view reloadData];
        
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;    
    }
    
    if ((indexPath.section == SECTION_DIVERS) && (indexPath.row == ROW_LEGAL))
    {
        LegalViewController* view = [[LegalViewController alloc] initWithNibName:@"LegalViewController" bundle:nil wizard:NO];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    if ((indexPath.section == SECTION_DIVERS) && (indexPath.row == ROW_LOGOUT))
    {
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
        
        UIActionSheet* popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_logout_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SettingsView_logout_logout", nil), nil];
        
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [popupQuery showFromTabBar:self.view];
        [popupQuery release];
        
        return;
    }

    
    //    if (tableView == _settingsTableView)
//    {
//        [self didSelectInSettingsTableViewRowAtIndexPath:indexPath];
//        return;
//    }
//    
//    [self didSelectInSelectionTableViewRowAtIndexPath:indexPath];
}





#pragma mark - ActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{    
    if (buttonIndex == 0)
    {
      [[AudioStreamManager main] stopRadio];
      [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutDidReturned)];
    }
}







- (void)logoutDidReturned
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_SCREEN object:nil];
}




@end
