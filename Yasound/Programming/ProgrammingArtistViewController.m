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
#import "SongCatalog.h"
#import "ProgrammingAlbumViewController.h"
#import "RootViewController.h"
#import "AudioStreamManager.h"
#import "SongLocal.h"
#import "ProgrammingLocalViewController.h"
#import "ProgrammingRadioViewController.h"

@implementation ProgrammingArtistViewController


@synthesize radio;
@synthesize catalog;
@synthesize sortedAlbums;


- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog forRadio:(Radio*)radio
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.radio = radio;
        self.catalog = catalog;
        
        NSArray* array = [self.catalog.selectedArtistRepo allKeys];
         self.sortedAlbums = [array sortedArrayUsingSelector:@selector(compare:)];
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
    

//    if (self.catalog == [SongCatalog synchronizedCatalog])
//        _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
//    else if (self.catalog == [SongCatalog availableCatalog])
//        _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);
//
//    _subtitleLabel.text = self.catalog.selectedArtist;
//    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
//    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if ([AudioStreamManager main].currentRadio == nil)
//        [_nowPlayingButton setEnabled:NO];
//    else
//        [_nowPlayingButton setEnabled:YES];
    
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
    NSInteger count = self.sortedAlbums.count;
    return count;
}




- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"TableView.cell" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    cell.backgroundView = [sheet makeImage];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    
//    NSArray* albums = [self.catalog.selectedArtistRepo allKeys];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    NSString* albumKey = [self.sortedAlbums objectAtIndex:indexPath.row];
    cell.textLabel.text = albumKey;

     NSArray* songs = [self.catalog.selectedArtistRepo objectForKey:albumKey];

    NSInteger nbSongs = songs.count;
    
    if (nbSongs == 1)
        cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_songs_1", nil);
    else
        cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_songs_n", nil);
    
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbSongs]];    

    id firstSong = [songs objectAtIndex:0];
    if ([firstSong isKindOfClass:[SongLocal class]])
    {
        SongLocal* songLocal = (SongLocal*)firstSong;
        
        NSInteger imageSize = 44;
        cell.imageView.image = [songLocal.artwork imageWithSize:CGSizeMake(imageSize,imageSize)];
    }
        
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    
    NSString* albumKey = [self.sortedAlbums objectAtIndex:indexPath.row];
    [self.catalog selectAlbum:albumKey];

    ProgrammingAlbumViewController* view = [[ProgrammingAlbumViewController alloc] initWithNibName:@"ProgrammingAlbumViewController" bundle:nil usingCatalog:self.catalog forRadio:self.radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];

}
















#pragma mark - IBActions



- (IBAction)onSynchronize:(id)semder
{
    ProgrammingUploadViewController* view = [[ProgrammingUploadViewController alloc] initWithNibName:@"ProgrammingUploadViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


//- (IBAction)onAdd:(id)sender
//{
//    ProgrammingLocalViewController* view = [[ProgrammingLocalViewController alloc] initWithNibName:@"ProgrammingLocalViewController" bundle:nil withMatchedSongs:[SongCatalog synchronizedCatalog].matchedSongs];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
//}


- (void)onNotifSongAdded:(NSNotification*)notif
{
    //[self.sortedAlbums release];
    self.sortedAlbums = nil;
    NSArray* array = [self.catalog.selectedArtistRepo allKeys];
    self.sortedAlbums = [array sortedArrayUsingSelector:@selector(compare:)];
    
    [self reloadData];
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
