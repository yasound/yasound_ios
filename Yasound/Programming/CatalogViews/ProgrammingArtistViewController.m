//
//  ProgrammingArtistViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingArtistViewController.h"
#import "ActivityAlertView.h"
#import "Radio.h"
#import "YasoundDataProvider.h"
#import "SongInfoViewController.h"
#import "ProgrammingUploadViewController.h"
#import "ProgrammingLocalViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"
#import "RootViewController.h"
#import "AudioStreamManager.h"
#import "SongLocal.h"
#import "ProgrammingCell.h"
//#import "ProgrammingLocalViewController.h"
//#import "ProgrammingRadioViewController.h"
#import "ActionCollectionCell.h"


@implementation ProgrammingArtistViewController


@synthesize radio;
@synthesize catalog;
//@synthesize sortedAlbums;
@synthesize albumVC;

- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog forRadio:(Radio*)radio
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.radio = radio;
        self.catalog = catalog;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonGradient.png"]];

        
//        NSArray* array = [self.catalog.selectedArtistRepo allKeys];
//         self.sortedAlbums = [array sortedArrayUsingSelector:@selector(compare:)];
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
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
    NSArray* albums = nil;
    NSInteger count = 0;
    
    if (self.catalog.selectedGenre) {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
    }
    else if (self.catalog.selectedPlaylist) {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist withPlaylist:self.catalog.selectedPlaylist];
    }
    else
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist];
    
    count = albums.count;
    return count;
}




- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    if (self.catalog.selectedGenre) {
        title = [NSString stringWithFormat:@"%@: %@", self.catalog.selectedGenre, self.catalog.selectedArtist];
    }
    else if (self.catalog.selectedPlaylist) {
        title = [NSString stringWithFormat:@"%@: %@", self.catalog.selectedPlaylist, self.catalog.selectedArtist];
    }
    else
        title = [NSString stringWithFormat:@"%@", self.catalog.selectedArtist];
    
    
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



//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    static NSString* CellIdentifier = @"Cell";
//    
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) 
//    {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.disclosureIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    UIImageView* di = [sheet makeImage];
//    cell.accessoryView = di;
//    [di release];
//
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    
//    sheet = [[Theme theme] stylesheetForKey:@"TableView.textLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    cell.textLabel.backgroundColor = [sheet fontBackgroundColor];
//    cell.textLabel.textColor = [sheet fontTextColor];
//    cell.textLabel.font = [sheet makeFont];
//    
//    
//    sheet = [[Theme theme] stylesheetForKey:@"TableView.detailTextLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    cell.detailTextLabel.backgroundColor = [sheet fontBackgroundColor];
//    cell.detailTextLabel.textColor = [sheet fontTextColor];
//    cell.detailTextLabel.font = [sheet makeFont];
//
//    
//    
//    
//    NSString* albumKey = [self.sortedAlbums objectAtIndex:indexPath.row];
//    cell.textLabel.text = albumKey;
//
//     NSArray* songs = [self.catalog.selectedArtistRepo objectForKey:albumKey];
//
//    NSInteger nbSongs = songs.count;
//    
//    if (nbSongs == 1)
//        cell.detailTextLabel.text = NSLocalizedString(@"Programming.nbSongs.1", nil);
//    else
//        cell.detailTextLabel.text = NSLocalizedString(@"Programming.nbSongs.n", nil);
//    
//    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbSongs]];    
//
//    id firstSong = [songs objectAtIndex:0];
//    if ([firstSong isKindOfClass:[SongLocal class]])
//    {
//        SongLocal* songLocal = (SongLocal*)firstSong;
//        
//        NSInteger imageSize = 44;
//        cell.imageView.image = [songLocal.artwork imageWithSize:CGSizeMake(imageSize,imageSize)];
//    }
//        
//    
//    return cell;
//}
//







- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
//    ProgrammingCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray* albums = nil;
    NSString* album = nil;
    NSArray* songs = nil;
    NSInteger nbSongs = 0;
    
    // sort with a selected genre
    if (self.catalog.selectedGenre) {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
        album = [albums objectAtIndex:indexPath.row];
        songs = [self.catalog songsForAlbum:album fromArtist:self.catalog.selectedArtist  withGenre:self.catalog.selectedGenre];
        nbSongs = songs.count;
    }

    // sort with a selected playlist
    else if (self.catalog.selectedPlaylist) {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist  withPlaylist:self.catalog.selectedPlaylist];
        album = [albums objectAtIndex:indexPath.row];
        songs = [self.catalog songsForAlbum:album fromArtist:self.catalog.selectedArtist  withPlaylist:self.catalog.selectedPlaylist];
        nbSongs = songs.count;
    }
    
    // no sort
    else {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist];
        album = [albums objectAtIndex:indexPath.row];
        songs = [self.catalog songsForAlbum:album fromArtist:self.catalog.selectedArtist];
        nbSongs = songs.count;
    }
    
    NSString* subtitle;
    if (nbSongs == 1)
        subtitle = NSLocalizedString(@"Programming.nbSongs.1", nil);
    else
        subtitle = NSLocalizedString(@"Programming.nbSongs.n", nil);
    
    subtitle = [subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbSongs]];
    
    id firstSong = [songs objectAtIndex:0];
    UIImage* customImage = nil;
    if ([firstSong isKindOfClass:[SongLocal class]])
    {
        SongLocal* songLocal = (SongLocal*)firstSong;
        
        NSInteger imageSize = 30;
        customImage = [songLocal.artwork imageWithSize:CGSizeMake(imageSize,imageSize)];
        if (customImage == nil)
        {
            BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy30" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            customImage = [sheet image];
        }
    }
    
    // else customImage will be replaced by refSong's image

    
//    if (cell == nil)
//    {
//        cell = [[[ProgrammingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier text:albumKey detailText:detailText customImage:customImage refSong:firstSong] autorelease];
//    }
//    else
//        [cell updateWithText:albumKey detailText:detailText customImage:customImage refSong:firstSong];

    ActionCollectionCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[ActionCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier album:album subtitle:subtitle forRadio:self.radio usingCatalog:self.catalog] autorelease];
    }
    else
        [cell updateAlbum:album subtitle:subtitle];

    
    
    
    
    
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    NSArray* albums = nil;
    
    if (self.catalog.selectedGenre) {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
    }
    
    // sort with a selected playlist
    else if (self.catalog.selectedPlaylist) {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist  withPlaylist:self.catalog.selectedPlaylist];
    }
    
    // no sort
    else {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist];
    }

    
    NSString* albumKey = [albums objectAtIndex:indexPath.row];

    [self.catalog selectAlbum:albumKey];
    
    self.albumVC = [[ProgrammingAlbumViewController alloc] initWithStyle:UITableViewStylePlain usingCatalog:self.catalog forRadio:self.radio];
    CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
    self.albumVC.tableView.frame = frame;
    [self.view.superview addSubview:self.albumVC.tableView];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.33];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    frame = CGRectMake(0,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
    self.albumVC.tableView.frame = frame;
    [UIView commitAnimations];

    
    //    [viewc release];
}














//
//
//#pragma mark - IBActions
//
//
//
//- (IBAction)onSynchronize:(id)semder
//{
//    ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
//}
//

//- (IBAction)onAdd:(id)sender
//{
//    ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithNibName:@"ProgrammingLocalViewController" bundle:nil withMatchedSongs:[SongCatalog synchronizedCatalog].matchedSongs];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
//}


- (void)onNotifSongAdded:(NSNotification*)notif
{
//    //[self.sortedAlbums release];
//    self.sortedAlbums = nil;
//    //LBDEBUG
////    NSArray* array = [self.catalog.selectedArtistRepo allKeys];
//    NSArray* array = nil;
//    self.sortedAlbums = [array sortedArrayUsingSelector:@selector(compare:)];
//    
//    [self.tableView reloadData];
}




- (BOOL)onBackClicked
{
    if (self.albumVC)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
        CGRect frame = CGRectMake(self.view.frame.size.width,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.albumVC.tableView.frame = frame;
        [UIView commitAnimations];
        
        return NO;
    }
    
    return YES;

}

- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.albumVC.tableView removeFromSuperview];
    [self.albumVC release];
    self.albumVC = nil;
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
//        ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithNibName:@"ProgrammingLocalViewController" bundle:nil forRadio:self.radio];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//    else if (itemIndex == WHEEL_ITEM_RADIO)
//    {
//        ProgrammingRadioViewController* view = [[ProgrammingRadioViewController alloc] initWithNibName:@"ProgrammingRadioViewController" bundle:nil  forRadio:self.radio];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//    else if (itemIndex == WHEEL_ITEM_UPLOADS)
//    {
//        ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//}



@end
