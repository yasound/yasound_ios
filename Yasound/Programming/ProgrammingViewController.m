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
#import "ProgrammingRadioViewController.h"
#import "ProgrammingUploadViewController.h"
#import "ProgrammingLocalViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"
#import "ProgrammingArtistViewController.h"
#import "RootViewController.h"
#import "AudioStreamManager.h"
#import "ProgrammingCell.h"
#import "DataBase.h"

@implementation ProgrammingViewController

@synthesize radio;
//@synthesize sortedArtists;
//@synthesize sortedSongs;
@synthesize container;
@synthesize tableview;
@synthesize topbar;

#define SEGMENT_INDEX_ALPHA 0
#define SEGMENT_INDEX_ARTIST 1


#define TIMEPROFILE_BUILD @"Programming build catalog"



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(Radio*)radio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.radio = radio;
        
//        self.sortedArtists = [[NSMutableDictionary alloc] init];
//        self.sortedSongs = [[NSMutableDictionary alloc] init];

        // anti-bug
        NSString* catalogId = [NSString stringWithFormat:@"%@", [SongRadioCatalog main].radio.id];
        NSString* newId = [NSString stringWithFormat:@"%@", self.radio.id];
        
        // clean catalog
        if (([SongRadioCatalog main].radio.id != nil) && ![catalogId isEqualToString:newId])
        {
            [SongRadioCatalog releaseCatalog];
            [SongLocalCatalog releaseCatalog];
            [DataBase releaseDataBase];
        }
    }
    return self;
}


- (void)dealloc
{
    [SongCatalog releaseSynchronizedCatalog];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [_tableView release];
    [super dealloc];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongRemoved:) name:NOTIF_PROGAMMING_SONG_REMOVED object:nil];
    

//    _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
//    _subtitleLabel.text = NSLocalizedString(@"ProgrammingView_subtitle", nil);
//    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
//    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    [_radioSegment setTitle:NSLocalizedString(@"Programming.segment.titles", nil) forSegmentAtIndex:0];
    [_radioSegment setTitle:NSLocalizedString(@"Programming.segment.artists", nil) forSegmentAtIndex:1];

    [_localSegment setTitle:NSLocalizedString(@"Programming.segment.playlists", nil) forSegmentAtIndex:0];
    [_localSegment setTitle:NSLocalizedString(@"Programming.segment.genres", nil) forSegmentAtIndex:1];
    [_localSegment setTitle:NSLocalizedString(@"Programming.segment.titles", nil) forSegmentAtIndex:2];

//    [_segment addTarget:self action:@selector(onSegmentClicked:) forControlEvents:UIControlEventValueChanged];
    
    
    // waiting for the synchronization to be done
//    _tableView.hidden = YES;
    

//    [ActivityAlertView showWithTitle: NSLocalizedString(@"PlaylistsViewController_FetchingPlaylists", nil)];
    
    //DLog(@"%d - %d", _nbReceivedData, _nbPlaylists);
    
    // PROFILE
//    [[TimeProfile main] begin:TIMEPROFILE_BUILD];
//    
//    [[SongCatalog synchronizedCatalog] downloadMatchedSongsForRadio:self.radio target:self action:@selector(matchedSongsDownloaded:success:)];
    
#ifdef DEBUG
    [self.topbar showEditItemWithTarget:self action:@selector(onDebugItem:)];
#endif
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


//- (void)matchedSongsDownloaded:(NSDictionary*)info success:(NSNumber*)success
//{
//    NSInteger nbMatchedSongs = [[info objectForKey:@"nbMatchedSongs"] integerValue];
//    NSString* message = [info objectForKey:@"message"];
//    
//    if (![success boolValue])
//    {
//        // display an error dialog
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProgrammingView_error_title", nil) message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//        [av release];
//        return;
//    }
//    
//    // PROFILE
//    [[TimeProfile main] end:TIMEPROFILE_BUILD];
//    [[TimeProfile main] logInterval:TIMEPROFILE_BUILD inMilliseconds:NO];
//
//    DLog(@"%d matched songs", nbMatchedSongs);
//    
//    NSString* subtitle = nil;
//    if (nbMatchedSongs == 0)
//        subtitle = NSLocalizedString(@"ProgrammingView_subtitled_count_0", nil);
//    else if (nbMatchedSongs == 1)
//        subtitle = NSLocalizedString(@"ProgrammingView_subtitled_count_1", nil);
//    else if (nbMatchedSongs > 1)
//        subtitle = NSLocalizedString(@"ProgrammingView_subtitled_count_n", nil);
//    
//    subtitle = [subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbMatchedSongs]];
//
//    _subtitleLabel.text = subtitle;
//    
//    
//    // now that the synchronization is been done,
////    _tableView.hidden = NO;
//    [_tableView reloadData];
//
//    [ActivityAlertView close];
//}
//





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











