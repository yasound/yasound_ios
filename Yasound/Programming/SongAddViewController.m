//
//  SongAddViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongAddViewController.h"
#import "Song.h"
#import "SongLocal.h"
#import "SongUploader.h"
#import "SongUploadManager.h"
#import "TimeProfile.h"
#import "ActivityAlertView.h"
#import "SongUploadViewController.h"
#import "SongCatalog.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "ProgrammingArtistViewController.h"
#import "YasoundDataProvider.h"
#import "RootViewController.h"
#import "LocalSongInfoViewController.h"
#import "SongAddCell.h"


#define TIMEPROFILE_AVAILABLECATALOG_BUILD @"TimeProfileAvailableCatalogBuild"

#define BORDER 8

@implementation SongAddViewController


@synthesize searchedSongs;
@synthesize subtitle;



#define SEGMENT_INDEX_ALPHA 0
#define SEGMENT_INDEX_ARTIST 1
#define SEGMENT_INDEX_SERVER 2




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMatchedSongs:(NSDictionary*)matchedSongs
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _selectedIndex = -1;
    }
    return self;
}


- (void)dealloc
{
    [SongCatalog releaseAvailableCatalog];
    [super dealloc];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationUploadCanceled:) name:NOTIF_UPLOAD_DIDCANCEL_NEEDGUIREFRESH object:nil];


    _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);
    _subtitleLabel.text = NSLocalizedString(@"SongAddView_subtitle", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    [_segment setTitle:NSLocalizedString(@"SongAddView_segment_titles", nil) forSegmentAtIndex:0];  
    [_segment setTitle:NSLocalizedString(@"SongAddView_segment_artists", nil) forSegmentAtIndex:1];  
    [_segment insertSegmentWithTitle:NSLocalizedString(@"SongAddView_segment_server", nil) atIndex:2 animated:NO];
    [_segment addTarget:self action:@selector(onSegmentClicked:) forControlEvents:UIControlEventValueChanged];

    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    
    _searchBar.placeholder = NSLocalizedString(@"SongAddView_searchServer", nil);
    
    _searchView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    _searchView.frame = CGRectMake(0, 44, _searchView.frame.size.width, _searchView.frame.size.height);
    
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchController.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    _searchController.searchResultsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _searchController.searchResultsTableView.rowHeight = _tableView.rowHeight;
    
    
    [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_alert", nil)];        
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(afterBreath:) userInfo:nil repeats:NO];
}

- (void)afterBreath:(NSTimer*)timer
{
    // PROFILE
    [[TimeProfile main] begin:TIMEPROFILE_AVAILABLECATALOG_BUILD];
    
    [[SongCatalog availableCatalog] buildAvailableComparingToSource:[SongCatalog synchronizedCatalog].matchedSongs];
    
    
    // PROFILE
    [[TimeProfile main] end:TIMEPROFILE_AVAILABLECATALOG_BUILD];
    // PROFILE
    [[TimeProfile main] logInterval:TIMEPROFILE_AVAILABLECATALOG_BUILD inMilliseconds:NO];

    NSInteger count = [SongCatalog availableCatalog].nbSongs;
    
        
    
    NSLog(@"SongAddViewController : %d songs added to the local array", count);
    
    if (count == 0)
        self.subtitle = NSLocalizedString(@"SongAddView_subtitled_count_0", nil);
    else if (count == 1)
        self.subtitle = NSLocalizedString(@"SongAddView_subtitled_count_1", nil);
    else if (count > 1)
        self.subtitle = NSLocalizedString(@"SongAddView_subtitled_count_n", nil);
    
    self.subtitle = [self.subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", count]];
    
    _subtitleLabel.text = self.subtitle;
    

    
    [ActivityAlertView close];
    
    
    
    if (count == 0)
    {
        [_tableView removeFromSuperview];
        NSString* str = NSLocalizedString(@"PlaylistsView_empty_message", nil);
        _itunesConnectLabel.text = str;
        
        _itunesConnectView.frame = CGRectMake(_itunesConnectView.frame.origin.x, 44, _itunesConnectView.frame.size.width, _itunesConnectView.frame.size.height);
        
        [self.view addSubview:_itunesConnectView];
        
        // IB, sometimes, is, huh.....
        [_itunesConnectView addSubview:_itunesConnectLabel];
        
        [self.view bringSubviewToFront:_navBar];
        [self.view bringSubviewToFront:_titleLabel];
        [self.view bringSubviewToFront:_subtitleLabel];
        [self.view bringSubviewToFront:_toolbar];

        return;
        
    }
    
    [_tableView reloadData];

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
    if (_selectedIndex == SEGMENT_INDEX_SERVER)
        return 1;
    
    return [SongCatalog availableCatalog].indexMap.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_selectedIndex == SEGMENT_INDEX_SERVER)
        return 0;
    
    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];
    if (nbRows == 0)
        return 0;
    
    return 22;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_selectedIndex == SEGMENT_INDEX_SERVER)
        return nil;
    

    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];
    
    if (nbRows == 0)
        return nil;
    
    NSString* title = [[SongCatalog availableCatalog].indexMap objectAtIndex:section];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 44);
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (_selectedIndex == SEGMENT_INDEX_SERVER)
    {
        if (self.searchedSongs == nil)
            return 0;
        
        return self.searchedSongs.count;
    }
    
    
    return [self getNbRowsForTable:tableView inSection:section];
}


