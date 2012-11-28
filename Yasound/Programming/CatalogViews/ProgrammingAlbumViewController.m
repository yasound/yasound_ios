//
//  ProgrammingAlbumViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingAlbumViewController.h"
#import "ActivityAlertView.h"
#import "YasoundRadio.h"
#import "YasoundDataProvider.h"
#import "SongInfoViewController.h"
#import "ProgrammingUploadViewController.h"
#import "ProgrammingLocalViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"
#import "SongUploader.h"
#import "SongUploadManager.h"
#import "RootViewController.h"
#import "ActionAddSongCell.h"
#import "AudioStreamManager.h"
#import "LocalSongInfoViewController.h"
#import "ProgrammingCell.h"
#import "ProgrammingLocalViewController.h"
#import "ProgrammingRadioViewController.h"
#import "YasoundAppDelegate.h"
#import "ActionRemoveSongCell.h"

@implementation ProgrammingAlbumViewController

@synthesize radio;
@synthesize catalog;


- (void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog forRadio:(YasoundRadio*)radio
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.radio = radio;
        self.catalog = catalog;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
        
        
        [self load];
    }
    return self;
}




- (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongRemoved:) name:NOTIF_PROGAMMING_SONG_REMOVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongUpdated:) name:NOTIF_PROGAMMING_SONG_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationUploadCanceled:) name:NOTIF_SONG_GUI_NEED_REFRESH object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
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





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}






- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSArray* songs = nil;
    
    DLog(@"selected Album '%@'", self.catalog.selectedAlbum);
    
    if (self.catalog.selectedGenre) {
        songs = [self.catalog songsForAlbum:self.catalog.selectedAlbum fromArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
    }
    else if (self.catalog.selectedPlaylist) {
        songs = [self.catalog songsForAlbum:self.catalog.selectedAlbum fromArtist:self.catalog.selectedArtist withPlaylist:self.catalog.selectedPlaylist];
    }
    else
        songs = [self.catalog songsForAlbum:self.catalog.selectedAlbum fromArtist:self.catalog.selectedArtist];
    
    return songs.count;
}





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DLog(@"selected Album '%@'", self.catalog.selectedAlbum);

    NSString* title = nil;
    if (self.catalog.selectedGenre) {
        title = [NSString stringWithFormat:@"%@: %@: %@", self.catalog.selectedGenre, self.catalog.selectedArtist, self.catalog.selectedAlbum];
    }
    else if (self.catalog.selectedPlaylist) {
        title = [NSString stringWithFormat:@"%@: %@: %@", self.catalog.selectedPlaylist, self.catalog.selectedArtist, self.catalog.selectedAlbum];
    }
    else
        title = [NSString stringWithFormat:@"%@", self.catalog.selectedAlbum];
    
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.Section.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];
    
    sheet = [[Theme theme] stylesheetForKey:@"Programming.Section.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    cell.backgroundView = [sheet makeImage];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSArray* songs = nil;
    
    if (self.catalog.selectedGenre) {
        songs = [self.catalog songsForAlbum:self.catalog.selectedAlbum fromArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
    }
    else if (self.catalog.selectedPlaylist) {
        songs = [self.catalog songsForAlbum:self.catalog.selectedAlbum fromArtist:self.catalog.selectedArtist withPlaylist:self.catalog.selectedPlaylist];
    }
    else
        songs = [self.catalog songsForAlbum:self.catalog.selectedAlbum fromArtist:self.catalog.selectedArtist];

    NSString* songKey = [songs objectAtIndex:indexPath.row];
    Song* song = [self.catalog.songsDb objectForKey:songKey];

    
    if (self.catalog == [SongLocalCatalog main])
    {
        static NSString* CellAddIdentifier = @"CellAdd";
        
        ActionAddSongCell* cell = [tableView dequeueReusableCellWithIdentifier:CellAddIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[ActionAddSongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddIdentifier song:song forRadio:self.radio] autorelease];
        }
        else
            [cell update:song];        
        
        return cell;
    }
    
    else
    {
        static NSString* CellIdentifier = @"CellAlbumSong";

        ActionRemoveSongCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[ActionRemoveSongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier song:song forRadio:self.radio] autorelease];
        }
        else
            [cell update:song];
        
        return cell;
    }
    
    return nil;
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

    
    // clean catalogs and wait for the refresh notifs
    [[SongRadioCatalog main] updateSongRemovedFromProgramming:song];
    [[SongLocalCatalog main] updateSongRemovedFromProgramming:song];
}







- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    NSArray* songs = nil;
    
    if (self.catalog.selectedGenre) {
        songs = [self.catalog songsForAlbum:self.catalog.selectedAlbum fromArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
    }
    else if (self.catalog.selectedPlaylist) {
        songs = [self.catalog songsForAlbum:self.catalog.selectedAlbum fromArtist:self.catalog.selectedArtist withPlaylist:self.catalog.selectedPlaylist];
    }
    else
        songs = [self.catalog songsForAlbum:self.catalog.selectedAlbum fromArtist:self.catalog.selectedArtist];

    NSString* songKey = [songs objectAtIndex:indexPath.row];
    Song* song = [self.catalog.songsDb objectForKey:songKey];
    
    if (self.catalog == [SongRadioCatalog main])
    {
        SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:song showNowPlaying:YES forRadio:self.radio];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (self.catalog == [SongLocalCatalog main])
    {
        SongLocal* songLocal = song;

        LocalSongInfoViewController* view = [[LocalSongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:songLocal];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }

}







#pragma mark - IBActions



- (void)onNotifSongAdded:(NSNotification*)notif
{
    [self.tableView reloadData];
}


- (void)onNotifSongRemoved:(NSNotification*)notif
{    
    [self.tableView reloadData];
}


- (void)onNotifSongUpdated:(NSNotification*)notif
{
        [self.tableView reloadData];
}



- (void)onNotificationUploadCanceled:(NSNotification*)notif
{
    [self.tableView reloadData];
}


@end
