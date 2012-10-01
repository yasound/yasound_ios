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
#import "RootViewController.h"
#import "AudioStreamManager.h"
#import "YasoundAppDelegate.h"
#import "ObjectButton.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"
#import "DataBase.h"
#import "ActionRemoveSongCell.h"
#import "ActionRemoveCollectionCell.h"



@implementation ProgrammingRadioViewController

@synthesize radio;
@synthesize artistVC;
@synthesize songToIndexPath;


#define TIMEPROFILE_BUILD @"Programming build catalog"




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
        self.radio = radio;
        self.songToIndexPath = [NSMutableDictionary dictionary];
        
        self.selectedSegmentIndex = RADIOSEGMENT_INDEX_TITLES;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];

        // anti-bug
        NSString* catalogId = [NSString stringWithFormat:@"%@", [SongRadioCatalog main].radio.id];
        NSString* newId = [NSString stringWithFormat:@"%@", self.radio.id];
        
        // clean catalog
        if (([SongRadioCatalog main].radio.id != nil) && ![catalogId isEqualToString:newId])
        {
            [SongRadioCatalog releaseCatalog];
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
    
    if (![SongRadioCatalog main].isInCache)
        [ActivityAlertView showWithTitle: NSLocalizedString(@"PlaylistsViewController_FetchingPlaylists", nil)];
    
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
    
    // now that the synchronization is been done,
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
    
    if ((self.selectedSegmentIndex == RADIOSEGMENT_INDEX_TITLES) || (self.selectedSegmentIndex == RADIOSEGMENT_INDEX_ARTISTS))
        return 22;
    
    return 32;
}




- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger nbRows = [self getNbRowsForTable:tableView inSection:section];

    if (nbRows == 0)
        return nil;

    //LBDEBUG
    assert([SongRadioCatalog main].indexMap.count > section);

    NSString* title = [[SongRadioCatalog main].indexMap objectAtIndex:section];

    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.Section.background" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* view = [sheet makeImage];

    if ((self.selectedSegmentIndex == RADIOSEGMENT_INDEX_TITLES) || (self.selectedSegmentIndex == RADIOSEGMENT_INDEX_ARTISTS))
        sheet = [[Theme theme] stylesheetForKey:@"Programming.Section.labelTitles" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    else
        sheet = [[Theme theme] stylesheetForKey:@"Programming.Section.label" retainStylesheet:YES overwriteStylesheet:NO error:nil];
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
    if (self.selectedSegmentIndex == RADIOSEGMENT_INDEX_TITLES) {

        static NSString* CellIdentifier = @"CellAlpha";

        //LBDEBUG
        assert([SongRadioCatalog main].indexMap.count > indexPath.section);

        NSString* charIndex = [[SongRadioCatalog main].indexMap objectAtIndex:indexPath.section];
        NSArray* songs = [[SongRadioCatalog main] songsForLetter:charIndex];

        assert(songs.count > indexPath.row);

        Song* song = [songs objectAtIndex:indexPath.row];

        
        ActionRemoveSongCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[ActionRemoveSongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier song:song forRadio:self.radio] autorelease];
        }
        else
            [cell update:song];
        
        // store
        [self.songToIndexPath setObject:indexPath forKey:song.catalogKey];
        
        return cell;

    }
    
    else {
        
        static NSString* CellArtistIdentifier = @"CellArtist";

        assert([SongRadioCatalog main].indexMap.count > indexPath.section);

        NSString* charIndex = [[SongRadioCatalog main].indexMap objectAtIndex:indexPath.section];
        NSArray* artists = [[SongRadioCatalog main] artistsForLetter:charIndex];

        NSString* artist = [artists objectAtIndex:indexPath.row];

        NSInteger nbAlbums = [[SongRadioCatalog main] albumsForArtist:artist].count;


        NSString* subtitle = nil;
        if (nbAlbums == 1)
            subtitle = NSLocalizedString(@"Programming.nbAlbums.1", nil);
        else
            subtitle = NSLocalizedString(@"Programming.nbAlbums.n", nil);

        subtitle = [subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbAlbums]];

        ActionRemoveCollectionCell* cell = [tableView dequeueReusableCellWithIdentifier:CellArtistIdentifier];
        
        if (cell == nil)
        {
            cell = [[[ActionRemoveCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellArtistIdentifier artist:artist subtitle:subtitle forRadio:self.radio usingCatalog:[SongRadioCatalog main]] autorelease];
        }
        else
            [cell updateArtist:artist subtitle:subtitle];
        
        return cell;

    }
    
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



#pragma mark - UIAlertViewDelegate


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




- (void)onNotifSongAdded:(NSNotification*)notif
{
    [self.tableView reloadData];
}


- (void)onNotifSongRemoved:(NSNotification*)notif
{    
    DLog(@"onNotifSongRemoved");

    Song* song = notif.object;
    assert(song);
    
    [self.songToIndexPath removeObjectForKey:song];
    
    [self.tableView reloadData];
}


- (void)onNotifSongUpdated:(NSNotification*)notif
{
}





@end
