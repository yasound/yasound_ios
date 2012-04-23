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
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongCatalog.h"
#import "ProgrammingArtistViewController.h"
#import "RootViewController.h"
#import "AudioStreamManager.h"
#import "ProgrammingTitleCell.h"

@implementation ProgrammingViewController

@synthesize matchedSongs;


#define SEGMENT_INDEX_ALPHA 0
#define SEGMENT_INDEX_ARTIST 1

#define TIMEPROFILE_DOWNLOAD @"Programming download synchronized"
#define TIMEPROFILE_BUILD @"Programming build catalog"



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _data = [[NSMutableArray alloc] init];
        [_data retain];
        
        _nbReceivedData = 0;
        _nbPlaylists = 0;
        
        self.matchedSongs = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)dealloc
{
    [SongCatalog releaseSynchronizedCatalog];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView release];
    [super dealloc];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    

    _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    _subtitleLabel.text = NSLocalizedString(@"ProgrammingView_subtitle", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    [_segment setTitle:NSLocalizedString(@"ProgrammingView_segment_titles", nil) forSegmentAtIndex:0];  
    [_segment setTitle:NSLocalizedString(@"ProgrammingView_segment_artists", nil) forSegmentAtIndex:1];  
    [_segment addTarget:self action:@selector(onSegmentClicked:) forControlEvents:UIControlEventValueChanged];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    // waiting for the synchronization to be done
    _tableView.hidden = YES;
    

    [ActivityAlertView showWithTitle: NSLocalizedString(@"PlaylistsViewController_FetchingPlaylists", nil)];
    
    //NSLog(@"%d - %d", _nbReceivedData, _nbPlaylists);
    
    // PROFILE
    [[TimeProfile main] begin:TIMEPROFILE_DOWNLOAD];
    
    Radio* radio = [YasoundDataProvider main].radio;
    [[YasoundDataProvider main] playlistsForRadio:radio target:self action:@selector(receivePlaylists:withInfo:)];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([AudioStreamManager main].currentRadio == nil)
        [_nowPlayingButton setEnabled:NO];
    else
        [_nowPlayingButton setEnabled:YES];

}



- (void)receivePlaylists:(NSArray*)playlists withInfo:(NSDictionary*)info
{
    if (playlists == nil)
        _nbPlaylists = 0;
    else
        _nbPlaylists = playlists.count;
    
    
    NSLog(@"received %d playlists", _nbPlaylists);
    
    if (_nbPlaylists == 0)
    {
        [ActivityAlertView close];
        
        
        // disable all functions
        _addBtn.enabled = NO;
        _segment.enabled = NO;
        _synchroBtn.enabled = NO;
        _subtitleLabel.text =  NSLocalizedString(@"ProgrammingView_subtitle_error", nil);
        
        
        // display an error dialog
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProgrammingView_error_title", nil) message:NSLocalizedString(@"ProgrammingView_error_no_playlist_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;
    }
    
    
    
    for (Playlist* playlist in playlists) 
    {
        [[YasoundDataProvider main] matchedSongsForPlaylist:playlist target:self action:@selector(matchedSongsReceveived:info:)]; 
    }
}


- (void)matchedSongsReceveived:(NSArray*)songs info:(NSDictionary*)info
{
    NSNumber* succeededNb = [info objectForKey:@"succeeded"];
    assert(succeededNb != nil);
    BOOL succeeded = [succeededNb boolValue];
    
    if (!succeeded)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProgrammingView_error_title", nil) message:NSLocalizedString(@"ProgrammingView_error_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  

        NSLog(@"matchedSongsReceveived : REQUEST FAILED for playlist nb %d", _nbReceivedData);
        NSLog(@"%@", info);
    }
    
    
    NSLog(@"received playlist nb %d : %d songs", _nbReceivedData, songs.count);
    


    
    _nbReceivedData++;
    
    if (succeeded && (songs != nil) && (songs.count != 0))
        [_data addObject:songs];
    
    if (_nbReceivedData != _nbPlaylists)
        return;
    
    //PROFILE
    [[TimeProfile main] end:TIMEPROFILE_DOWNLOAD];
    [[TimeProfile main] logInterval:TIMEPROFILE_DOWNLOAD inMilliseconds:NO];
    
    
    // PROFILE
    [[TimeProfile main] begin:TIMEPROFILE_BUILD];

    // merge songs
    for (NSInteger i = 0; i < _data.count; i++)
    {
        NSArray* songs = [_data objectAtIndex:i];
        
        for (Song* song in songs)
        {
            // create a key for the dictionary 
            NSString* key = [SongCatalog catalogKeyOfSong:song.name artist:song.artist album:song.album];

            // and store the song in the dictionnary, for later convenient use
            [self.matchedSongs setObject:song forKey:key];
            
        }
    }
    
    
    // build catalog
    [[SongCatalog synchronizedCatalog] buildSynchronizedWithSource:self.matchedSongs];
    [SongCatalog synchronizedCatalog].matchedSongs = self.matchedSongs;
    

    // PROFILE
    [[TimeProfile main] end:TIMEPROFILE_BUILD];
    [[TimeProfile main] logInterval:TIMEPROFILE_BUILD inMilliseconds:NO];

    NSLog(@"%d matched songs", self.matchedSongs.count);
    
    NSString* subtitle = nil;
    if (self.matchedSongs.count == 0)
        subtitle = NSLocalizedString(@"ProgrammingView_subtitled_count_0", nil);
    else if (self.matchedSongs.count == 1)
        subtitle = NSLocalizedString(@"ProgrammingView_subtitled_count_1", nil);
    else if (self.matchedSongs.count > 1)
        subtitle = NSLocalizedString(@"ProgrammingView_subtitled_count_n", nil);
    
    subtitle = [subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", self.matchedSongs.count]];

    _subtitleLabel.text = subtitle;
    
    
    // now that the synchronization is been done,
    _tableView.hidden = NO;
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
//    return [gIndexMap objectAtIndex:section];
//}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [SongCatalog synchronizedCatalog].indexMap.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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
    return [self getNbRowsForTable:tableView inSection:section];
}


