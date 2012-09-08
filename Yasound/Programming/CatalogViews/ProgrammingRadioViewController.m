//
//  ProgrammingRadioViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingRadioViewController.h"
#import "ActivityAlertView.h"
#import "Radio.h"
#import "YasoundDataProvider.h"
#import "SongInfoViewController.h"
#import "ProgrammingUploadViewController.h"
#import "ProgrammingLocalViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
//#import "SongCatalog.h"
#import "RootViewController.h"
#import "AudioStreamManager.h"
#import "ProgrammingCell.h"
#import "YasoundAppDelegate.h"
#import "ObjectButton.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"
#import "DataBase.h"

@implementation ProgrammingRadioViewController

@synthesize radio;
//@synthesize sortedArtists;
//@synthesize sortedSongs;
//@synthesize selectedSegmentIndex;
@synthesize artistVC;
//@synthesize artistToIndexPath;
//@synthesize deleteArtistNameFromClient;
//@synthesize deleteRunning;


#define TIMEPROFILE_BUILD @"Programming build catalog"




- (void)dealloc
{
//    [SongCatalog releaseSynchronizedCatalog];
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
        self.radio = radio;
        self.selectedSegmentIndex = RADIOSEGMENT_INDEX_TITLES;
//        self.deleteRunning = NO;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];

        
//        self.sortedArtists = [[NSMutableDictionary alloc] init];
//        self.sortedSongs = [[NSMutableDictionary alloc] init];
//        self.artistToIndexPath = [[NSMutableDictionary alloc] init];

        // anti-bug
        NSString* catalogId = [NSString stringWithFormat:@"%@", [SongRadioCatalog main].radio.id];
        NSString* newId = [NSString stringWithFormat:@"%@", self.radio.id];
        
        // clean catalog
        if (([SongRadioCatalog main].radio.id != nil) && ![catalogId isEqualToString:newId])
        {
            [SongRadioCatalog releaseCatalog];
            [SongLocalCatalog releaseCatalog];
            [DataBase releaseDatabase];
        }
        
        [self load];
    }
    return self;
}






- (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongRemoved:) name:NOTIF_PROGAMMING_SONG_REMOVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongUpdated:) name:NOTIF_PROGAMMING_SONG_UPDATED object:nil];
    

//    _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
//    _subtitleLabel.text = NSLocalizedString(@"ProgrammingView_subtitle", nil);
//    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
//    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

//    [_segment setTitle:NSLocalizedString(@"ProgrammingView_segment_titles", nil) forSegmentAtIndex:0];  
//    [_segment setTitle:NSLocalizedString(@"ProgrammingView_segment_artists", nil) forSegmentAtIndex:1];  
//    [_segment addTarget:self action:@selector(onSegmentClicked:) forControlEvents:UIControlEventValueChanged];
    
    
    // waiting for the synchronization to be done
//    _tableView.hidden = YES;
    

    if (![SongRadioCatalog main].isInCache)
        [ActivityAlertView showWithTitle: NSLocalizedString(@"PlaylistsViewController_FetchingPlaylists", nil)];
    
    //DLog(@"%d - %d", _nbReceivedData, _nbPlaylists);
    
    // PROFILE
    [[TimeProfile main] begin:TIMEPROFILE_BUILD];
    
    [[SongRadioCatalog main] initForRadio:self.radio target:self action:@selector(radioProgrammingBuilt:)];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}


- (void)radioProgrammingBuilt:(NSDictionary*)info
{
    BOOL success = [[info objectForKey:@"success"] boolValue];
    NSString* error = [info objectForKey:@"error"];
    NSInteger count = [[info objectForKey:@"count"] integerValue];
    
    [ActivityAlertView close];

    if (!success)
    {

        // display an error dialog
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.Radio.error.title", nil) message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    
    // PROFILE
    [[TimeProfile main] end:TIMEPROFILE_BUILD];
    [[TimeProfile main] logInterval:TIMEPROFILE_BUILD inMilliseconds:NO];

    DLog(@"%d matched songs", count);
    

//    //LBDEBUG TIMEPROFILE ALERTVIEW
//    {
//        CGFloat interval = [[TimeProfile main] interval:TIMEPROFILE_BUILD inMilliseconds:NO];
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"radio" message:[NSString stringWithFormat:@"%.2fs for %d songs", interval, count] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//        [av release];
//        return;
//        
//    }
//    /////////

    
//    NSString* subtitle = nil;
//    if (songs.count == 0)
//        subtitle = NSLocalizedString(@"ProgrammingView_subtitled_count_0", nil);
//    else if (songs.count == 1)
//        subtitle = NSLocalizedString(@"ProgrammingView_subtitled_count_1", nil);
//    else if (songs.count > 1)
//        subtitle = NSLocalizedString(@"ProgrammingView_subtitled_count_n", nil);
//    
//    subtitle = [subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", songs.count]];

//    _subtitleLabel.text = subtitle;
    
    
    // now that the synchronization is been done,
//    _tableView.hidden = NO;
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
//    return [gIndexMap objectAtIndex:section];
//}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger nbSections = [SongRadioCatalog main].indexMap.count;

    return nbSections;
}


- (NSInteger)getNbRowsForTable:(UITableView*)tableView inSection:(NSInteger)section
{
    NSString* charIndex = [[SongRadioCatalog main].indexMap objectAtIndex:section];
    
    if (self.selectedSegmentIndex == RADIOSEGMENT_INDEX_TITLES) {
        NSArray* songsForLetter = [[SongRadioCatalog main] songsForLetter:charIndex];
        assert(songsForLetter != nil);
        return songsForLetter.count;
    }
    else {
        NSArray* artistsForLetter = [[SongRadioCatalog main] artistsForLetter:charIndex];
        assert(artistsForLetter != nil);
        return artistsForLetter.count;
    }
}





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![SongRadioCatalog main].isInCache)
        return 0;

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

    //LBDEBUG
    assert([SongRadioCatalog main].indexMap.count > section);

    NSString* title = [[SongRadioCatalog main].indexMap objectAtIndex:section];

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
    if (![SongRadioCatalog main].isInCache)
        return 0;
    
    NSInteger nb = [self getNbRowsForTable:tableView inSection:section];
    return nb;
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
    if (self.selectedSegmentIndex == RADIOSEGMENT_INDEX_ARTISTS)
        return nil;
    
    return [SongRadioCatalog main].indexMap;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    if (self.selectedSegmentIndex == RADIOSEGMENT_INDEX_ARTISTS)
        return 0;
    
    return index;
}






- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    cell.backgroundView = [sheet makeImage];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (self.selectedSegmentIndex == RADIOSEGMENT_INDEX_TITLES)
        return [self cellAlphaForRowAtIndexPath:indexPath];
    else
        return [self cellFolderForRowAtIndexPath:indexPath];
}




- (UITableViewCell*)cellAlphaForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"CellAlpha";

    //LBDEBUG
    assert([SongRadioCatalog main].indexMap.count > indexPath.section);

    NSString* charIndex = [[SongRadioCatalog main].indexMap objectAtIndex:indexPath.section];
    NSArray* songs = [[SongRadioCatalog main] songsForLetter:charIndex];
    
    assert(songs.count > indexPath.row);

    Song* song = [songs objectAtIndex:indexPath.row];
    
    
    ProgrammingCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[ProgrammingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withSong:song atRow:0 deletingTarget:self deletingAction:@selector(onSongDeleteRequested:song:)] autorelease];
    }
    else
        [cell updateWithSong:song atRow:0];
    
    return cell;
}


- (void)onSongDeleteRequested:(UITableViewCell*)cell song:(Song*)song
{
    DLog(@"onSongDeleteRequested for Song %@", song.name);   
    
    // request to server
    [[YasoundDataProvider main] deleteSong:song target:self action:@selector(onSongDeleted:info:) userData:cell];

}


// server's callback
- (void)onSongDeleted:(Song*)song info:(NSDictionary*)info
{
    DLog(@"onSongDeleted for Song %@", song.name);  
    DLog(@"info %@", info);
    
    BOOL success = NO;
    NSNumber* nbsuccess = [info objectForKey:@"success"];
    if (nbsuccess != nil)
        success = [nbsuccess boolValue];
    
    DLog(@"success %d", success);
    
    UITableViewCell* cell = [info objectForKey:@"userData"];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];

    //LBDEBUG
    assert(0);
    
    [[SongCatalog synchronizedCatalog] removeSynchronizedSong:song];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROGAMMING_SONG_REMOVED object:self];

    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}



- (UITableViewCell*)cellFolderForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellArtistIdentifier = @"CellArtist";

    assert([SongRadioCatalog main].indexMap.count > indexPath.section);
    
    NSString* charIndex = [[SongRadioCatalog main].indexMap objectAtIndex:indexPath.section];
    NSArray* artists = [[SongRadioCatalog main] artistsForLetter:charIndex];

    NSString* artist = [artists objectAtIndex:indexPath.row];
    
    NSInteger nbAlbums = [[SongRadioCatalog main] albumsForArtist:artist].count;

    
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellArtistIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellArtistIdentifier] autorelease];

            cell.selectionStyle = UITableViewCellSelectionStyleGray;

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.disclosureIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIImageView* di = [sheet makeImage];
            cell.accessoryView = di;
            [di release];

            sheet = [[Theme theme] stylesheetForKey:@"TableView.textLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            cell.textLabel.backgroundColor = [sheet fontBackgroundColor];
            cell.textLabel.textColor = [sheet fontTextColor];
            cell.textLabel.font = [sheet makeFont];
            
            
            sheet = [[Theme theme] stylesheetForKey:@"TableView.detailTextLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            cell.detailTextLabel.backgroundColor = [sheet fontBackgroundColor];
            cell.detailTextLabel.textColor = [sheet fontTextColor];
            cell.detailTextLabel.font = [sheet makeFont];
        }
        
    
        cell.textLabel.text = artist;

        if (nbAlbums == 1)
            cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_albums_1", nil);
        else
            cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_albums_n", nil);

         cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbAlbums]];

    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    
    
    if (self.selectedSegmentIndex == RADIOSEGMENT_INDEX_TITLES)
    {
        NSString* charIndex = [[SongRadioCatalog main].indexMap objectAtIndex:indexPath.section];
        
        NSArray* songs = [[SongRadioCatalog main] songsForLetter:charIndex];
        Song* song = [songs objectAtIndex:indexPath.row];
        
        SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:song showNowPlaying:YES forRadio:self.radio];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        NSString* charIndex = [[SongRadioCatalog main].indexMap objectAtIndex:indexPath.section];
        NSArray* artists = [[SongRadioCatalog main] artistsForLetter:charIndex];
        NSString* artist = [artists objectAtIndex:indexPath.row];

        [[SongRadioCatalog main] selectArtist:artist withCharIndex:charIndex];
        
        self.artistVC = [[ProgrammingArtistViewController alloc] initWithStyle:UITableViewStylePlain usingCatalog:[SongRadioCatalog main] forRadio:self.radio];
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

