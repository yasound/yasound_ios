//
//  ProgrammingLocalViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingLocalViewController.h"
#import "ProgrammingViewController.h"
#import "Song.h"
#import "SongLocal.h"
#import "SongUploader.h"
#import "SongUploadManager.h"
#import "TimeProfile.h"
#import "ActivityAlertView.h"
#import "ProgrammingUploadViewController.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"

#import "BundleFileManager.h"
#import "Theme.h"
#import "YasoundDataProvider.h"
#import "RootViewController.h"
#import "LocalSongInfoViewController.h"
#import "SongAddCell.h"
#import "ProgrammingRadioViewController.h"
#import "ProgrammingUploadViewController.h"
#import "YasoundAppDelegate.h"

//LBDEBUG TEMPORARLY
#import "DataBase.h"
#import "PlaylistMoulinor.h"


#define TIMEPROFILE_AVAILABLECATALOG_BUILD @"TimeProfileAvailableCatalogBuild"

#define BORDER 8

@implementation ProgrammingLocalViewController

@synthesize radio;
@synthesize selectedSegmentIndex;
//@synthesize sortedArtists;
//@synthesize sortedSongs;
@synthesize collectionVC;
//@synthesize genreVC;




- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (self.collectionVC)
    {
        [self.collectionVC onBackClicked];
        [self.collectionVC.tableView removeFromSuperview];
        [self.collectionVC release];
        self.collectionVC = nil;
    }

//    if (self.playlistVC)
//    {
//        [self.playlistVC onBackClicked];
//        [self.playlistVC.tableView removeFromSuperview];
//        [self.playlistVC release];
//        self.playlistVC = nil;
//    }
    
    [super dealloc];
    
}



- (id)initWithStyle:(UITableViewStyle)style forRadio:(Radio*)radio
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.selectedSegmentIndex = LOCALSEGMENT_INDEX_PLAYLISTS;
        
        self.radio = radio;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];
        
//        self.sortedArtists = [[NSMutableDictionary alloc] init];
//        self.sortedSongs = [[NSMutableDictionary alloc] init];
        
        [self load];
    }
    return self;
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





- (void)load
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationUploadCanceled:) name:NOTIF_SONG_GUI_NEED_REFRESH object:nil];

    if (![SongLocalCatalog main].isInCache)
        [ActivityAlertView showWithTitle: NSLocalizedString(@"SongAddView_alert", nil)];
    
    
    //DLog(@"%d - %d", _nbReceivedData, _nbPlaylists);
    
    // PROFILE
    [[TimeProfile main] begin:TIMEPROFILE_AVAILABLECATALOG_BUILD];
    
//    [[SongLocalCatalog main] initFromMatchedSongs:[SongRadioCatalog main].songs  target:self action:@selector(localProgrammingBuilt:)];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(afterBreathing:) userInfo:nil repeats:NO];
    
    
}


- (void)afterBreathing:(NSTimer*)timer {
    
    [[SongLocalCatalog main] initFromMatchedSongs:[SongRadioCatalog main].songs  target:self action:@selector(localProgrammingBuilt:)];
}




- (void)localProgrammingBuilt:(NSDictionary*)info {
    
    [ActivityAlertView close];

    BOOL success = [[info objectForKey:@"success"] boolValue];
    NSString* error = [info objectForKey:@"error"];
    NSInteger count = [[info objectForKey:@"count"] integerValue];
    
    if (!success) {
        
        // display an error dialog
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.Radio.error.title", nil) message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }

    // PROFILE
    [[TimeProfile main] end:TIMEPROFILE_AVAILABLECATALOG_BUILD];
    [[TimeProfile main] logInterval:TIMEPROFILE_AVAILABLECATALOG_BUILD inMilliseconds:NO];
    
    DLog(@"%d available songs", count);
    

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

    if (count == 0) {
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.empty" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        UIImageView* emptyView = [sheet makeImage];
        [self.view addSubview:emptyView];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.Catalog.local", nil) message:NSLocalizedString(@"Programming.empty", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
        return;        
    }
    
    [self.tableView reloadData];
    

}
    
    








#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ((self.selectedSegmentIndex == LOCALSEGMENT_INDEX_PLAYLISTS) || (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_GENRES))
        return 1;
    
    return [SongLocalCatalog main].indexMap.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![SongLocalCatalog main].isInCache)
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
    assert([SongLocalCatalog main].indexMap.count > section);
    
    NSString* title = nil;
    if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_PLAYLISTS)
        title = NSLocalizedString(@"Programming.segment.playlists", nil);
    else if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_GENRES)
        title = NSLocalizedString(@"Programming.segment.genres", nil);
    else if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_TITLES)
        title = [[SongLocalCatalog main].indexMap objectAtIndex:section];

    
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
    if (![SongLocalCatalog main].isInCache)
        return 0;
    
    NSInteger nb = [self getNbRowsForTable:tableView inSection:section];
    return nb;
}


- (NSInteger)getNbRowsForTable:(UITableView*)tableView inSection:(NSInteger)section
{
    
    if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_TITLES) {
        NSString* charIndex = [[SongLocalCatalog main].indexMap objectAtIndex:section];
        NSArray* songsForLetter = [[SongLocalCatalog main] songsForLetter:charIndex];
        assert(songsForLetter != nil);
        return songsForLetter.count;
    }
    
    else if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_PLAYLISTS) {
        NSArray* playlists = [[SongLocalCatalog main] playlistsAll];
        assert(playlists != nil);
        return playlists.count;
    }
    
    else if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_GENRES) {
        NSArray* genres = [[SongLocalCatalog main] genresAll];
        assert(genres != nil);
        return genres.count;
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 46;
}






- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{    
    if ((self.selectedSegmentIndex == LOCALSEGMENT_INDEX_GENRES) || (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_PLAYLISTS))
        return nil;
    
    if ([SongLocalCatalog main].songsDb == 0)
        return nil;
    
    return [SongLocalCatalog main].indexMap;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    if ((self.selectedSegmentIndex == LOCALSEGMENT_INDEX_GENRES) || (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_PLAYLISTS))
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
    NSString* charIndex = [[SongLocalCatalog main].indexMap objectAtIndex:indexPath.section];

    
    if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_TITLES)
    {
        static NSString* CellAddIdentifier = @"CellAdd";

        NSArray* songs = [[SongLocalCatalog main] songsForLetter:charIndex];
        assert(songs.count > indexPath.row);
        SongLocal* song = [songs objectAtIndex:indexPath.row];
        assert([song isKindOfClass:[SongLocal class]]);

        SongAddCell* cell = [tableView dequeueReusableCellWithIdentifier:CellAddIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[SongAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddIdentifier song:song forRadio:self.radio] autorelease];
        }
        else
            [cell update:song];        

        return cell;
    }
    else if ((self.selectedSegmentIndex == LOCALSEGMENT_INDEX_GENRES) || (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_PLAYLISTS))
    {
        static NSString* CellIdentifier = @"CellGenre";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

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
        
        if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_GENRES) {
            
            NSArray* collections = [[SongLocalCatalog main] genresAll];
            NSString* collection = [collections objectAtIndex:indexPath.row];
            NSInteger nbItems = [[SongLocalCatalog main] artistsForGenre:collection].count;
            
            cell.textLabel.text = collection;
            
            if (nbItems == 1)
                cell.detailTextLabel.text = NSLocalizedString(@"Programmin.nbArtists.1", nil);
            else
                cell.detailTextLabel.text = NSLocalizedString(@"Programmin.nbArtists.n", nil);
            
            cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbItems]];
        }
        else if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_PLAYLISTS) {
            
            NSArray* collections = [[SongLocalCatalog main] playlistsAll];
            NSString* collection = [collections objectAtIndex:indexPath.row];
            NSInteger nbItems = [[SongLocalCatalog main] artistsForPlaylist:collection].count;
            
            cell.textLabel.text = collection;
            
            if (nbItems == 1)
                cell.detailTextLabel.text = NSLocalizedString(@"Programmin.nbArtists.1", nil);
            else
                cell.detailTextLabel.text = NSLocalizedString(@"Programmin.nbArtists.n", nil);
            
            cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbItems]];
        }

        
        return cell;
    }
    
    
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_TITLES)
    {
        NSString* charIndex = [[SongLocalCatalog main].indexMap objectAtIndex:indexPath.section];
        
        NSArray* songs = [[SongLocalCatalog main] songsForLetter:charIndex];
        SongLocal* songLocal = [songs objectAtIndex:indexPath.row];
        

        LocalSongInfoViewController* view = [[LocalSongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:songLocal];
        [APPDELEGATE.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_GENRES)
    {
        NSArray* collections = [[SongLocalCatalog main] genresAll];
        NSString* collection = [collections objectAtIndex:indexPath.row];
        NSArray* artists = [[SongLocalCatalog main] artistsForGenre:collection];

        self.collectionVC = [[ProgrammingCollectionViewController alloc] initWithStyle:UITableViewStylePlain usingCatalog:[SongLocalCatalog main] withArtists:artists forRadio:self.radio];
        CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.collectionVC.tableView.frame = frame;
        [self.view.superview addSubview:self.collectionVC.tableView];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

        frame = CGRectMake(0,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.collectionVC.tableView.frame = frame;
        
        [UIView commitAnimations];
    }
    else if (self.selectedSegmentIndex == LOCALSEGMENT_INDEX_PLAYLISTS)
    {
        NSArray* collections = [[SongLocalCatalog main] playlistsAll];
        NSString* collection = [collections objectAtIndex:indexPath.row];
        NSArray* artists = [[SongLocalCatalog main] artistsForPlaylist:collection];
        
        self.collectionVC = [[ProgrammingCollectionViewController alloc] initWithStyle:UITableViewStylePlain usingCatalog:[SongLocalCatalog main] withArtists:artists forRadio:self.radio];
        CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.collectionVC.tableView.frame = frame;
        [self.view.superview addSubview:self.collectionVC.tableView];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        frame = CGRectMake(0,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.collectionVC.tableView.frame = frame;
        
        [UIView commitAnimations];
    }
    
}



- (void)setSegment:(NSInteger)index
{
    self.selectedSegmentIndex = index;
    
    if (self.collectionVC)
    {
        [self.collectionVC onBackClicked];
        [self.collectionVC.tableView removeFromSuperview];
        [self.collectionVC release];
        self.collectionVC = nil;
    }
    
    [self.tableView reloadData];
}




- (BOOL)onBackClicked
{
    BOOL goBack = YES;
    if (self.collectionVC)
    {
        goBack = [self.collectionVC onBackClicked];
        
        if (goBack)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.33];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
            
            CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
            self.collectionVC.tableView.frame = frame;
            
            [UIView commitAnimations];
            
            return NO;
        }
    }
    
    return goBack;
}




- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.collectionVC.tableView removeFromSuperview];
    [self.collectionVC release];
    self.collectionVC = nil;
}



- (void)onNotificationUploadCanceled:(NSNotification*)notif
{
    [self.tableView reloadData];
}




@end

































