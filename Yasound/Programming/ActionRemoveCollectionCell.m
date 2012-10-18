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

    // button "del from programming"
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.del" retainStylesheet:YES overwriteStylesheet:NO error:nil];
    self.button = [sheet makeButton];
    [self.button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];

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
        
    if (self.mode == eArtistRemove)
        [self artistRemoveClicked];
    else if (self.mode == eAlbumRemove)
        [self albumRemoveClicked];
}







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
    
    [[SongRadioCatalog main] updateSongRemovedFromProgramming:song];
    [[SongLocalCatalog main] updateSongRemovedFromProgramming:song];
}





@end