//
//
//
//#pragma mark - TableView Source and Delegate
//
//
////- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
////{
////    return [gIndexMap objectAtIndex:section];
////}
//
//
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    NSInteger nbSections = [SongCatalog synchronizedCatalog].indexMap.count;
//
//    return nbSections;
//}
//
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];
//    if (nbRows == 0)
//        return 0;
//
//    return 22;
//}
//
//
//
//
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];
//
//    if (nbRows == 0)
//        return nil;
//
//    //LBDEBUG
//    assert([SongCatalog synchronizedCatalog].indexMap.count > section);
//
//    NSString* title = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:section];
//
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.Section.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UIImageView* view = [sheet makeImage];
//
//    sheet = [[Theme theme] stylesheetForKey:@"TableView.Section.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UILabel* label = [sheet makeLabel];
//    label.text = title;
//    [view addSubview:label];
//
//    return view;
//}
//
//
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
//{
//    return [self getNbRowsForTable:tableView inSection:section];
//}
//
//
//- (NSInteger)getNbRowsForTable:(UITableView*)tableView inSection:(NSInteger)section
//{
//    //LBDEBUG
//    assert([SongCatalog synchronizedCatalog].indexMap.count > section);
//
//    NSString* charIndex = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:section];
//    
//    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
//    {
//        NSArray* letterRepo = [[SongCatalog synchronizedCatalog].alphabeticRepo objectForKey:charIndex];
//        assert(letterRepo != nil);
//        return letterRepo.count;
//    }
//    else
//    {
//        NSArray* artistsForSection = [[SongCatalog synchronizedCatalog].alphaArtistsRepo objectForKey:charIndex];
//        NSInteger count = artistsForSection.count;
//        return count;
//    }
//
//}
//
//
//
////- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
////{    
////    return 44;
////}
//
//
////- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
////{
////    return 22;
////}
//
//
//
//
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
//{
//    return [SongCatalog synchronizedCatalog].indexMap;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
//{
//    return index;
//}
//
//
//
//
//
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    cell.backgroundView = [sheet makeImage];
//}
//
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
//        return [self cellAlphaForRowAtIndexPath:indexPath];
//    else
//        return [self cellFolderForRowAtIndexPath:indexPath];
//}
//
//
//
//
//- (UITableViewCell*)cellAlphaForRowAtIndexPath:(NSIndexPath*)indexPath
//{
//    static NSString* CellIdentifier = @"CellAlpha";
//
//    //LBDEBUG
//    assert([SongCatalog synchronizedCatalog].indexMap.count > indexPath.section);
//
//    NSString* charIndex = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:indexPath.section];
//    NSArray* songs = [self.sortedSongs objectForKey:charIndex];
//    
//    if (songs == nil)
//    {
//        
//        songs = [[SongCatalog synchronizedCatalog].alphabeticRepo objectForKey:charIndex];
//        
//        // sort the items array
//        songs = [songs sortedArrayUsingSelector:@selector(nameCompare:)];
//        
//        // store the cache
//        assert(songs != nil);
//        [self.sortedSongs setObject:songs forKey:charIndex];
//
//    }
//
//    //LBDEBUG
//#ifdef _DEBUG
//    DLog(@"songs.count %d", songs.count);
//    DLog(@"indexPath.row %d", indexPath.row);
//#endif
//    assert(songs.count > indexPath.row);
//
//    Song* song = [songs objectAtIndex:indexPath.row];
//    
//    
//    ProgrammingCell* cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) 
//    {
//        cell = [[[ProgrammingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withSong:song atRow:0 deletingTarget:self deletingAction:@selector(onSongDeleteRequested:song:)] autorelease];
//    }
//    else
//        [cell updateWithSong:song atRow:0];
//    
//    return cell;
//}
//
//
//- (void)onSongDeleteRequested:(UITableViewCell*)cell song:(Song*)song
//{
//    DLog(@"onSongDeleteRequested for Song %@", song.name);   
//    
//    // request to server
//    [[YasoundDataProvider main] deleteSong:song target:self action:@selector(onSongDeleted:info:) userData:cell];
//
//}
//
//
//// server's callback
//- (void)onSongDeleted:(Song*)song info:(NSDictionary*)info
//{
//    DLog(@"onSongDeleted for Song %@", song.name);  
//    DLog(@"info %@", info);
//    
//    BOOL success = NO;
//    NSNumber* nbsuccess = [info objectForKey:@"success"];
//    if (nbsuccess != nil)
//        success = [nbsuccess boolValue];
//    
//    DLog(@"success %d", success);
//    
//    UITableViewCell* cell = [info objectForKey:@"userData"];
//    NSIndexPath* indexPath = [_tableView indexPathForCell:cell];
//
//    [[SongCatalog synchronizedCatalog] removeSynchronizedSong:song];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROGAMMING_SONG_REMOVED object:self];
//
//    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];        
//}
//
//
//
//- (UITableViewCell*)cellFolderForRowAtIndexPath:(NSIndexPath*)indexPath
//{
//    //LBDEBUG
//    assert([SongCatalog synchronizedCatalog].indexMap.count > indexPath.section);
//    
//    NSString* charIndex = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:indexPath.section];
//
//    NSMutableDictionary* artistsForSection = [[SongCatalog synchronizedCatalog].alphaArtistsRepo objectForKey:charIndex];
//
//    // get sorted list
//    NSArray* artists = [self.sortedArtists objectForKey:charIndex];
//    if (artists == nil)
//    {
//        artists = [artistsForSection allKeys];
//
//        // sort the items array
//        artists = [artists sortedArrayUsingSelector:@selector(compare:)];
//        
//        // store the cache
//        assert(artists != nil);
//        [self.sortedArtists setObject:artists forKey:charIndex];
//    }
//
//
//    
//        static NSString* CellIdentifier = @"Cell";
//        
//        UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        if (cell == nil) 
//        {
//            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
//        }
//        
//        cell.textLabel.backgroundColor = [UIColor clearColor];
//        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
//        
//        
//    //LBDEBUG
//    assert(artists.count > indexPath.row);
//
//    NSString* artist = [artists objectAtIndex:indexPath.row];
//        
//        NSDictionary* artistRepo = [artistsForSection objectForKey:artist];
//
//        NSInteger nbAlbums = artistRepo.count;
//        
//        cell.textLabel.textColor = [UIColor whiteColor];
//        cell.textLabel.text = artist;
//
//        if (nbAlbums == 1)
//            cell.detailTextLabel.text = NSLocalizedString(@"Programmin.nbSongs.1", nil);
//        else
//            cell.detailTextLabel.text = NSLocalizedString(@"Programmin.nbSongs.n", nil);
//
//         cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbAlbums]];
//
//    return cell;
//}
//
//
//
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
//    
//    
//    
//    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
//    {
//        
//        //LBDEBUG
//        assert([SongCatalog synchronizedCatalog].indexMap.count > indexPath.section);
//
//        NSString* charIndex = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:indexPath.section];
//        
//        
//        //LBDEBUG
//        {
//            NSArray* array  =[self.sortedSongs objectForKey:charIndex];
//        assert(array.count > indexPath.row);
//        }
//
//        Song* song = [[self.sortedSongs objectForKey:charIndex] objectAtIndex:indexPath.row];
//        
//        SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:song showNowPlaying:YES forRadio:self.radio];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//    else
//    {
//        //LBDEBUG
//        assert([SongCatalog synchronizedCatalog].indexMap.count > indexPath.section);
//
//        NSString* charIndex = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:indexPath.section];
//
//        
//        //LBDEBUG
//        {
//            NSArray* array  =[self.sortedArtists objectForKey:charIndex];
//            assert(array.count > indexPath.row);
//        }
//
//        
//        NSString* artistKey = [[self.sortedArtists objectForKey:charIndex] objectAtIndex:indexPath.row];
//        
//        [[SongCatalog synchronizedCatalog] selectArtist:artistKey withIndex:charIndex];
//        
//        ProgrammingArtistViewController* view = [[ProgrammingArtistViewController alloc] initWithNibName:@"ProgrammingArtistViewController" bundle:nil usingCatalog:[SongCatalog synchronizedCatalog] forRadio:self.radio];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//
//}
//
//
//
//
//
//
//
//
//







