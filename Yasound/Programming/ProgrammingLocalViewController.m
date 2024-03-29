//
//  ProgrammingLocalViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingLocalViewController.h"
#import "Song.h"
#import "SongLocal.h"
#import "SongUploader.h"
#import "SongUploadManager.h"
#import "TimeProfile.h"
#import "ActivityAlertView.h"
#import "ProgrammingUploadViewController.h"
#import "SongCatalog.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "ProgrammingArtistViewController.h"
#import "YasoundDataProvider.h"
#import "RootViewController.h"
#import "LocalSongInfoViewController.h"
#import "SongAddCell.h"
#import "ProgrammingRadioViewController.h"
#import "ProgrammingUploadViewController.h"
#import "YasoundAppDelegate.h"



#define TIMEPROFILE_AVAILABLECATALOG_BUILD @"TimeProfileAvailableCatalogBuild"

#define BORDER 8

@implementation ProgrammingLocalViewController

@synthesize radio;
@synthesize selectedSegmentIndex;
//@synthesize wheelSelector;
//@synthesize searchedSongs;
//@synthesize subtitle;
@synthesize sortedArtists;
@synthesize sortedSongs;
@synthesize artistVC;


#define SEGMENT_INDEX_ALPHA 0
#define SEGMENT_INDEX_ARTIST 1
#define SEGMENT_INDEX_SERVER 2


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (self.artistVC)
    {
        [self.artistVC onBackClicked];
        [self.artistVC.tableView removeFromSuperview];
        [self.artistVC release];
        self.artistVC = nil;
    }
    
    [super dealloc];
    
}



- (id)initWithStyle:(UITableViewStyle)style forRadio:(Radio*)radio
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.selectedSegmentIndex = SEGMENT_INDEX_ALPHA;
        
        self.radio = radio;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
        
        self.sortedArtists = [[NSMutableDictionary alloc] init];
        self.sortedSongs = [[NSMutableDictionary alloc] init];
        
        [self load];
    }
    return self;
}






- (void)load
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationUploadCanceled:) name:NOTIF_SONG_GUI_NEED_REFRESH object:nil];


//    _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);
//    _subtitleLabel.text = NSLocalizedString(@"SongAddView_subtitle", nil);
//    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
//    
//    [_segment setTitle:NSLocalizedString(@"SongAddView_segment_titles", nil) forSegmentAtIndex:0];  
//    [_segment setTitle:NSLocalizedString(@"SongAddView_segment_artists", nil) forSegmentAtIndex:1];  
//    [_segment insertSegmentWithTitle:NSLocalizedString(@"SongAddView_segment_server", nil) atIndex:2 animated:NO];
//    [_segment addTarget:self action:@selector(onSegmentClicked:) forControlEvents:UIControlEventValueChanged];

    
//    _searchBar.placeholder = NSLocalizedString(@"SongAddView_searchServer", nil);
//    
//    _searchView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
//    _searchView.frame = CGRectMake(0, 44, _searchView.frame.size.width, _searchView.frame.size.height);
//    
//    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _searchController.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
//    _searchController.searchResultsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
//    _searchController.searchResultsTableView.rowHeight = _tableView.rowHeight;
    
    BOOL isCached = [SongCatalog availableCatalog].cached;

    
    if (!isCached)
    {
        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_alert", nil)];
        [[TimeProfile main] begin:TIMEPROFILE_AVAILABLECATALOG_BUILD];

        [[SongCatalog availableCatalog] buildAvailableComparingToSource:[SongCatalog synchronizedCatalog].matchedSongs];
    
        [ActivityAlertView close];
        // PROFILE
        [[TimeProfile main] end:TIMEPROFILE_AVAILABLECATALOG_BUILD];
        // PROFILE
        [[TimeProfile main] logInterval:TIMEPROFILE_AVAILABLECATALOG_BUILD inMilliseconds:NO];
    }

    NSInteger count = [SongCatalog availableCatalog].nbSongs;
    
        
    
    DLog(@"ProgrammingLocalViewController : %d songs added to the local array", count);
    
    
//    //LBDEBUG TIMEPROFILE ALERTVIEW
//    {
//        CGFloat interval = [[TimeProfile main] interval:TIMEPROFILE_AVAILABLECATALOG_BUILD inMilliseconds:NO];
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"local" message:[NSString stringWithFormat:@"%.2fs for %d songs", interval, count] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//        [av release];
//        return;
//        
//    }
//    /////////
    
    
//    if (count == 0)
//        self.subtitle = NSLocalizedString(@"SongAddView_subtitled_count_0", nil);
//    else if (count == 1)
//        self.subtitle = NSLocalizedString(@"SongAddView_subtitled_count_1", nil);
//    else if (count > 1)
//        self.subtitle = NSLocalizedString(@"SongAddView_subtitled_count_n", nil);
//    
//    self.subtitle = [self.subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", count]];
//    
//    _subtitleLabel.text = self.subtitle;
    

    
    
    
    
