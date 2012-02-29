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
#import "SongInfoViewController.h"
#import "SongUploadViewController.h"
#import "SongAddViewController.h"
#import "TimeProfile.h"



@implementation ProgrammingViewController

@synthesize matchedSongs;
@synthesize alphabeticRepo;

static NSMutableArray* gIndexMap = nil;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _data = [[NSMutableArray alloc] init];
        [_data retain];
        
        _nbReceivedData = 0;
        _nbPlaylists = 0;
        
        if (gIndexMap == nil)
            [self initIndexMap];
        
    }
    return self;
}



- (void)initIndexMap
{
    gIndexMap = [[NSMutableArray alloc] init];
    [gIndexMap retain];
    [gIndexMap addObject:@"-"];
    [gIndexMap addObject:@"A"];
    [gIndexMap addObject:@"B"];
    [gIndexMap addObject:@"C"];
    [gIndexMap addObject:@"D"];
    [gIndexMap addObject:@"E"];
    [gIndexMap addObject:@"F"];
    [gIndexMap addObject:@"G"];
    [gIndexMap addObject:@"H"];
    [gIndexMap addObject:@"I"];
    [gIndexMap addObject:@"J"];
    [gIndexMap addObject:@"K"];
    [gIndexMap addObject:@"L"];
    [gIndexMap addObject:@"M"];
    [gIndexMap addObject:@"N"];
    [gIndexMap addObject:@"O"];
    [gIndexMap addObject:@"P"];
    [gIndexMap addObject:@"Q"];
    [gIndexMap addObject:@"R"];
    [gIndexMap addObject:@"S"];
    [gIndexMap addObject:@"T"];
    [gIndexMap addObject:@"U"];
    [gIndexMap addObject:@"V"];
    [gIndexMap addObject:@"W"];
    [gIndexMap addObject:@"X"];
    [gIndexMap addObject:@"Y"];
    [gIndexMap addObject:@"Z"];
}




- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    

    [ActivityAlertView showWithTitle: NSLocalizedString(@"PlaylistsViewController_FetchingPlaylists", nil)];
    
    //NSLog(@"%d - %d", _nbReceivedData, _nbPlaylists);
    
    [[TimeProfile main] begin];
    
    Radio* radio = [YasoundDataProvider main].radio;
    [[YasoundDataProvider main] playlistsForRadio:radio target:self action:@selector(receivePlaylists:withInfo:)];
}


- (void)viewWillAppear:(BOOL)animated
{
    // redraw the last selected song's cell, if it's been updated
    NSIndexPath* indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath != nil)
    {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    

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
    
    if ((songs != nil) && (songs.count != 0))
        [_data addObject:songs];
    
    if (_nbReceivedData != _nbPlaylists)
        return;
    
    // merge all song arrays
    self.matchedSongs = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < _data.count; i++)
    {
        NSArray* songs = [_data objectAtIndex:i];
        
        for (Song* song in songs)
        {
            [self.matchedSongs addObject:song];
        }
    }
    
    [[TimeProfile main] end];
    
    
    
    [[TimeProfile main] begin];

    // sort matched song
    self.matchedSongs = [self.matchedSongs sortedArrayUsingSelector:@selector(nameCompare:)];

    [[TimeProfile main] end];

    
    
//    // group the songs by letter
//    self.alphabeticRepo = [[NSMutableArray alloc] init];
//
//    Song* song = [self.matchedSongs objectAtIndex:0];
//    NSString* comparator =  [song getFirstSignificantWord:song.name];
//    NSInteger repoIndex = 0;
//    
//    for (Song* song in self.matchedSongs)
//    {
//        NSString* currentComparator = [song getFirstSignificantWord:song.name];
//        
//        BOOL isDigit = NO;
//        char firstChar = [currentComparator characterAtIndex:0];
//        if (firstChar >= '0' && firstChar <= '9')
//            isDigit = YES;
//                
//        if (!isDigit && [currentComparator compare:comparator options:NSCaseInsensitiveSearch] != NSOrderedSame)
//        {
//            comparator = currentComparator;
//            repoIndex++;
//        }
//        
//        NSMutableArray* currentRepo = nil;
//        if (self.alphabeticRepo.count > repoIndex)
//            currentRepo = [self.alphabeticRepo objectAtIndex:repoIndex];
//        if (currentRepo == nil)
//        {
//            currentRepo = [[NSMutableArray alloc] init];
//            [self.alphabeticRepo addObject:currentRepo];
//        }
//        
//        [currentRepo addObject:song];
//    }
    
    

    
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
//    return gIndexMap.count;
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








//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
//{
//    return gIndexMap;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
//{
//    return index;
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




- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainRow.png"]];
    cell.backgroundView = view;
    [view release];
}



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
    cell.textLabel.backgroundColor = [UIColor clearColor];
    if ([song isSongEnabled])
    {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    }
    else 
    {
        cell.textLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    }
    
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song* song = [self.matchedSongs objectAtIndex:indexPath.row];
    
    SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:song];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}
















#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSynchronize:(id)semder
{
    SongUploadViewController* view = [[SongUploadViewController alloc] initWithNibName:@"SongUploadViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


- (IBAction)onAdd:(id)sender
{
    SongAddViewController* view = [[SongAddViewController alloc] initWithNibName:@"SongAddViewController" bundle:nil withMatchedSongs:self.matchedSongs];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


@end