- (NSInteger)getNbRowsForTable:(UITableView*)tableView inSection:(NSInteger)section
{
    NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:section];
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:charIndex];
        assert(letterRepo != nil);
        return letterRepo.count;
    }
    else
    {
        NSArray* artistsForSection = [[SongCatalog availableCatalog].alphaArtistsOrder objectForKey:charIndex];
        NSInteger count = artistsForSection.count;
        return count;
    }
    
}



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    return 44;
//}


//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 22;
//}





- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{    
    if (_selectedIndex == SEGMENT_INDEX_SERVER)
        return nil;
    

    return [SongCatalog availableCatalog].indexMap;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    if (_selectedIndex == SEGMENT_INDEX_SERVER)
    {
        return 0;
    }
    
    
    return index;
}






- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellPlainRow.png"]];
    cell.backgroundView = view;
    [view release];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{

    
    if (_selectedIndex == SEGMENT_INDEX_SERVER)
    {
        static NSString* CellIdentifier = @"CellServer";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }

        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        YasoundSong* song = [self.searchedSongs objectAtIndex:indexPath.row];
     
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
        
        cell.textLabel.text = song.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.album_name, song.artist_name];     
        
        return cell;
    }
    
    else if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        static NSString* CellAddIdentifier = @"CellAdd";

        NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
        NSArray* letterRepo = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:charIndex];
        Song* song = [letterRepo objectAtIndex:indexPath.row];
        
        
        SongAddCell* cell = [tableView dequeueReusableCellWithIdentifier:CellAddIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[SongAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddIdentifier song:song] autorelease];
        }
        else
            [cell update:song];        

        return cell;
    }
    else
    {
        static NSString* CellIdentifier = @"CellArtist";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

        
        NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
        NSArray* artistsForSection = [[SongCatalog availableCatalog].alphaArtistsOrder objectForKey:charIndex];
        
        NSString* artist = [artistsForSection objectAtIndex:indexPath.row];
        
        NSDictionary* artistsRepo = [[SongCatalog availableCatalog].alphaArtistsRepo objectForKey:charIndex];
        NSDictionary* artistRepo = [artistsRepo objectForKey:artist];
        
        NSInteger nbAlbums = artistRepo.count;
        
        cell.textLabel.text = artist;
        
        if (nbAlbums == 1)
            cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_albums_1", nil);
        else
            cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_albums_n", nil);
        
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbAlbums]];
        
        return cell;
    }
    
    
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_SERVER)
    {
        YasoundSong* song = [self.searchedSongs objectAtIndex:indexPath.row];
        
        [ActivityAlertView showWithTitle:nil];

        [[YasoundDataProvider main] addSong:song target:self action:@selector(songAdded:info:)];


        return;
    }
    

    
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:[[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section]];
        SongLocal* songLocal = (SongLocal*)[letterRepo objectAtIndex:indexPath.row];

        LocalSongInfoViewController* view = [[LocalSongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:songLocal];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        [[SongCatalog availableCatalog] selectArtistInSection:indexPath.section atRow:indexPath.row];
        
        ProgrammingArtistViewController* view = [[ProgrammingArtistViewController alloc] initWithNibName:@"ProgrammingArtistViewController" bundle:nil usingCatalog:[SongCatalog availableCatalog]];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    
}




