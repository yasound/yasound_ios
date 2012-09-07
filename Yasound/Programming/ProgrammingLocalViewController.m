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
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"

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
//@synthesize sortedArtists;
//@synthesize sortedSongs;
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
    
    [[SongLocalCatalog main] initFromMatchedSongs:[SongRadioCatalog main].songs  target:self action:@selector(localProgrammingBuilt:)];
}




- (void)localProgrammingBuilt:(NSDictionary*)info {
    
    BOOL success = [[info objectForKey:@"success"] boolValue];
    NSString* error = [info objectForKey:@"error"];
    NSInteger count = [[info objectForKey:@"count"] integerValue];
    
    if (!success) {
        
        [ActivityAlertView close];
        
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
    
    [ActivityAlertView close];

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
//    return [SongCatalog availableCatalog].indexMap.count;
    return 0;
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
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getNbRowsForTable:tableView inSection:section];
}


- (NSInteger)getNbRowsForTable:(UITableView*)tableView inSection:(NSInteger)section
{
//    NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:section];
//    
//    if (self.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
//    {
//        NSArray* letterRepo = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:charIndex];
//        assert(letterRepo != nil);
//        return letterRepo.count;
//    }
//    else
//    {
//        NSArray* artistsForSection = [[SongCatalog availableCatalog].alphaArtistsRepo objectForKey:charIndex];
//        NSInteger count = artistsForSection.count;
//        return count;
//    }

    return 0;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 46;
}






- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{    
//    if (self.selectedSegmentIndex == SEGMENT_INDEX_ARTIST)
//        return nil;
//    
//    if ([SongCatalog availableCatalog].nbSongs == 0)
//        return nil;
//    
//    return [SongCatalog availableCatalog].indexMap;
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    if (self.selectedSegmentIndex == SEGMENT_INDEX_ARTIST)
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
    return nil;
    
//    if (self.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
//    {
//        static NSString* CellAddIdentifier = @"CellAdd";
//
//        NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
//        NSArray* songs = [self.sortedSongs objectForKey:charIndex];
//        
//        if (songs == nil)
//        {
//            
//            songs = [[SongCatalog availableCatalog].alphabeticRepo objectForKey:charIndex];
//            
//            // sort the items array
//            songs = [songs sortedArrayUsingSelector:@selector(nameCompare:)];
//            
//            // store the cache
//            [self.sortedSongs setObject:songs forKey:charIndex];
//            
//        }
//        
//        Song* song = [songs objectAtIndex:indexPath.row];
//
//        
//        
//        SongAddCell* cell = [tableView dequeueReusableCellWithIdentifier:CellAddIdentifier];
//        
//        if (cell == nil) 
//        {
//            cell = [[[SongAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddIdentifier song:song forRadio:self.radio] autorelease];
//        }
//        else
//            [cell update:song];        
//
//        return cell;
//    }
//    else
//    {
//        static NSString* CellIdentifier = @"CellArtist";
//        
//        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        if (cell == nil) 
//        {
//            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
//
//            cell.textLabel.backgroundColor = [UIColor clearColor];
//            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
//            cell.textLabel.textColor = [UIColor whiteColor];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//
//        
//        NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
//        NSMutableDictionary* artistsForSection = [[SongCatalog availableCatalog].alphaArtistsRepo objectForKey:charIndex];
//        
//        // get sorted list
//        NSArray* artists = [self.sortedArtists objectForKey:charIndex];
//        if (artists == nil)
//        {
//            artists = [artistsForSection allKeys];
//            
//            // sort the items array
//            artists = [artists sortedArrayUsingSelector:@selector(compare:)];
//            
//            // store the cache
//            [self.sortedArtists setObject:artists forKey:charIndex];
//        }
//
//        NSString* artist = [artists objectAtIndex:indexPath.row];
//        
//        NSDictionary* artistRepo = [artistsForSection objectForKey:artist];
//        
//        NSInteger nbAlbums = artistRepo
//        
//        .count;
//        
//        cell.textLabel.text = artist;
//        
//        if (nbAlbums == 1)
//            cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_albums_1", nil);
//        else
//            cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_albums_n", nil);
//        
//        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbAlbums]];
//        
//        return cell;
//    }
//    
//    
//    
//    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
//    
//    if (self.selectedSegmentIndex == SEGMENT_INDEX_ALPHA)
//    {
//        NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
//        SongLocal* songLocal = [[self.sortedSongs objectForKey:charIndex] objectAtIndex:indexPath.row];
//
//        LocalSongInfoViewController* view = [[LocalSongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:songLocal];
//        [APPDELEGATE.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//    else
//    {
//        NSString* charIndex = [[SongCatalog availableCatalog].indexMap objectAtIndex:indexPath.section];
//        NSString* artistKey = [[self.sortedArtists objectForKey:charIndex] objectAtIndex:indexPath.row];
//        
//        [[SongCatalog availableCatalog] selectArtist:artistKey withIndex:charIndex];
//
//        
//        self.artistVC = [[ProgrammingArtistViewController alloc] initWithStyle:UITableViewStylePlain usingCatalog:[SongCatalog availableCatalog] forRadio:self.radio];
//        CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
//        self.artistVC.tableView.frame = frame;
//        [self.view.superview addSubview:self.artistVC.tableView];
//        
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.33];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        
//        frame = CGRectMake(0,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
//        self.artistVC.tableView.frame = frame;
//        
//        [UIView commitAnimations];
//    }
    
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



- (void)onNotificationUploadCanceled:(NSNotification*)notif
{
    [self.tableView reloadData];
}




@end

