- (void)onArtistDeleteClicked:(id)sender
{
//    // one in a time
//    if (self.deleteRunning)
//        return;
//    
//    ObjectButton* button = sender;
//    
//    _alertDeleteArtist = [[ObjectAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.Catalog.radio", nil) message:NSLocalizedString(@"Programming.delete.artist", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.cancel", nil) otherButtonTitles:NSLocalizedString(@"Navigation.delete", nil),nil];
//
//    _alertDeleteArtist.userObject = button.userObject;
//    [_alertDeleteArtist show];
//    [_alertDeleteArtist release];
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //LBDEBUG TODO : pour plus tard
//    if ((alertView == _alertDeleteArtist) && (buttonIndex == 1))
//    {
//        [ActivityAlertView showWithTitle:nil];
//        NSString* artistNameFromClient = _alertDeleteArtist.userObject;
//        
//        self.deleteArtistNameFromClient = artistNameFromClient;
//        self.deleteRunning = YES;
//
//        DLog(@"ProgrammingRadioViewController request delete artist '%@'", artistNameFromClient);
//        
//        // delete artist request
//        [[YasoundDataProvider main] deleteArtist:artistNameFromClient fromRadio:self.radio target:self action:@selector(onArtistDeleted:success:)];
//        return;
//    }
}


- (void)onArtistDeleted:(ASIHTTPRequest*)req success:(BOOL)success
{
//    [ActivityAlertView close];
//    self.deleteRunning = NO;
//
//
//    if (!success)
//    {
//        DLog(@"ProgrammingRadioViewController::onArtistDeleted failed!");
//
//        UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.delete.artist.error.title", nil) message:NSLocalizedString(@"Programming.delete.artist.error", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Navigation.cancel", nil) otherButtonTitles:nil];
//        [av show];
//        [av release];
//        
//        self.deleteArtistNameFromClient = nil;
//
//        return;
//    }
//    
//    // refresh catalog
//    [[SongCatalog synchronizedCatalog] deleteArtist:self.deleteArtistNameFromClient];
//    
//    NSIndexPath* indexPath = [self.artistToIndexPath objectForKey:self.deleteArtistNameFromClient];
//    
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//    
//    self.deleteArtistNameFromClient = nil;

    
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








//
//
//
//#pragma mark - IBActions
//
//
//- (IBAction)onSynchronize:(id)semder
//{
//    ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
//}
//
//
//- (IBAction)onSegmentClicked:(id)sender
//{
//    [self.tableView reloadData];
//}
//
//
//

- (void)onNotifSongAdded:(NSNotification*)notif
{
//    [self.sortedSongs release];
//    [self.sortedArtists release];
//    
//    self.sortedArtists = [[NSMutableDictionary alloc] init];
//    self.sortedSongs = [[NSMutableDictionary alloc] init];    
//    
//    [self.tableView reloadData];
}


- (void)onNotifSongRemoved:(NSNotification*)notif
{    
//    UIViewController* sender = notif.object;
//    
//    //LBDEBUG : ICI : release objects?
//    
//    if (sender != self)
//        [self.tableView reloadData];    
}


- (void)onNotifSongUpdated:(NSNotification*)notif
{
//    UIViewController* sender = notif.object;
//    
//    if (sender != self)
//        [self.tableView reloadData];
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
////    if (itemIndex == WHEEL_ITEM_SERVER)
////        return NSLocalizedString(@"Programming.Catalog.server", nil);
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
//        ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithNibName:@"ProgrammingLocalViewController" bundle:nil forRadio:self.radio];
//        [self.navigationController pushViewController:view animated:NO];
//        [view release];
//    }
//    else if (itemIndex == WHEEL_ITEM_RADIO)
//    {
////        ProgrammingRadioViewController* view = [[ProgrammingRadioViewController alloc] initWithNibName:@"ProgrammingRadioViewController" bundle:nil  forRadio:self.radio];
////        [self.navigationController pushViewController:view animated:NO];
////        [view release];
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
