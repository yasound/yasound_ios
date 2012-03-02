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


@implementation ProgrammingViewController

@synthesize matchedSongs;
@synthesize catalog;



#define SEGMENT_INDEX_ALPHA 0
#define SEGMENT_INDEX_ARTIST 1



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
        
        self.catalog = [[SongCatalog alloc] init];
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
}





- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    _subtitleLabel.text = NSLocalizedString(@"ProgrammingView_subtitle", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
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
    
    NSLog(@"received %d playlists", _nbPlaylists);
    
    if (_nbPlaylists == 0)
    {
        [ActivityAlertView close];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProgrammingView_error_title", nil) message:NSLocalizedString(@"ProgrammingView_error_message", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;
    }
    
    
    
    for (Playlist* playlist in playlists) 
    {
        [[YasoundDataProvider main] matchedSongsForPlaylist:playlist target:self action:@selector(matchedSongsReceveived:info:)]; 
        // didReceiveMatchedSongs:(NSArray*)matched_songs info:
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
    [[TimeProfile main] end];
    [[TimeProfile main] logInterval:@"Download matched songs"];
    
    
    // PROFILE
    [[TimeProfile main] begin];

    // merge songs
    for (NSInteger i = 0; i < _data.count; i++)
    {
        NSArray* songs = [_data objectAtIndex:i];
        
        for (Song* song in songs)
        {
            // be aware of empty artist names, and empty album names
            NSString* artistKey = song.artist;
            if ((artistKey == nil) || (artistKey.length == 0))
            {
                artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
                NSLog(@"empty artist found!");
            }
            NSString* albumKey = song.album;
            if ((albumKey == nil) || (albumKey.length == 0))
            {
                artistKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
                NSLog(@"empty album found!");
            }
            
            
            // create a key for the dictionary 
            NSString* key = [NSString stringWithFormat:@"%@|%@|%@", song.name, artistKey, albumKey];
            // and store the song in the dictionnary, for later convenient use
            [self.matchedSongs setObject:song forKey:key];
        }
    }
    
    // build catalog
    [self.catalog buildWithSource:self.matchedSongs];
    

    // PROFILE
    [[TimeProfile main] end];
    [[TimeProfile main] logInterval:@"Sort matched songs"];

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
    
    
    //LBDEBUG
    //NSLog(@"%@", self.artistsRepo);
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


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        title = [self.catalog.indexMap objectAtIndex:section];
    }
    else
    {
        title = [self.catalog.artistsRepoKeys objectAtIndex:section];
    }
    
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"MenuSection" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    
    UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 44);
    
    sheet = [[Theme theme] stylesheetForKey:@"MenuSectionTitle" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UILabel* label = [sheet makeLabel];
    label.text = title;
    [view addSubview:label];
    
    return view;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
        return self.catalog.indexMap.count;
    else
        return self.catalog.artistsRepoKeys.count;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [self.catalog.alphabeticRepo objectForKey:[self.catalog.indexMap objectAtIndex:section]];
        assert(letterRepo != nil);
        return letterRepo.count;
    }
    else
    {
        NSString* artist = [self.catalog.artistsRepoKeys objectAtIndex:section]; 
        NSDictionary* albumsRepo = [self.catalog.artistsRepo objectForKey:artist];
        NSArray* albumsValues = [albumsRepo allValues];
        NSInteger count = 0;
        for (NSArray* album in albumsValues)
            count += album.count;
            
        return count;
    }
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





- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return self.catalog.indexMap;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
        return index;
    else
    {
        NSNumber* nb = [self.catalog.artistsIndexSections objectAtIndex:index];
        return [nb integerValue];
    }
}






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
    
    Song* song = nil;
    
    if (_segment.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
    {
        NSArray* letterRepo = [self.catalog.alphabeticRepo objectForKey:[self.catalog.indexMap objectAtIndex:indexPath.section]];
        song = [letterRepo objectAtIndex:indexPath.row];
    }
    else
    {
        NSString* artist = [self.catalog.artistsRepoKeys objectAtIndex:indexPath.section];
        NSDictionary* albumsRepo = [self.catalog.artistsRepo objectForKey:artist];
        NSArray* albumsValues = [albumsRepo allValues];
        NSInteger count = 0;
        BOOL done = NO;
        for (NSArray* album in albumsValues)
        {
            for (Song* albumSong in album)
            {
                if (count == indexPath.row)
                {
                    song = albumSong;
                    done = YES;
                    break;
                }
                count++;
            }
            
            if (done)
                break;
        }
}
    
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
    NSArray* letterRepo = [self.catalog.alphabeticRepo objectForKey:[self.catalog.indexMap objectAtIndex:indexPath.section]];
    Song* song = [letterRepo objectAtIndex:indexPath.row];
    
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

- (IBAction)onSegmentClicked:(id)sender
{
    [_tableView reloadData];
}


@end
