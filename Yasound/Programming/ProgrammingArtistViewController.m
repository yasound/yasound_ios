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
#import "RootViewController.h"
#import "AudioStreamManager.h"
#import "SongLocal.h"
#import "ProgrammingCell.h"
//#import "ProgrammingLocalViewController.h"
//#import "ProgrammingRadioViewController.h"

@implementation ProgrammingArtistViewController


@synthesize radio;
@synthesize catalog;
@synthesize sortedAlbums;
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
//        cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_songs_1", nil);
//    else
//        cell.detailTextLabel.text = NSLocalizedString(@"ProgramminView_nb_songs_n", nil);
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
    
    ProgrammingCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString* albumKey = [self.sortedAlbums objectAtIndex:indexPath.row];
    
    NSArray* songs = [self.catalog.selectedArtistRepo objectForKey:albumKey];
    
    NSInteger nbSongs = songs.count;
    
    NSString* detailText;
    if (nbSongs == 1)
        detailText = NSLocalizedString(@"ProgramminView_nb_songs_1", nil);
    else
        detailText = NSLocalizedString(@"ProgramminView_nb_songs_n", nil);
    
    detailText = [detailText stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbSongs]];
    
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

    
    if (cell == nil)
    {
        cell = [[[ProgrammingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier text:albumKey detailText:detailText customImage:customImage refSong:firstSong] autorelease];
    }
    else
        [cell updateWithText:albumKey detailText:detailText customImage:customImage refSong:firstSong];
    
    
    
    
    
    
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    
    NSString* albumKey = [self.sortedAlbums objectAtIndex:indexPath.row];
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
    //[self.sortedAlbums release];
    self.sortedAlbums = nil;
    NSArray* array = [self.catalog.selectedArtistRepo allKeys];
    self.sortedAlbums = [array sortedArrayUsingSelector:@selector(compare:)];
    
    [self.tableView reloadData];
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
