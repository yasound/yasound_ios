//
//  ActionAddCollectionCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ActionAddCollectionCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongUploadManager.h"
#import "SongCatalog.h"
#import "ActivityAlertView.h"
#import "YasoundReachability.h"
#import "SongLocalCatalog.h"
#import "SongRadioCatalog.h"
#import "DataBase.h"


@implementation ActionAddCollectionCell

@synthesize mode;
@synthesize radio;
@synthesize collection;
@synthesize label;
@synthesize detailedLabel;
@synthesize button;
@synthesize songsToUpload;
@synthesize nbSongsProgrammed;
@synthesize nbSongsCantUpload;
@synthesize nbSongsSelected;


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if(!newSuperview)
    {
        if (_thread) {
            [_thread cancel];
            _thread = nil;
        }
    }
}





- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier genre:(NSString*)genre subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.mode = eGenreAdd;
        self.radio = radio;
        self.catalog = catalog;
        self.collection = genre;
        
        [self commonInit];
        [self updateGenre:genre subtitle:subtitle];
    }
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier playlist:(NSString*)playlist subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.mode = ePlaylistAdd;
        self.radio = radio;
        self.catalog = catalog;
        self.collection = playlist;
        
        [self commonInit];
        [self updatePlaylist:playlist subtitle:subtitle];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier artist:(NSString*)artist subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.mode = eArtistAdd;
        self.radio = radio;
        self.catalog = catalog;
        self.collection = artist;
        
        [self commonInit];
        [self updateArtist:artist subtitle:subtitle];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier album:(NSString*)album subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.mode = eAlbumAdd;
        self.radio = radio;
        self.catalog = catalog;
        self.collection = album;
        
        [self commonInit];
        [self updateAlbum:album subtitle:subtitle];
    }
    return self;
}