//    if (count == 0)
//    {
//        [_tableView removeFromSuperview];
//        NSString* str = NSLocalizedString(@"PlaylistsView_empty_message", nil);
//        _itunesConnectLabel.text = str;
//        
//        _itunesConnectView.frame = CGRectMake(_itunesConnectView.frame.origin.x, 44, _itunesConnectView.frame.size.width, _itunesConnectView.frame.size.height);
//        
//        [self.view addSubview:_itunesConnectView];
//        
//        // IB, sometimes, is, huh.....
//        [_itunesConnectView addSubview:_itunesConnectLabel];
//        
//        [self.view bringSubviewToFront:_navBar];
//        [self.view bringSubviewToFront:_titleLabel];
//        [self.view bringSubviewToFront:_subtitleLabel];
//        [self.view bringSubviewToFront:_toolbar];
//
//        return;
//        
//    }
    
    if ([SongCatalog availableCatalog].nbSongs == 0)
    {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.empty" retainStylesheet:YES overwriteStylesheet:YES error:nil];
        UIImageView* view = [sheet makeImage];
        [self.tableView addSubview:view];
        [view release];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.Catalog.local", nil) message:NSLocalizedString(@"Programming.empty", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
        
    }
    
    [self.tableView reloadData];

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
//    if (_selectedIndex == SEGMENT_INDEX_SERVER)
//        return 1;
    
    return [SongCatalog availableCatalog].indexMap.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (_selectedIndex == SEGMENT_INDEX_SERVER)
//        return 0;
    
    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];
    if (nbRows == 0)
        return 0;
    
    return 22;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];
    
    if (nbRows == 0)
        return nil;
    
    NSString* title = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:section];
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.Section.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    
    sheet = [[Theme theme] stylesheetForKey:@"TableView.Section.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (_selectedIndex == SEGMENT_INDEX_SERVER)
//    {
//        if (self.searchedSongs == nil)
//            return 0;
//        
//        return self.searchedSongs.count;
//    }
    
    
    return [self getNbRowsForTable:tableView inSection:section];
}


- (NSInteger)getNbRowsForTable:(UITableView*)tableView inSection:(NSInteger)section
{
    NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:section];
    
    if (self.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:charIndex];
        assert(letterRepo != nil);
        return letterRepo.count;
    }
    else
    {
        NSArray* artistsForSection = [[SongCatalog availableCatalog].alphaArtistsRepo objectForKey:charIndex];
        NSInteger count = artistsForSection.count;
        return count;
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 46;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 22;
//}





- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{    
    if (self.selectedSegmentIndex == SEGMENT_INDEX_ARTIST)
        return nil;
    
    if ([SongCatalog availableCatalog].nbSongs == 0)
        return nil;
    
//    if (_selectedIndex == SEGMENT_INDEX_SERVER)
//        return nil;
    

    return [SongCatalog availableCatalog].indexMap;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    if (self.selectedSegmentIndex == SEGMENT_INDEX_ARTIST)
        return 0;
//    if (_selectedIndex == SEGMENT_INDEX_SERVER)
//    {
//        return 0;
//    }
    
    
    return index;
}






- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    cell.backgroundView = [sheet makeImage];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{

    
//    if (_selectedIndex == SEGMENT_INDEX_SERVER)
//    {
//        static NSString* CellIdentifier = @"CellServer";
//        
//        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        if (cell == nil) 
//        {
//            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
//        }
//
//        cell.textLabel.backgroundColor = [UIColor clearColor];
//        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
//        
//        YasoundSong* song = [self.searchedSongs objectAtIndex:indexPath.row];
//     
//        cell.textLabel.textColor = [UIColor whiteColor];
//        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
//        
//        cell.textLabel.text = song.name;
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.album_name, song.artist_name];     
//        
//        return cell;
//    }
// else
    if (self.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        static NSString* CellAddIdentifier = @"CellAdd";

        NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
        NSArray* songs = [self.sortedSongs objectForKey:charIndex];
        
        if (songs == nil)
        {
            
            songs = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:charIndex];
            
            // sort the items array
            songs = [songs sortedArrayUsingSelector:@selector(nameCompare:)];
            
            // store the cache
            [self.sortedSongs setObject:songs forKey:charIndex];
            
        }
        
        Song* song = [songs objectAtIndex:indexPath.row];

        
        
        SongAddCell* cell = [tableView dequeueReusableCellWithIdentifier:CellAddIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[SongAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddIdentifier song:song forRadio:self.radio] autorelease];
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
        NSMutableDictionary* artistsForSection = [[SongCatalog availableCatalog].alphaArtistsRepo objectForKey:charIndex];
        
        // get sorted list
        NSArray* artists = [self.sortedArtists objectForKey:charIndex];
        if (artists == nil)
        {
            artists = [artistsForSection allKeys];
            
            // sort the items array
            artists = [artists sortedArrayUsingSelector:@selector(compare:)];
            
            // store the cache
            [self.sortedArtists setObject:artists forKey:charIndex];
        }

        NSString* artist = [artists objectAtIndex:indexPath.row];
        
        NSDictionary* artistRepo = [artistsForSection objectForKey:artist];
        
        NSInteger nbAlbums = artistRepo
        
        .count;
        
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
    
//    if (self.selectedSegmentIndex == SEGMENT_INDEX_SERVER)
//    {
//        YasoundSong* song = [self.searchedSongs objectAtIndex:indexPath.row];
//        
//        [ActivityAlertView showWithTitle:nil];
//
//        [[YasoundDataProvider main] addSong:song target:self action:@selector(songAdded:info:)];
//
//
//        return;
//    }
    
    if (self.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
        SongLocal* songLocal = [[self.sortedSongs objectForKey:charIndex] objectAtIndex:indexPath.row];

        LocalSongInfoViewController* view = [[LocalSongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:songLocal];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
        NSString* artistKey = [[self.sortedArtists objectForKey:charIndex] objectAtIndex:indexPath.row];
        
        [[SongCatalog availableCatalog] selectArtist:artistKey withIndex:charIndex];

        
        self.artistVC = [[ProgrammingArtistViewController alloc] initWithStyle:UITableViewStylePlain usingCatalog:[SongCatalog availableCatalog] forRadio:self.radio];
        CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.artistVC.tableView.frame = frame;
        [self.view.superview addSubview:self.artistVC.tableView];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        frame = CGRectMake(0,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.artistVC.tableView.frame = frame;
        
        [UIView commitAnimations];
    }
    
}



- (void)setSegment:(NSInteger)index
{
    self.selectedSegmentIndex = index;
    
    if (self.artistVC)
    {
        [self.artistVC onBackClicked];
        [self.artistVC.tableView removeFromSuperview];
        [self.artistVC release];
        self.artistVC = nil;
    }
    
    [self.tableView reloadData];
}




- (BOOL)onBackClicked
{
    BOOL goBack = YES;
    if (self.artistVC)
    {
        goBack = [self.artistVC onBackClicked];
        
        if (goBack)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.33];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
            
            CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
            self.artistVC.tableView.frame = frame;
            
            [UIView commitAnimations];
            
            return NO;
        }
    }
    
    return goBack;
}




- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.artistVC.tableView removeFromSuperview];
    [self.artistVC release];
    self.artistVC = nil;
}






//- (void)songAdded:(Song*)song info:(NSDictionary*)info
//{
//    [ActivityAlertView close];
//
//    if (song == nil)
//    {
//        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_addedError", nil) closeAfterTimeInterval:2];
//        return;
//    }
//    
//    NSDictionary* status = [info objectForKey:@"status"];
//    NSNumber* successNb = [status objectForKey:@"success"];
//    NSNumber* createdNb = [status objectForKey:@"created"];
//    BOOL success = YES;
//    BOOL created = YES;
//
//    if ((successNb != nil) && (createdNb != nil))
//    {
//        success = [successNb boolValue];
//        created = [createdNb boolValue];
//    }
//    
//    if (success && !created)
//        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_addedAlready", nil) closeAfterTimeInterval:2];
//    else
//    {
//        [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_addedOk", nil) closeAfterTimeInterval:2];
//
//        // add the song to the catalog of synchronized catalog (we dont want to re-generate it entirely)
//        [[SongCatalog synchronizedCatalog] insertAndEnableSong:song];
//        
//        // and let the views know about it
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROGAMMING_SONG_ADDED object:nil];
//
//        
//        //  flag the current song as "uploading song"    
//        NSIndexPath* indexPath = [_searchController.searchResultsTableView indexPathForSelectedRow];
//        
//        // have a flag "synchronized" instead of using "uploading"
//        song.uploading = YES;
//        UITableViewCell* cell = [_searchController.searchResultsTableView cellForRowAtIndexPath:indexPath];
//        [cell setNeedsLayout];
//    }
//}
//




