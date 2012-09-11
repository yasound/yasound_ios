//
//  CollectionAddCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "CollectionAddCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongUploadManager.h"
#import "SongCatalog.h"
#import "ActivityAlertView.h"
#import "YasoundReachability.h"
#import "SongLocalCatalog.h"
#import "SongRadioCatalog.h"


@implementation CollectionAddCell

@synthesize mode;
@synthesize radio;
@synthesize collection;
@synthesize label;
@synthesize detailedLabel;
@synthesize button;
@synthesize songsToUpload;

//
//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//    if(!newSuperview)
//    {
//        if (self.image)
//            [self.image releaseCache];
//    }
//}
//




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
    
    BOOL areAllDisabled = YES;
    
    NSArray* songs = [[SongLocalCatalog main] songsForGenre:self.collection];
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


- (void)updatePlaylist:(NSString*)playlist subtitle:(NSString*)subtitle
{
    self.mode = ePlaylistAdd;
    self.collection = playlist;
    
    self.label.text = playlist;
    self.detailedLabel.text = subtitle;
    
    BOOL areAllDisabled = YES;
    
    NSArray* songs = [[SongLocalCatalog main] songsForPlaylist:self.collection];
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



- (void)updateArtist:(NSString*)artist subtitle:(NSString*)subtitle
{
    self.mode = eArtistAdd;
    self.collection = artist;
    
    self.label.text = artist;
    self.detailedLabel.text = subtitle;
    
    BOOL areAllDisabled = YES;
    
    NSArray* songs = nil;
    
    if (self.catalog.selectedGenre)
        songs = [[SongLocalCatalog main] songsForArtist:self.collection withGenre:self.catalog.selectedGenre];
    else if (self.catalog.selectedPlaylist)
        songs = [[SongLocalCatalog main] songsForArtist:self.collection withPlaylist:self.catalog.selectedPlaylist];
    else
        songs = [[SongLocalCatalog main] songsForArtist:self.collection];
    
    
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
    
    if (self.mode == eGenreAdd)
        [self genreAddClicked];
    else if (self.mode == ePlaylistAdd)
        [self playlistAddClicked];
}


- (void)genreAddClicked {
 
    NSInteger nbProgrammed = 0;
    NSInteger nbCantProgram = 0;
    
    NSArray* songs = [[SongLocalCatalog main] songsForGenre:self.collection];
    for (NSString* songKey in songs) {
        
        Song* song = [[SongLocalCatalog main].songsDb objectForKey:songKey];
        assert(song);
        
        // don't upload if the song is programmed already
        if (song.isProgrammed) {
            nbProgrammed++;
            continue;
        }
        
        // can it be upload?
        BOOL can = [[SongUploader main] canUploadSong:song];
        if (!can) {
            nbCantProgram++;
            continue;
        }
        
        // ok, add it to the group of songs to upload
        [self.songsToUpload addObject:song];
    }

    
    if (self.songsToUpload.count == 0) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.collection.add.title", nil) message:NSLocalizedString(@"Programming.collection.add.message.empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    // ask confirm
    NSString* message = NSLocalizedString(@"Programming.collection.add.message", nil);
    message = [NSString stringWithFormat:message, nbProgrammed, self.songsToUpload.count, songs.count];
    _addedGenreUpload = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.collection.add.title", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.cancel", nil) otherButtonTitles:NSLocalizedString(@"Navigation.ok", nil), nil];
        [_addedGenreUpload show];
        [_addedGenreUpload release];
    
}









- (void)playlistAddClicked {
 
    NSInteger nbProgrammed = 0;
    NSInteger nbCantProgram = 0;
    
    NSArray* songs = [[SongLocalCatalog main] songsForPlaylist:self.collection];
    for (NSString* songKey in songs) {
        
        Song* song = [[SongLocalCatalog main].songsDb objectForKey:songKey];
        assert(song);
        
        // don't upload if the song is programmed already
        if (song.isProgrammed) {
            nbProgrammed++;
            continue;
        }
        
        // can it be upload?
        BOOL can = [[SongUploader main] canUploadSong:song];
        if (!can) {
            nbCantProgram++;
            continue;
        }
        
        // ok, add it to the group of songs to upload
        [self.songsToUpload addObject:song];
    }
    
    
    if (self.songsToUpload.count == 0) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.collection.add.title", nil) message:NSLocalizedString(@"Programming.collection.add.message.empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    // ask confirm
    NSString* message = NSLocalizedString(@"Programming.collection.add.message", nil);
    message = [NSString stringWithFormat:message, nbProgrammed, self.songsToUpload.count, songs.count];
    _addedPlaylistUpload = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.collection.add.title", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.cancel", nil) otherButtonTitles:NSLocalizedString(@"Navigation.ok", nil), nil];
    [_addedPlaylistUpload show];
    [_addedPlaylistUpload release];

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
