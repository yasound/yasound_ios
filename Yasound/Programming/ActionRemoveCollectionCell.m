//
//  ActionRemoveCollectionCell.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ActionRemoveCollectionCell.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "SongUploadManager.h"
#import "SongCatalog.h"
#import "ActivityAlertView.h"
#import "YasoundReachability.h"
//#import "SongLocalCatalog.h"
#import "SongRadioCatalog.h"
#import "SongLocalCatalog.h"



@implementation ActionRemoveCollectionCell

@synthesize mode;
@synthesize radio;
@synthesize collection;
@synthesize label;
@synthesize detailedLabel;
@synthesize button;
@synthesize songsToRemove;

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


//
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier genre:(NSString*)genre subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog {
//
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    
//    if (self)
//    {
//        self.mode = eGenreAdd;
//        self.radio = radio;
//        self.catalog = catalog;
//        self.collection = genre;
//        
//        [self commonInit];
//        [self updateGenre:genre subtitle:subtitle];
//    }
//    return self;
//}

//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier playlist:(NSString*)playlist subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog {
//    
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    
//    if (self)
//    {
//        self.mode = ePlaylistAdd;
//        self.radio = radio;
//        self.catalog = catalog;
//        self.collection = playlist;
//        
//        [self commonInit];
//        [self updatePlaylist:playlist subtitle:subtitle];
//    }
//    return self;
//}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier artist:(NSString*)artist subtitle:(NSString*)subtitle forRadio:(Radio*)radio usingCatalog:(SongCatalog*)catalog {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.mode = eArtistRemove;
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
        self.mode = eAlbumRemove;
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
        
    
    
        // button "del from programming"
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.del" retainStylesheet:YES overwriteStylesheet:NO error:nil];
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


//- (void)updateGenre:(NSString*)genre subtitle:(NSString*)subtitle
//{
//    self.mode = eGenreAdd;
//    self.collection = genre;
//    
//    self.label.text = genre;
//    self.detailedLabel.text = subtitle;
//    
//    NSArray* songs = [self.catalog songsForGenre:self.collection];
//    
//    [self updateItemsWithSongs:songs];
//}
//
//
//- (void)updatePlaylist:(NSString*)playlist subtitle:(NSString*)subtitle
//{
//    self.mode = ePlaylistAdd;
//    self.collection = playlist;
//    
//    self.label.text = playlist;
//    self.detailedLabel.text = subtitle;
//    
//    NSArray* songs = [self.catalog songsForPlaylist:self.collection];
//    
//    [self updateItemsWithSongs:songs];
//}
//


- (void)updateArtist:(NSString*)artist subtitle:(NSString*)subtitle
{
    self.mode = eArtistRemove;
    self.collection = artist;
    
    self.label.text = artist;
    self.detailedLabel.text = subtitle;
    
    
    NSArray* songs = nil;
    
    if (self.catalog.selectedGenre)
        songs = [self.catalog songsForArtist:self.collection withGenre:self.catalog.selectedGenre];
    else if (self.catalog.selectedPlaylist)
        songs = [self.catalog songsForArtist:self.collection withPlaylist:self.catalog.selectedPlaylist];
    else
        songs = [self.catalog songsForArtist:self.collection];
 
    [self updateItemsWithSongs:songs];
}


- (void)updateAlbum:(NSString*)album subtitle:(NSString*)subtitle
{
    self.mode = eAlbumRemove;
    self.collection = album;
    
    self.label.text = album;
    self.detailedLabel.text = subtitle;
    
    
    NSArray* songs = nil;
    
    if (self.catalog.selectedGenre)
        songs = [self.catalog songsForAlbum:self.collection fromArtist:(NSString*)self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
    else if (self.catalog.selectedPlaylist)
        songs = [self.catalog songsForAlbum:self.collection  fromArtist:(NSString*)self.catalog.selectedArtist withPlaylist:self.catalog.selectedPlaylist];
    else
        songs = [self.catalog songsForAlbum:self.collection fromArtist:(NSString*)self.catalog.selectedArtist];
    
    [self updateItemsWithSongs:songs];
}



- (void)updateItemsWithSongs:(NSArray*)songs {

    BOOL atLeastOneEnabled = NO;

    for (NSString* songKey in songs) {
        
        Song* song = [self.catalog.songsDb objectForKey:songKey];
        assert(song);
        assert([song isKindOfClass:[Song class]]);
        
        atLeastOneEnabled |= [song isSongEnabled];
    }
    
    if (atLeastOneEnabled) {
        
        self.button.enabled = YES;
        self.label.alpha = 1;
        self.detailedLabel.alpha = 1;
    } else {
        self.button.enabled = NO;
        self.label.alpha = 0.5;
        self.detailedLabel.alpha = 0.5;
    }
}











- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)onButtonClicked:(id)sender
{
    self.songsToRemove = nil;
    self.songsToRemove = [NSMutableArray array];
    
//    if (self.mode == eGenreAdd)
//        [self genreAddClicked];
//    else if (self.mode == ePlaylistAdd)
//        [self playlistAddClicked];
//    else
        
    if (self.mode == eArtistRemove)
        [self artistRemoveClicked];
    else if (self.mode == eAlbumRemove)
        [self albumRemoveClicked];
}


//- (void)genreAddClicked {
// 
//    NSInteger nbProgrammed = 0;
//    NSInteger nbCantProgram = 0;
//    
//    NSArray* songs = [self.catalog songsForGenre:self.collection];
//    for (NSString* songKey in songs) {
//        
//        Song* song = [self.catalog.songsDb objectForKey:songKey];
//        assert(song);
//        
//        // don't upload if the song is programmed already
//        if (song.isProgrammed) {
//            nbProgrammed++;
//            continue;
//        }
//        
//        // can it be upload?
//        BOOL can = [[SongUploader main] canUploadSong:song];
//        if (!can) {
//            nbCantProgram++;
//            continue;
//        }
//        
//        // ok, add it to the group of songs to upload
//        [self.songsToUpload addObject:song];
//    }
//
//    
//    [self requestUploadsFrom:songs nbProgrammed:nbProgrammed];
//    
//}









//- (void)playlistAddClicked {
// 
//    NSInteger nbProgrammed = 0;
//    NSInteger nbCantProgram = 0;
//    
//    NSArray* songs = [self.catalog songsForPlaylist:self.collection];
//    for (NSString* songKey in songs) {
//        
//        Song* song = [self.catalog.songsDb objectForKey:songKey];
//        assert(song);
//        
//        // don't upload if the song is programmed already
//        if (song.isProgrammed) {
//            nbProgrammed++;
//            continue;
//        }
//        
//        // can it be upload?
//        BOOL can = [[SongUploader main] canUploadSong:song];
//        if (!can) {
//            nbCantProgram++;
//            continue;
//        }
//        
//        // ok, add it to the group of songs to upload
//        [self.songsToUpload addObject:song];
//    }
//    
//    
//    [self requestUploadsFrom:songs nbProgrammed:nbProgrammed];
//
//}
//









- (void)artistRemoveClicked {
    
    NSArray* songs;
    
    if (self.catalog.selectedGenre)
        songs = [self.catalog songsForArtist:self.collection withGenre:self.catalog.selectedGenre];
    else if (self.catalog.selectedPlaylist)
        songs = [self.catalog songsForArtist:self.collection withPlaylist:self.catalog.selectedPlaylist];
    else
        songs = [self.catalog songsForArtist:self.collection];

    for (NSString* songKey in songs) {
        
        Song* song = [self.catalog.songsDb objectForKey:songKey];
        assert(song);
        
        // ok, add it to the group of songs to remove
        [self.songsToRemove addObject:song];
    }
    
    [self requestRemoveFrom:songs];
}







- (void)albumRemoveClicked {
    
    NSArray* songs;
    
    if (self.catalog.selectedGenre)
        songs = [self.catalog songsForAlbum:self.collection fromArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedGenre];
    else if (self.catalog.selectedPlaylist)
        songs = [self.catalog songsForAlbum:self.collection fromArtist:self.catalog.selectedArtist withGenre:self.catalog.selectedPlaylist];
    else
        songs = [self.catalog songsForAlbum:self.collection fromArtist:self.catalog.selectedArtist];
    
    for (NSString* songKey in songs) {
        
        Song* song = [self.catalog.songsDb objectForKey:songKey];
        assert(song);
        
        // ok, add it to the group of songs to remove
        [self.songsToRemove addObject:song];
    }
    
    [self requestRemoveFrom:songs];
}








- (void)requestRemoveFrom:(NSArray*)songs {
    
//    "Programming.collection.add.message.programmed.1" = "1 song is in your radio already.";
//    "Programming.collection.add.message.programmed.n" = "%d songs are in your radio already.";
//    "Programming.collection.add.message.toUpload.1" = "1 of %d songs may be uploaded to your radio.\nWould you like to upload it?";
//    "Programming.collection.add.message.toUpload.n" = "%d of %d songs may be uploaded to your radio.\nWould you like to upload them?";

    if (self.songsToRemove.count == 0) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.collection.del.title", nil) message:NSLocalizedString(@"Programming.collection.del.message.empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Navigation.ok", nil) otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    // ask confirm
    NSString* message = nil;
    
    if (self.songsToRemove.count == 1) {
        message = NSLocalizedString(@"Programming.collection.del.message.toRemove.1", nil);
        message = [NSString stringWithFormat:message, songs.count];
    }
    else {
        message = NSLocalizedString(@"Programming.collection.del.message.toRemove.n", nil);
        message = [NSString stringWithFormat:message, self.songsToRemove.count, songs.count];
    }

    message = [NSString stringWithFormat:message, self.songsToRemove.count, songs.count];
    _alertRemove = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Programming.collection.del.title", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation.cancel", nil) otherButtonTitles:NSLocalizedString(@"Navigation.ok", nil), nil];
    [_alertRemove show];
    [_alertRemove release];
    
}












#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView == _alertRemove) && (buttonIndex == 1))
    {
        for (Song* song in self.songsToRemove) {
            
            [[YasoundDataProvider main] deleteSong:song target:self action:@selector(onSongDeleted:info:) userData:nil];
            
            // refresh gui
            [self updateArtist:self.collection subtitle:self.detailedLabel.text];
        }
        
        return;
    }

}





// server's callback
- (void)onSongDeleted:(Song*)song info:(NSDictionary*)info
{
    DLog(@"onSongDeleted for Song %@", song.name);
    DLog(@"info %@", info);
    
    BOOL success = NO;
    NSNumber* nbsuccess = [info objectForKey:@"success"];
    if (nbsuccess != nil)
        success = [nbsuccess boolValue];
    
    DLog(@"success %d", success);
    
    if (!success) {
        return;
    }
    
    //    UITableViewCell* cell = [info objectForKey:@"userData"];
    //    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    [[SongRadioCatalog main] updateSongRemovedFromProgramming:song];
    [[SongLocalCatalog main] updateSongRemovedFromProgramming:song];
    
    //    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}





@end
