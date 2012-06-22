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
#import "SongUploadViewController.h"
#import "SongAddViewController.h"
#import "TimeProfile.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongCatalog.h"
#import "ProgrammingAlbumViewController.h"
#import "RootViewController.h"
#import "AudioStreamManager.h"
#import "SongLocal.h"


@implementation ProgrammingArtistViewController



@synthesize catalog;
@synthesize sortedAlbums;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil usingCatalog:(SongCatalog*)catalog
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
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
    

    if (self.catalog == [SongCatalog synchronizedCatalog])
        _titleLabel.text = NSLocalizedString(@"ProgrammingView_title", nil);
    else if (self.catalog == [SongCatalog availableCatalog])
        _titleLabel.text = NSLocalizedString(@"SongAddView_title", nil);

    _subtitleLabel.text = self.catalog.selectedArtist;
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    _nowPlayingButton.title = NSLocalizedString(@"Navigation_NowPlaying", nil);

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([AudioStreamManager main].currentRadio == nil)
        [_nowPlayingButton setEnabled:NO];
    else
        [_nowPlayingButton setEnabled:YES];
    
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

    ProgrammingAlbumViewController* view = [[ProgrammingAlbumViewController alloc] initWithNibName:@"ProgrammingAlbumViewController" bundle:nil usingCatalog:self.catalog];
    [self.navigationController pushViewController:view animated:YES];
    [view release];

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
    SongAddViewController* view = [[SongAddViewController alloc] initWithNibName:@"SongAddViewController" bundle:nil withMatchedSongs:[SongCatalog synchronizedCatalog].matchedSongs];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


- (void)onNotifSongAdded:(NSNotification*)notif
{
    //[self.sortedAlbums release];
    self.sortedAlbums = nil;
    NSArray* array = [self.catalog.selectedArtistRepo allKeys];
    self.sortedAlbums = [array sortedArrayUsingSelector:@selector(compare:)];
    
    [_tableView reloadData];    
}




@end