- (void)songAdded:(Song*)song info:(NSDictionary*)info
{
    [ActivityAlertView close];

    if (song == nil)
    {
        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_addedError", nil) closeAfterTimeInterval:2];
        return;
    }
    
    NSDictionary* status = [info objectForKey:@"status"];
    NSNumber* successNb = [status objectForKey:@"success"];
    NSNumber* createdNb = [status objectForKey:@"created"];
    BOOL success = YES;
    BOOL created = YES;

    if ((successNb != nil) && (createdNb != nil))
    {
        success = [successNb boolValue];
        created = [createdNb boolValue];
    }
    
    if (success && !created)
        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_addedAlready", nil) closeAfterTimeInterval:2];
    else
    {
        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_addedOk", nil) closeAfterTimeInterval:2];

        // add the song to the catalog of synchronized catalog (we dont want to re-generate it entirely)
        [[SongCatalog synchronizedCatalog] insertAndSortAndEnableSong:song];
        
        // and let the views know about it
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROGAMMING_SONG_ADDED object:nil];

        
        //  flag the current song as "uploading song"    
        NSIndexPath* indexPath = [_searchController.searchResultsTableView indexPathForSelectedRow];
        
        // have a flag "synchronized" instead of using "uploading"
        song.uploading = YES;
        UITableViewCell* cell = [_searchController.searchResultsTableView cellForRowAtIndexPath:indexPath];
        [cell setNeedsLayout];
    }
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

- (IBAction)onSegmentClicked:(id)sender
{
    NSInteger index = [_segment selectedSegmentIndex];
    if ((index == SEGMENT_INDEX_ALPHA) || (index == SEGMENT_INDEX_ARTIST))
    {
        _subtitleLabel.text = self.subtitle;

        if (_selectedIndex == SEGMENT_INDEX_SERVER)
        {
            [_searchView removeFromSuperview];
            if ([SongCatalog availableCatalog].nbSongs == 0)
            {
                _itunesConnectView.frame = CGRectMake(_itunesConnectView.frame.origin.x, 44, _itunesConnectView.frame.size.width, _itunesConnectView.frame.size.height);

                [self.view addSubview:_itunesConnectView];
                
                [self.view bringSubviewToFront:_navBar];
                [self.view bringSubviewToFront:_titleLabel];
                [self.view bringSubviewToFront:_subtitleLabel];
                [self.view bringSubviewToFront:_toolbar];
            }
            else
                [self.view addSubview:_tableView];

        }
        
        _selectedIndex = index;

        if ([SongCatalog availableCatalog].nbSongs != 0)
            [_tableView reloadData];
    }
    
    else if (index == SEGMENT_INDEX_SERVER)
    {
        _subtitleLabel.text = NSLocalizedString(@"SongAddView_addFromServer", nil);

        if ([SongCatalog availableCatalog].nbSongs == 0)
            [_itunesConnectView removeFromSuperview];
        else
            [_tableView removeFromSuperview];
        
        
        [self.view addSubview:_searchView];
        
        _selectedIndex = index;
        
        [_searchController.searchResultsTableView reloadData];

    }
    
}








#pragma mark - Search Delegate

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
//{
//
//}
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//
//}

- (void)requestsSongSearch:(NSString*)searchText
{
    [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_requestServer", nil)];
    
  [[YasoundDataProvider main] searchSong:searchText count:20 offset:0 target:self action:@selector(didReceiveSongs:info:)]; 
    
}

     
- (void)didReceiveSongs:(NSArray*)songs info:(NSDictionary*)info
{
    self.searchedSongs = songs;
    [_searchController.searchResultsTableView reloadData];
    
    [ActivityAlertView close];
}


//{
//    if (_radios != nil)
//        [_radios release];
//    _radios = nil;
//    if (_radiosByCreator != nil)
//        [_radiosByCreator release];
//    _radiosByCreator = nil;
//    if (_radiosBySong != nil)
//        [_radiosBySong release];
//    _radiosBySong = nil;
//    
//    [self.searchDisplayController.searchResultsTableView reloadData];
//    
//    [[YasoundDataProvider main] searchRadios:searchText withTarget:self action:@selector(receiveRadios:withInfo:)];
//    [[YasoundDataProvider main] searchRadiosByCreator:searchText withTarget:self action:@selector(receiveRadiosSearchedByCreator:withInfo:)];
//    [[YasoundDataProvider main] searchRadiosBySong:searchText withTarget:self action:@selector(receiveRadiosSearchBySong:withInfo:)];
//}

//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    NSLog(@"searchBarSearchButtonClicked %@", searchBar.text);
//    
//    [self requestsSongSearch:searchBar.text];
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked %@", searchBar.text);
    
    [self requestsSongSearch:searchBar.text];
}




- (void)onNotificationUploadCanceled:(NSNotification*)notif
{
    [_tableView reloadData];
}


@end

































