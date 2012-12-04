//
//  ProgrammingArtistViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 22/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ProgrammingArtistViewController.h"
#import "ActivityAlertView.h"
#import "YaRadio.h"
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
#import "ActionAddCollectionCell.h"
#import "ActionRemoveCollectionCell.h"

@implementation ProgrammingArtistViewController


@synthesize radio;
@synthesize catalog;
@synthesize albumVC;

- (id)initWithStyle:(UITableViewStyle)style  usingCatalog:(SongCatalog*)catalog forRadio:(YaRadio*)radio
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
    
    if (self.catalog == [SongLocalCatalog main])
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAdded:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
    
    if (self.catalog == [SongRadioCatalog main])
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongDeleted:) name:NOTIF_PROGAMMING_SONG_REMOVED object:nil];
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






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    NSArray* albums = nil;
    NSString* album = nil;
    NSArray* songs = nil;
    NSInteger nbSongs = 0;
    
    // sort with a selected genre
    if (self.catalog.selectedGenre) {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
        
        //LBDEBUG
        assert(albums.count > indexPath.row);
               
        album = [albums objectAtIndex:indexPath.row];
        songs = [self.catalog songsForAlbum:album fromArtist:self.catalog.selectedArtist  withGenre:self.catalog.selectedGenre];
        nbSongs = songs.count;
        
        //LBDEBUG ICI
        assert(nbSongs != 0);
        
    }

    // sort with a selected playlist
    else if (self.catalog.selectedPlaylist) {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist  withPlaylist:self.catalog.selectedPlaylist];
        
        //LBDEBUG
        assert(albums.count > indexPath.row);
        
        album = [albums objectAtIndex:indexPath.row];
        songs = [self.catalog songsForAlbum:album fromArtist:self.catalog.selectedArtist  withPlaylist:self.catalog.selectedPlaylist];
        nbSongs = songs.count;

        //LBDEBUG ICI
        assert(nbSongs != 0);

    }
    
    // no sort
    else {
        albums = [self.catalog albumsForArtist:self.catalog.selectedArtist];
        
        //LBDEBUG
        assert(albums.count > indexPath.row);
        
        album = [albums objectAtIndex:indexPath.row];
        songs = [self.catalog songsForAlbum:album fromArtist:self.catalog.selectedArtist];
        nbSongs = songs.count;

        //LBDEBUG ICI
        assert(nbSongs != 0);
    }
    
    
    NSString* subtitle;
    if (nbSongs == 1)
        subtitle = NSLocalizedString(@"Programming.nbSongs.1", nil);
    else
        subtitle = NSLocalizedString(@"Programming.nbSongs.n", nil);
    
    subtitle = [subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbSongs]];
    
    //LBDEBUG
    assert(songs.count > 0);

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
    
    if (self.catalog == [SongLocalCatalog main]) {

        ActionAddCollectionCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[ActionAddCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier album:album subtitle:subtitle forRadio:self.radio usingCatalog:self.catalog] autorelease];
        }
        else
            [cell updateAlbum:album subtitle:subtitle];
        
        return cell;
    }


    if (self.catalog == [SongRadioCatalog main]) {
        
        ActionRemoveCollectionCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[ActionRemoveCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier album:album subtitle:subtitle forRadio:self.radio usingCatalog:self.catalog] autorelease];
        }
        else
            [cell updateAlbum:album subtitle:subtitle];
        
        return cell;
    }
    
    
    
    
    
    return nil;
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

    //LBDEBUG
    assert(albums.count > indexPath.row);
    
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
}









- (void)onNotifSongAdded:(NSNotification*)notif
{
    [self.tableView reloadData];
}


- (void)onNotifSongDeleted:(NSNotification*)notif
{
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



@end