- (NSInteger)getNbRowsForTable:(UITableView*)tableView inSection:(NSInteger)section
{
    NSString* charIndex = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:section];
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [[SongCatalog synchronizedCatalog].alphabeticRepo objectForKey:charIndex];
        assert(letterRepo != nil);
        return letterRepo.count;
    }
    else
    {
        NSArray* artistsForSection = [[SongCatalog synchronizedCatalog].alphaArtistsOrder objectForKey:charIndex];
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
    return [SongCatalog synchronizedCatalog].indexMap;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
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
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
        return [self cellAlphaForRowAtIndexPath:indexPath];
    else
        return [self cellFolderForRowAtIndexPath:indexPath];
}




- (UITableViewCell*)cellAlphaForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"CellAlpha";

    NSString* charIndex = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:indexPath.section];
    NSArray* letterRepo = [[SongCatalog synchronizedCatalog].alphabeticRepo objectForKey:charIndex];
    Song* song = [letterRepo objectAtIndex:indexPath.row];
    
    ProgrammingTitleCell* cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[ProgrammingTitleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withSong:song deletingTarget:self deletingAction:@selector(onSongDeleteRequested:song:)] autorelease];
    }
    else
        [cell updateWithSong:song];
    
    return cell;
}


- (void)onSongDeleteRequested:(UITableViewCell*)cell song:(Song*)song
{
    NSLog(@"onSongDeleteRequested for Song %@", song.name);   
    
    // request to server
    [[YasoundDataProvider main] deleteSong:song target:self action:@selector(onSongDeleted:info:) userData:cell];

}


// server's callback
- (void)onSongDeleted:(Song*)song info:(NSDictionary*)info
{
    NSLog(@"onSongDeleted for Song %@", song.name);  
    NSLog(@"info %@", info);
    
    BOOL success = NO;
    NSNumber* nbsuccess = [info objectForKey:@"success"];
    if (nbsuccess != nil)
        success = [nbsuccess boolValue];
    
    NSLog(@"success %d", success);
    
    UITableViewCell* cell = [info objectForKey:@"userData"];
    NSIndexPath* indexPath = [_tableView indexPathForCell:cell];

    [[SongCatalog synchronizedCatalog] removeSynchronizedSong:song atIndexPath:indexPath];
    
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];        
}



- (UITableViewCell*)cellFolderForRowAtIndexPath:(NSIndexPath*)indexPath
{
        NSString* charIndex = [[SongCatalog synchronizedCatalog].indexMap objectAtIndex:indexPath.section];
        NSArray* artistsForSection = [[SongCatalog synchronizedCatalog].alphaArtistsOrder objectForKey:charIndex];
        static NSString* CellIdentifier = @"Cell";
        
        UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        
        NSString* artist = [artistsForSection objectAtIndex:indexPath.row];
        
        NSDictionary* artistsRepo = [[SongCatalog synchronizedCatalog].alphaArtistsRepo objectForKey:charIndex];
        NSDictionary* artistRepo = [artistsRepo objectForKey:artist];

        NSInteger nbAlbums = artistRepo.count;
        
        cell.textLabel.textColor = [UIColor whiteColor];
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
    
    
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [[SongCatalog synchronizedCatalog].alphabeticRepo objectForKey:[[SongCatalog synchronizedCatalog].indexMap objectAtIndex:indexPath.section]];
        Song* song = [letterRepo objectAtIndex:indexPath.row];
        
        SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:song];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        [[SongCatalog synchronizedCatalog] selectArtistInSection:indexPath.section atRow:indexPath.row];
        
        ProgrammingArtistViewController* view = [[ProgrammingArtistViewController alloc] initWithNibName:@"ProgrammingArtistViewController" bundle:nil usingCatalog:[SongCatalog synchronizedCatalog]];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }

}
















#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nowPlayingClicked:(id)sender
{
    // call root to launch the Radio
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil]; 
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

- (IBAction)onSegmentClicked:(id)sender
{
    [_tableView reloadData];
}



- (void)onNotifSongAdded:(NSNotification*)notif
{
    [_tableView reloadData];    
}


@end