#pragma mark - IBActions


//- (IBAction)onSynchronize:(id)semder
//{
//    ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
//}


- (IBAction)onRadioSegmentClicked:(id)sender
{
    NSInteger index = _radioSegment.selectedSegmentIndex;
    
    [self.tableview setSegment:index];
}


- (IBAction)onLocalSegmentClicked:(id)sender
{
    NSInteger index = _localSegment.selectedSegmentIndex;
    
    [self.tableview setSegment:index];
}



- (void)onNotifSongAdded:(NSNotification*)notif
{
//    [self.sortedSongs release];
//    [self.sortedArtists release];
//    self.sortedArtists = [[NSMutableDictionary alloc] init];
//    self.sortedSongs = [[NSMutableDictionary alloc] init];    
    
//    [_tableView reloadData];    
}


- (void)onNotifSongRemoved:(NSNotification*)notif
{    
    UIViewController* sender = notif.object;
    
    //LBDEBUG : ICI : release objects?
    
//    if (sender != self)
//        [_tableView reloadData];    
}










#pragma mark - WheelSelectorDelegate



- (NSInteger)numberOfItemsInWheelSelector:(WheelSelector*)wheel
{
    return PROGRAMMING_WHEEL_NB_ITEMS;
}

- (NSString*)wheelSelector:(WheelSelector*)wheel titleForItem:(NSInteger)itemIndex
{
    if (itemIndex == PROGRAMMING_WHEEL_ITEM_LOCAL)
        return NSLocalizedString(@"Programming.Catalog.local", nil);
    if (itemIndex == PROGRAMMING_WHEEL_ITEM_RADIO)
        return NSLocalizedString(@"Programming.Catalog.radio", nil);
//    if (itemIndex == PROGRAMMING_WHEEL_ITEM_SERVER)
//        return NSLocalizedString(@"Programming.Catalog.server", nil);
    if (itemIndex == PROGRAMMING_WHEEL_ITEM_UPLOADS)
        return NSLocalizedString(@"Programming.Catalog.uploads", nil);
    return nil;
}