- (void)commonInit {

        self.selectionStyle = UITableViewCellSelectionStyleGray;
//    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    
    
        // button "add to upload list"
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.add" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.button = [sheet makeButton];
        [self.button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
//    CGFloat offset = self.button.frame.origin.x + self.button.frame.size.width;
    CGFloat offset = 0;
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.textLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.label = [sheet makeLabel];
        self.label.frame = [self updateToRect:sheet.frame withOffset:offset withInset:(offset + 16)];
        [self addSubview:self.label];
        
        
        sheet = [[Theme theme] stylesheetForKey:@"TableView.detailTextLabel" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        self.detailedLabel = [sheet makeLabel];
        self.detailedLabel.frame = [self updateToRect:sheet.frame withOffset:offset withInset:(offset + 16)];
        [self addSubview:self.detailedLabel];
        
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    sheet = [[Theme theme] stylesheetForKey:@"TableView.disclosureIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    UIImageView* di = [sheet makeImage];
    self.accessoryView = di;
    [di release];

        
//        if ([song isProgrammed] || ([[SongUploadManager main] getUploadingSong:song.name artist:song.artist album:song.album forRadio:self.radio] != nil))
//        {
//            self.button.enabled = NO;
//            self.image.alpha = 0.5;
//            self.label.alpha = 0.5;
//            self.detailedLabel.alpha = 0.5;
//        }

}



                      
- (CGRect)rect:(CGRect)frame withOffset:(CGFloat)offset 
{
    CGRect newframe = CGRectMake(frame.origin.x + offset, frame.origin.y, frame.size.width, frame.size.height);
    return newframe;
}

- (CGRect)updateToRect:(CGRect)frame withOffset:(CGFloat)offset withInset:(CGFloat)inset
{
    CGRect newframe = CGRectMake(frame.origin.x + offset, frame.origin.y, frame.size.width - inset, frame.size.height);
    return newframe;
}

//
//- (void)willMoveToSuperview:(UIView *)newSuperview 
//{
//    [super willMoveToSuperview:newSuperview];
//    if(!newSuperview) 
//    {
//        self.item.delegate = nil;
//    }
//}


- (void)updateGenre:(NSString*)genre subtitle:(NSString*)subtitle
{
    self.mode = eGenreAdd;
    self.collection = genre;
    
    self.label.text = genre;
    self.detailedLabel.text = subtitle;
    
    NSArray* songs = [[SongLocalCatalog main] songsForGenre:self.collection];
    
    [self updateItemsWithSongs:songs];
}


- (void)updatePlaylist:(NSString*)playlist subtitle:(NSString*)subtitle
{
    self.mode = ePlaylistAdd;
    self.collection = playlist;
    
    self.label.text = playlist;
    self.detailedLabel.text = subtitle;
    
    NSArray* songs = [[SongLocalCatalog main] songsForPlaylist:self.collection];
    
    [self updateItemsWithSongs:songs];
}



- (void)updateArtist:(NSString*)artist subtitle:(NSString*)subtitle
{
    self.mode = eArtistAdd;
    self.collection = artist;
    
    self.label.text = artist;
    
    NSArray* songs = nil;
    
    if (self.catalog.selectedGenre)
        songs = [[SongLocalCatalog main] songsForArtist:self.collection withGenre:self.catalog.selectedGenre];
    else if (self.catalog.selectedPlaylist)
        songs = [[SongLocalCatalog main] songsForArtist:self.collection withPlaylist:self.catalog.selectedPlaylist];
    else
        songs = [[SongLocalCatalog main] songsForArtist:self.collection];
 
    [self updateItemsWithSongs:songs];

    if (subtitle != nil)
        self.detailedLabel.text = subtitle;
    else {
        self.detailedLabel.text = @"-";
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadGetInfo) object:nil];
        [_thread start];
    }
}


- (void)threadGetInfo {
    
    NSInteger nbItems = 0;

    if (self.catalog.selectedGenre)
        nbItems = [[SongLocalCatalog main] albumsForArtist:self.collection withGenre:self.catalog.selectedGenre fromTable:LOCALCATALOG_TABLE].count;
    else if (self.catalog.selectedPlaylist)
        nbItems = [[SongLocalCatalog main] albumsForArtist:self.collection withPlaylist:self.catalog.selectedPlaylist fromTable:LOCALCATALOG_TABLE].count;
    else
        nbItems = [[SongLocalCatalog main] albumsForArtist:self.collection].count;
    
    if (nbItems == 1)
        self.subtitle = NSLocalizedString(@"Programming.nbAlbums.1", nil);
    else
        self.subtitle = NSLocalizedString(@"Programming.nbAlbums.n", nil);
    
    self.subtitle = [self.subtitle stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", nbItems]];
    
    [self performSelectorOnMainThread:@selector(gotInfo) withObject:nil waitUntilDone:NO];
}

- (void)gotInfo {
    
    _thread = nil;
    
    
    self.detailedLabel.text = self.subtitle;

}


- (void)updateAlbum:(NSString*)album subtitle:(NSString*)subtitle
{
    self.mode = eAlbumAdd;
    self.collection = album;
    
    self.label.text = album;
    self.detailedLabel.text = subtitle;
    
    
    NSArray* songs = nil;
    
    if (self.catalog.selectedGenre)
        songs = [[SongLocalCatalog main] songsForAlbum:self.collection fromArtist:(NSString*)self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
    else if (self.catalog.selectedPlaylist)
        songs = [[SongLocalCatalog main] songsForAlbum:self.collection  fromArtist:(NSString*)self.catalog.selectedArtist withPlaylist:self.catalog.selectedPlaylist];
    else
        songs = [[SongLocalCatalog main] songsForAlbum:self.collection fromArtist:(NSString*)self.catalog.selectedArtist];
    
    [self updateItemsWithSongs:songs];
}



- (void)updateItemsWithSongs:(NSArray*)songs {

    BOOL areAllDisabled = YES;

    for (NSString* songKey in songs) {
        
        SongLocal* song = [[SongLocalCatalog main].songsDb objectForKey:songKey];
        assert(song);
        assert([song isKindOfClass:[SongLocal class]]);
        
        Song* matchedSong = [[SongRadioCatalog main].matchedSongs objectForKey:songKey];
        
        // don't upload if the song is programmed already
        BOOL isProgrammed = (matchedSong != nil);
        
        //        BOOL isUploading = [[SongUploadManager main] getUploadingSong:song.name artist:song.artist album:song.album forRadio:self.radio];
        BOOL isUploading = [[SongUploadManager main] getUploadingSong:song.catalogKey forRadio:self.radio];
        
        areAllDisabled &= (isProgrammed || isUploading);
    }
    
    if (areAllDisabled) {
        self.button.enabled = NO;
        self.label.alpha = 0.5;
        self.detailedLabel.alpha = 0.5;
    } else {
        self.button.enabled = YES;
        self.label.alpha = 1;
        self.detailedLabel.alpha = 1;
    }
}











- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)onButtonClicked:(id)sender
{
    self.songsToUpload = nil;
    self.songsToUpload = [NSMutableArray array];
    self.nbSongsProgrammed = 0;
    self.nbSongsCantUpload = 0;
    self.nbSongsSelected = 0;
    
    if (self.mode == eGenreAdd)
        [self genreAddClicked];
    else if (self.mode == ePlaylistAdd)
        [self playlistAddClicked];
    else if (self.mode == eArtistAdd)
        [self artistAddClicked];
    else if (self.mode == eAlbumAdd)
        [self albumAddClicked];
}


- (void)genreAddClicked {
 
    
    NSArray* songs = [[SongLocalCatalog main] songsForGenre:self.collection];
    self.nbSongsSelected = songs.count;
    for (NSString* songKey in songs) {
        
        Song* song = [[SongLocalCatalog main].songsDb objectForKey:songKey];
        assert(song);
        
        // don't upload if the song is programmed already
        if (song.isProgrammed) {
            self.nbSongsProgrammed++;
            continue;
        }
        
        // can it be upload?
        BOOL can = [[SongUploader main] canUploadSong:song];
        if (!can) {
            self.nbSongsCantUpload++;
            continue;
        }
        
        // ok, add it to the group of songs to upload
        [self.songsToUpload addObject:song];
    }

    
    [self requestUploadsFrom:songs];
    
}









- (void)playlistAddClicked {
 
    NSArray* songs = [[SongLocalCatalog main] songsForPlaylist:self.collection];
    self.nbSongsSelected = songs.count;

    for (NSString* songKey in songs) {
        
        Song* song = [[SongLocalCatalog main].songsDb objectForKey:songKey];
        assert(song);
        
        // don't upload if the song is programmed already
        if (song.isProgrammed) {
            self.nbSongsProgrammed++;
            continue;
        }
        
        // can it be upload?
        BOOL can = [[SongUploader main] canUploadSong:song];
        if (!can) {
            self.nbSongsCantUpload++;
            continue;
        }
        
        // ok, add it to the group of songs to upload
        [self.songsToUpload addObject:song];
    }
    
    
    [self requestUploadsFrom:songs];

}










- (void)artistAddClicked {
    
    NSArray* songs;
    
    if (self.catalog.selectedGenre)
        songs = [[SongLocalCatalog main] songsForArtist:self.collection withGenre:self.catalog.selectedGenre];
    else if (self.catalog.selectedPlaylist)
        songs = [[SongLocalCatalog main] songsForArtist:self.collection withPlaylist:self.catalog.selectedPlaylist];
    else
        songs = [[SongLocalCatalog main] songsForArtist:self.collection];

    self.nbSongsSelected = songs.count;

    for (NSString* songKey in songs) {
        
        Song* song = [[SongLocalCatalog main].songsDb objectForKey:songKey];
        assert(song);
        
        // don't upload if the song is programmed already
        if (song.isProgrammed) {
            self.nbSongsProgrammed++;
            continue;
        }
        
        // can it be upload?
        BOOL can = [[SongUploader main] canUploadSong:song];
        if (!can) {
            self.nbSongsCantUpload++;
            continue;
        }
        
        // ok, add it to the group of songs to upload
        [self.songsToUpload addObject:song];
    }
    
    [self requestUploadsFrom:songs];
}







- (void)albumAddClicked {
    
    NSArray* songs;
    
    if (self.catalog.selectedGenre)
        songs = [self.catalog songsForAlbum:self.collection fromArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
    else if (self.catalog.selectedPlaylist)
        songs = [self.catalog songsForAlbum:self.collection fromArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedPlaylist];
    else
        songs = [self.catalog songsForAlbum:self.collection fromArtist:self.catalog.selectedArtist];
    
    self.nbSongsSelected = songs.count;

    for (NSString* songKey in songs) {
        
        Song* song = [[SongLocalCatalog main].songsDb objectForKey:songKey];
        assert(song);
        
        // don't upload if the song is programmed already
        if (song.isProgrammed) {
            self.nbSongsProgrammed++;
            continue;
        }
        
        // can it be upload?
        BOOL can = [[SongUploader main] canUploadSong:song];
        if (!can) {
            self.nbSongsCantUpload++;
            continue;
        }
        
        // ok, add it to the group of songs to upload
        [self.songsToUpload addObject:song];
    }
    
    [self requestUploadsFrom:songs];
}








- (void)requestUploadsFrom:(NSArray*)songs {
    
    NSString* title = NSLocalizedString(@"Programming.collection.add.title", nil);
    title = [NSString stringWithFormat:title, self.nbSongsSelected];
    
    // ask confirm
    NSString* message = nil;
    NSString* message1 = NSLocalizedString(@"Programming.collection.add.message.readyToUpload", nil);
    message1 = [NSString stringWithFormat:message1, self.songsToUpload.count, self.nbSongsSelected];
    NSString* message2 = NSLocalizedString(@"Programming.collection.add.message.programmed", nil);
    message2 = [NSString stringWithFormat:message2, self.nbSongsProgrammed, self.nbSongsSelected];
    NSString* message3 = NSLocalizedString(@"Programming.collection.add.message.cantUpload", nil);
    message3 = [NSString stringWithFormat:message3, self.nbSongsCantUpload, self.nbSongsSelected];
    NSString* message4 = nil;
    
    if (self.songsToUpload.count == 0) {

        message4 = NSLocalizedString(@"Programming.collection.add.message.empty", nil);
        message = [NSString stringWithFormat:@"%@\n%@\n%@\n\n%@", message1, message2, message3, message4];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }


    if (self.songsToUpload.count == 1) {
        message4 = NSLocalizedString(@"Programming.collection.add.message.toUpload.1", nil);
    }
    else {
        message4 = NSLocalizedString(@"Programming.collection.add.message.toUpload.n", nil);
        message4 = [NSString stringWithFormat:message4, self.songsToUpload.count];
    }

    message = [NSString stringWithFormat:@"%@\n%@\n%@\n\n%@", message1, message2, message3, message4];

    _addedGenreUpload = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.cancel", nil) otherButtonTitles:NSLocalizedString(@"Navigation.ok", nil), nil];
    [_addedGenreUpload show];
    [_addedGenreUpload release];
    
}












#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView == _legalUploadWarning) && (buttonIndex == 1))
    {
        [[UserSettings main] setBool:NO forKey:USKEYuploadLegalWarning];
        [self requestUpload];
        return;
    }

    
    if ((alertView == _addedGenreUpload) && (buttonIndex == 1))
    {
        
        BOOL isWifi = ([YasoundReachability main].networkStatus == ReachableViaWiFi);
        BOOL startUploadNow = isWifi;

        for (SongLocal* song in self.songsToUpload) {
            
            SongUploading* songUploading = [SongUploading new];
            songUploading.songLocal = song;
            songUploading.radio_id = self.radio.id;

           // add an upload job to the queue
            [[SongUploadManager main] addSong:songUploading startUploadNow:startUploadNow];

            // refresh gui
            [self updateGenre:self.collection subtitle:self.detailedLabel.text];
        }
        
        return;
    }


    if ((alertView == _addedPlaylistUpload) && (buttonIndex == 1))
    {
        
        BOOL isWifi = ([YasoundReachability main].networkStatus == ReachableViaWiFi);
        BOOL startUploadNow = isWifi;
        
        for (SongLocal* song in self.songsToUpload) {
            
            SongUploading* songUploading = [SongUploading new];
            songUploading.songLocal = song;
            songUploading.radio_id = self.radio.id;
            
            // add an upload job to the queue
            [[SongUploadManager main] addSong:songUploading startUploadNow:startUploadNow];
            
            // refresh gui
            [self updatePlaylist:self.collection subtitle:self.detailedLabel.text];
        }
        
        return;
    }

}



@end