//#pragma mark - IBActions
//
//- (IBAction)onBack:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//
//- (IBAction)onSynchronize:(id)semder
//{
//    ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
//}
//
//- (IBAction)onSegmentClicked:(id)sender
//{
//    NSInteger index = [_segment selectedSegmentIndex];
//    if ((index == SEGMENT_INDEX_ALPHA) || (index == SEGMENT_INDEX_ARTIST))
//    {
//        _subtitleLabel.text = self.subtitle;
//
//        if (_selectedIndex == SEGMENT_INDEX_SERVER)
//        {
//            [_searchView removeFromSuperview];
//            if ([SongCatalog availableCatalog].nbSongs == 0)
//            {
//                _itunesConnectView.frame = CGRectMake(_itunesConnectView.frame.origin.x, 44, _itunesConnectView.frame.size.width, _itunesConnectView.frame.size.height);
//
//                [self.view addSubview:_itunesConnectView];
//                
//                [self.view bringSubviewToFront:_navBar];
//                [self.view bringSubviewToFront:_titleLabel];
//                [self.view bringSubviewToFront:_subtitleLabel];
//                [self.view bringSubviewToFront:_toolbar];
//            }
//            else
//                [self.view addSubview:_tableView];
//
//        }
//        
//        _selectedIndex = index;
//
//        if ([SongCatalog availableCatalog].nbSongs != 0)
//            [_tableView reloadData];
//    }
//    
//    else if (index == SEGMENT_INDEX_SERVER)
//    {
//        _subtitleLabel.text = NSLocalizedString(@"SongAddView_addFromServer", nil);
//
//        if ([SongCatalog availableCatalog].nbSongs == 0)
//            [_itunesConnectView removeFromSuperview];
//        else
//            [_tableView removeFromSuperview];
//        
//        
//        [self.view addSubview:_searchView];
//        
//        _selectedIndex = index;
//        
//        [_searchController.searchResultsTableView reloadData];
//
//    }
//    
//}
//







//#pragma mark - Search Delegate
//
////- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
////{
////
////}
////
////- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
////{
////
////}
//
//- (void)requestsSongSearch:(NSString*)searchText
//{
//    [ActivityAlertView showWithTitle:NSLocalizedString(@"SongAddView_requestServer", nil)];
//    
//  [[YasoundDataProvider main] searchSong:searchText count:20 offset:0 target:self action:@selector(didReceiveSongs:info:)]; 
//    
//}
//
//     
//- (void)didReceiveSongs:(NSArray*)songs info:(NSDictionary*)info
//{
//    self.searchedSongs = songs;
//    [_searchController.searchResultsTableView reloadData];
//    
//    [ActivityAlertView close];
//}
//

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
//    DLog(@"searchBarSearchButtonClicked %@", searchBar.text);
//    
//    [self requestsSongSearch:searchBar.text];
//}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    DLog(@"searchBarSearchButtonClicked %@", searchBar.text);
//    
//    [self requestsSongSearch:searchBar.text];
//}




- (void)onNotificationUploadCanceled:(NSNotification*)notif
{
    [self.tableView reloadData];
}





//
//
//#pragma mark - WheelSelectorDelegate
//
//
//#define WHEEL_NB_ITEMS 3
//#define WHEEL_ITEM_LOCAL 0
//#define WHEEL_ITEM_RADIO 1
//#define WHEEL_ITEM_UPLOADS 2
////#define WHEEL_ITEM_SERVER 3
//
//- (NSInteger)numberOfItemsInWheelSelector:(WheelSelector*)wheel
//{
//    return WHEEL_NB_ITEMS;
//}
//
//- (NSString*)wheelSelector:(WheelSelector*)wheel titleForItem:(NSInteger)itemIndex
//{
//    if (itemIndex == WHEEL_ITEM_LOCAL)
//        return NSLocalizedString(@"Programming.Catalog.local", nil);
//    if (itemIndex == WHEEL_ITEM_RADIO)
//        return NSLocalizedString(@"Programming.Catalog.radio", nil);
//    //    if (itemIndex == WHEEL_ITEM_SERVER)
//    //        return NSLocalizedString(@"Programming.Catalog.server", nil);
//    if (itemIndex == WHEEL_ITEM_UPLOADS)
//        return NSLocalizedString(@"Programming.Catalog.uploads", nil);
//    return nil;
//}
//
//- (NSInteger)initIndexForWheelSelector:(WheelSelector*)wheel
//{
//    return WHEEL_ITEM_RADIO;
//}
//
//- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex
//{
//    if (itemIndex == WHEEL_ITEM_LOCAL)
//    {
////        ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithNibName:@"ProgrammingLocalViewController" bundle:nil  forRadio:self.radio];
////        [self.navigationController pushViewController:view animated:NO];
////        [view release];
//    }
//    else if (itemIndex == WHEEL_ITEM_RADIO)
//    {
//        ProgrammingRadioViewController* view = [[ProgrammingRadioViewController alloc] initWithNibName:@"ProgrammingRadioViewController" bundle:nil forRadio:self.radio];
//        [self.navigationController pushViewController:view animated:NO];
//        [view release];
//    }
//    else if (itemIndex == WHEEL_ITEM_UPLOADS)
//    {
//        ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
//        [self.navigationController pushViewController:view animated:NO];
//        [view release];
//    }
//}
//

@end

