- (NSInteger)initIndexForWheelSelector:(WheelSelector*)wheel
{
    return PROGRAMMING_WHEEL_ITEM_RADIO;
}

- (void)wheelSelector:(WheelSelector*)wheel didSelectItemAtIndex:(NSInteger)itemIndex
{
    if (self.tableview != nil)
    {
        [self.tableview.tableView removeFromSuperview];
        [self.tableview release];
        self.tableview = nil;
    }

    if (itemIndex == PROGRAMMING_WHEEL_ITEM_LOCAL)
    {
        _containerLocalSegment.hidden = NO;
        _containerRadioSegment.hidden = YES;
        
        ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithStyle:UITableViewStylePlain forRadio:self.radio];
        self.tableview = view;
    }
    else if (itemIndex == PROGRAMMING_WHEEL_ITEM_RADIO)
    {
        _containerLocalSegment.hidden = YES;
        _containerRadioSegment.hidden = NO;
        
        ProgrammingRadioViewController* view = [[ProgrammingRadioViewController alloc] initWithStyle:UITableViewStylePlain forRadio:self.radio];
        self.tableview = view;
    }
    else if (itemIndex == PROGRAMMING_WHEEL_ITEM_UPLOADS)
    {
        _containerLocalSegment.hidden = YES;
        _containerRadioSegment.hidden = YES;
        
        ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithStyle:UITableViewStylePlain forRadio:self.radio];
        self.tableview = view;
    }
    
    self.tableview.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    CGRect frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height);
    self.tableview.tableView.frame = frame;
    [self.container addSubview:self.tableview.tableView];
    
    //[view release];
    
}








#pragma mark - TopBarBackAndTitleDelegate

- (BOOL)topBarBackClicked
{
    BOOL goBack = [self.tableview onBackClicked];
    return goBack;
}



#ifdef DEBUG

- (void)onDebugItem:(id)sender {

    [self.tableview.tableView reloadData];
}

#endif




@end
