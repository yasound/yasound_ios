//
//  ProgrammingViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingViewController.h"
#import "ActivityAlertView.h"
#import "Radio.h"
#import "YasoundDataProvider.h"



@implementation ProgrammingViewController

@synthesize matchedSongs;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _data = [[NSMutableArray alloc] init];
        [_data retain];
        
        _nbReceivedData = 0;
        _nbPlaylists = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    

    [ActivityAlertView showWithTitle: NSLocalizedString(@"PlaylistsViewController_FetchingPlaylists", nil)];
    
    //NSLog(@"%d - %d", _nbReceivedData, _nbPlaylists);
    
    Radio* radio = [YasoundDataProvider main].radio;
    [[YasoundDataProvider main] playlistsForRadio:radio target:self action:@selector(receivePlaylists:withInfo:)];
}


- (void)receivePlaylists:(NSArray*)playlists withInfo:(NSDictionary*)info
{
    _nbPlaylists = playlists.count;
    for (Playlist* playlist in playlists) 
    {
        [[YasoundDataProvider main] matchedSongsForPlaylist:playlist target:self action:@selector(matchedSongsReceveived:info:)]; 
        // didReceiveMatchedSongs:(NSArray*)matched_songs info:
    }
}


- (void)matchedSongsReceveived:(NSArray*)songs info:(NSDictionary*)info
{
    _nbReceivedData++;
    [_data addObject:songs];
    
    if (_nbReceivedData != _nbPlaylists)
        return;
    
    // merge all song arrays
    self.matchedSongs = [[NSArray alloc] initWithArray:[_data objectAtIndex:0]];
    
    for (int i = 1; i < _nbPlaylists; i++)
        self.matchedSongs = [self.matchedSongs arrayByAddingObjectsFromArray:[_data objectAtIndex:1]];
    
    [_tableView reloadData];

    [ActivityAlertView close];
}





- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return self.matchedSongs.count;
}



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    return 44;
//}


//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 22;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 22;
//}




//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSString* title = nil;
//    
//    if (section == 0)
//        return nil;
//    
//    if (section == SECTION_MONTHCHART)
//        title = NSLocalizedString(@"StatsView_monthselector_label", nil);
//    
//    else if (section == SECTION_LEADERBOARD)
//        title = NSLocalizedString(@"StatsView_leaderboardselector_label", nil);
//    
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    
//    UIImage* image = [sheet image];
//    CGFloat height = image.size.height;
//    UIImageView* view = [[UIImageView alloc] initWithImage:image];
//    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, height);
//    
//    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = title;
//    [view addSubview:label];
//    
//    return view;
//}




//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    if ((indexPath.section == SECTION_MONTHCHART) && (indexPath.row == ROW_MONTHCHART_CHART))
//    {
//        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChartBackground.png"]];
//        cell.backgroundView = view;
//        [view release];
//        return;
//    }
//    
//    
//    NSInteger nbRows;
//    if (indexPath.section == SECTION_STATS)
//    {
//        nbRows = 1;
//    }
//    else if (indexPath.section == SECTION_LEADERBOARD) 
//    {
//        nbRows = [_leaderboard count];
//    }
//    
//    
//    LeaderBoardEntry* entry = [_leaderboard objectAtIndex:indexPath.row];
//    BOOL isUserRadio = [entry isUserRadio];
//    
//    if (nbRows == 1)
//    {
//        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowSingle.png"]];
//        cell.backgroundView = view;
//        [view release];
//    }
//    else if (indexPath.row == 0)
//    {
//        UIImageView* view = nil;
//        if (isUserRadio)
//            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowGoldFirst.png"]];
//        else
//            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowFirst.png"]];
//        cell.backgroundView = view;
//        [view release];
//    }
//    else if (indexPath.row == (nbRows -1))
//    {
//        UIImageView* view = nil;
//        if (isUserRadio)
//            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowGoldLast.png"]];
//        else
//            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowLast.png"]];
//        cell.backgroundView = view;
//        [view release];
//    }
//    else
//    {
//        UIImageView* view = nil;
//        if (isUserRadio)
//            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowGoldInter.png"]];
//        else
//            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellRowInter.png"]];
//        cell.backgroundView = view;
//        [view release];
//    }
//    
//}
//


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Song* song = [self.matchedSongs objectAtIndex:indexPath.row];
    
    cell.textLabel.text = song.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
















#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
