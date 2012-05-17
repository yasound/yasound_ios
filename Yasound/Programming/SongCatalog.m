//
//  SongCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "Song.h"
#import "SongLocal.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SongUploadManager.h"

#import "TimeProfile.h"






#define PM_FIELD_UNKNOWN @""


@implementation SongCatalog

@synthesize matchedSongs;
@synthesize nbSongs;

@synthesize alphabeticRepo;
@synthesize indexMap;
@synthesize alphaArtistsRepo;

@synthesize selectedArtist;
@synthesize selectedAlbum;
@synthesize selectedArtistRepo;
@synthesize selectedAlbumRepo;




//...............................................................................................
//
// Singletons
//

static SongCatalog* _synchronizedCatalog; // for the server's synchronized songs
static SongCatalog* _availableCatalog;    // for the device's local iTunes songs


+ (SongCatalog*)synchronizedCatalog
{
    if (_synchronizedCatalog == nil)
    {
        _synchronizedCatalog = [[SongCatalog alloc] init];
    }
    return _synchronizedCatalog;
}

+ (void)releaseSynchronizedCatalog
{
    if (_synchronizedCatalog == nil)
        return;
    
    [_synchronizedCatalog release];
    _synchronizedCatalog = nil;
}

+ (SongCatalog*)availableCatalog
{
    if (_availableCatalog == nil)
    {
        _availableCatalog = [[SongCatalog alloc] init];
    }
    return _availableCatalog;
}


+ (void)releaseAvailableCatalog
{
    if (_availableCatalog == nil)
        return;
    
    [_availableCatalog release];
    _availableCatalog = nil;
}




+ (NSString*)catalogKeyOfSong:(NSString*)name artist:(NSString*)artist album:(NSString*)album
{
    NSString* artistKey = artist;
    NSString* albumKey = album;
    
    if (artistKey == nil)
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);

    if (albumKey == nil)
        albumKey =  NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
    
    return [NSString stringWithFormat:@"%@|%@|%@", name, artistKey, albumKey];
}




//...............................................................................................
//
// init
//


- (id)init
{
    if (self = [super init])
    {
        _numericSet = [[NSCharacterSet decimalDigitCharacterSet] retain];
        _lowerCaseSet = [[NSCharacterSet lowercaseLetterCharacterSet] retain];
        _upperCaseSet = [[NSCharacterSet uppercaseLetterCharacterSet] retain];
        
        self.nbSongs = 0;

        
        self.alphabeticRepo = [[NSMutableDictionary alloc] init];
        
        self.alphaArtistsRepo = [[NSMutableDictionary alloc] init];
        
        
        self.indexMap = [[NSMutableArray alloc] init];
        [self initIndexMap];
        
        for (NSString* indexKey in self.indexMap)
        {
            NSMutableArray* letterRepo = [[NSMutableArray alloc] init];
            [self.alphabeticRepo setObject:letterRepo forKey:indexKey];

            NSMutableDictionary* letterArtistRepo = [[NSMutableDictionary alloc] init];
            [self.alphaArtistsRepo setObject:letterArtistRepo forKey:indexKey];
        }

    }
    return self;
}




- (void)dealloc
{
    [_numericSet release];
    [_lowerCaseSet release];
    [_upperCaseSet release];
    [super dealloc];
}



- (void)initIndexMap
{
    [self.indexMap addObject:@"-"];
    [self.indexMap addObject:@"A"];
    [self.indexMap addObject:@"B"];
    [self.indexMap addObject:@"C"];
    [self.indexMap addObject:@"D"];
    [self.indexMap addObject:@"E"];
    [self.indexMap addObject:@"F"];
    [self.indexMap addObject:@"G"];
    [self.indexMap addObject:@"H"];
    [self.indexMap addObject:@"I"];
    [self.indexMap addObject:@"J"];
    [self.indexMap addObject:@"K"];
    [self.indexMap addObject:@"L"];
    [self.indexMap addObject:@"M"];
    [self.indexMap addObject:@"N"];
    [self.indexMap addObject:@"O"];
    [self.indexMap addObject:@"P"];
    [self.indexMap addObject:@"Q"];
    [self.indexMap addObject:@"R"];
    [self.indexMap addObject:@"S"];
    [self.indexMap addObject:@"T"];
    [self.indexMap addObject:@"U"];
    [self.indexMap addObject:@"V"];
    [self.indexMap addObject:@"W"];
    [self.indexMap addObject:@"X"];
    [self.indexMap addObject:@"Y"];
    [self.indexMap addObject:@"Z"];
    [self.indexMap addObject:@"#"];
}










//...............................................................................................
//
// build catalog from the server's synchronized songs 
//

- (void)buildSynchronizedWithSource:(NSDictionary*)source
{
    NSArray* songs = [source allValues];
    
    for (Song* song in songs)
    {
        // be aware of empty artist names, and empty album names
        NSString* artistKey = song.artist;
        if ((artistKey == nil) || (artistKey.length == 0))
        {
            artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
            NSLog(@"empty artist found!");
        }
        NSString* albumKey = song.album;
        if ((albumKey == nil) || (albumKey.length == 0))
        {
            artistKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
            NSLog(@"empty album found!");
        }
        
        [self catalogWithoutSorting:song  usingArtistKey:artistKey andAlbumKey:albumKey];
        self.nbSongs++;    
    }
}




//...............................................................................................
//
// build catalog from the device's local iTunes songs
//
- (void)buildAvailableComparingToSource:(NSDictionary*)synchronizedSource
{
    
    //NSLog(@"%@", synchronizedSource);
    
    [[TimeProfile main] begin:@"iTunesQuery"];
    
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    NSArray* songsArray = [allSongsQuery items];

    [[TimeProfile main] end:@"iTunesQuery"];
    [[TimeProfile main] logInterval:@"iTunesQuery" inMilliseconds:NO];

    // list all local songs from albums
    for (MPMediaItem* item in songsArray)
    {
        SongLocal* songLocal = [[SongLocal alloc] initWithMediaItem:item];
        
        Song* matchedSong = [synchronizedSource objectForKey:songLocal.catalogKey];
        
        
        // don't include it if it's included in the matched songs already
        if (matchedSong != nil)
            continue;
        
        // before putting this song into the catalog,
        // check if it's not uploading already.
        Song* uploadingSong = [[SongUploadManager main] getUploadingSong:songLocal.name artist:songLocal.artist album:songLocal.album];
        if (uploadingSong != nil)
            [songLocal setUploading:YES];
        
        // REMEMBER THAT HERE, songLocal is SongLocal* 
        
        [self catalogWithoutSorting:songLocal usingArtistKey:songLocal.artistKey andAlbumKey:songLocal.albumKey];
        
        
        self.nbSongs++;
        
    }
}





//...............................................................................................
//
// common building methods for both catalogs
//


- (void)insertAndEnableSong:(Song*)song;
{
    // be aware of empty artist names, and empty album names
    NSString* artistKey = song.artist;
    if ((artistKey == nil) || (artistKey.length == 0))
    {
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
        NSLog(@"empty artist found!");
    }
    NSString* albumKey = song.album;
    if ((albumKey == nil) || (albumKey.length == 0))
    {
        artistKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
        NSLog(@"empty album found!");
    }
    
    [song enableSong:YES];
    
    [self catalogWithoutSorting:song  usingArtistKey:artistKey andAlbumKey:albumKey];
    self.nbSongs++;    
}




- (void)removeSynchronizedSong:(Song*)song
{
    //
    // process alphaeticRepo
    //
    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
    
    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
        firstRelevantWord = @"#";
    
    unichar c = [firstRelevantWord characterAtIndex:0];

    NSMutableArray* letterRepo = nil;
    
    if ([_numericSet characterIsMember:c]) 
    {
        letterRepo = [self.alphabeticRepo objectForKey:@"-"];
    }
    // first letter is [a .. z] || [A .. Z]
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
    }
    // other cases (foreign languages, ...)
    else
    {
        letterRepo = [self.alphabeticRepo objectForKey:@"#"];
    }
    
    for (NSInteger index = 0; index < letterRepo.count; index++)
    {
        Song* letterSong = [letterRepo objectAtIndex:index];
        if ([letterSong.name isEqualToString:song.name])
        {
            [letterRepo removeObjectAtIndex:index];
            break;
        }
    }
    
    
    //
    // process artistsRepo
    //
    
    NSString* artistKey = song.artist;
    if ((artistKey == nil) || (artistKey.length == 0))
    {
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
        NSLog(@"empty artist found!");
    }
    NSString* albumKey = song.album;
    if ((albumKey == nil) || (albumKey.length == 0))
    {
        artistKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
        NSLog(@"empty album found!");
    }
    
    
    
    c = [artistKey characterAtIndex:0];
    NSMutableDictionary* artistsRepo = nil;
    if ([_numericSet characterIsMember:c])
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"-"];
    }
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperC = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        artistsRepo = [self.alphaArtistsRepo objectForKey:upperC];
    }
    else
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"#"];
    }
    
    NSMutableDictionary* artistRepo = [artistsRepo objectForKey:artistKey];
    NSLog(@"SongCatalog removeSynchronizedSong : may have error no dictionary for the artistKy '%@'", artistKey);
    if (artistRepo == nil)
        return;
    

    NSMutableArray* albumRepo = [artistRepo objectForKey:albumKey];
    
    for (NSInteger index = 0; index < albumRepo.count; index++)
    {
        Song* albumSong = [albumRepo objectAtIndex:index];
        if ([albumSong.name isEqualToString:song.name])
        {
            [albumRepo removeObjectAtIndex:index];
            break;
        }
    }
    
    
    
    
}





- (BOOL)doesContainSong:(Song*)song
{
    //
    // process alphaeticRepo
    //
    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
    
    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
        firstRelevantWord = @"#";
    
    unichar c = [firstRelevantWord characterAtIndex:0];
    
    NSMutableArray* letterRepo = nil;
    
    if ([_numericSet characterIsMember:c]) 
    {
        letterRepo = [self.alphabeticRepo objectForKey:@"-"];
    }
    // first letter is [a .. z] || [A .. Z]
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
    }
    // other cases (foreign languages, ...)
    else
    {
        letterRepo = [self.alphabeticRepo objectForKey:@"#"];
    }
    
    for (NSInteger index = 0; index < letterRepo.count; index++)
    {
        Song* letterSong = [letterRepo objectAtIndex:index];
        if ([letterSong.name isEqualToString:song.name])
        {
            return YES;
        }
    }
    
    return NO;
}





//
// add a song to the catalog,
//
- (void)catalogWithoutSorting:(Song*)song  usingArtistKey:(NSString*)artistKey andAlbumKey:(NSString*)albumKey
{
    
    // get what u need to sort alphabetically
    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
    
    // just in case of
    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
        firstRelevantWord = @"#";
    
    
    unichar c = [firstRelevantWord characterAtIndex:0];
    
    // we spread the songs, in a dictionnary, and group them depending on their first letter
    // => each table view section will be related to a letter
    
    // first letter is [0 .. 9]
    if ([_numericSet characterIsMember:c]) 
    {
        NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:@"-"];
        [letterRepo addObject:song];
    }
    // first letter is [a .. z] || [A .. Z]
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
        [letterRepo addObject:song];
    }
    // other cases (foreign languages, ...)
    else
    {
        NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:@"#"];
        [letterRepo addObject:song];
    }
    
    
    
    
    
    // now the Artist / Album / Song catalog
    
    c = [artistKey characterAtIndex:0];
    NSMutableDictionary* artistsRepo = nil;

    if ([_numericSet characterIsMember:c])
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"-"];
    }
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperC = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        artistsRepo = [self.alphaArtistsRepo objectForKey:upperC];
    }
    else
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"#"];
    }
    
    NSMutableDictionary* artistRepo = [artistsRepo objectForKey:artistKey];
    if (artistRepo == nil)
    {
        artistRepo = [[NSMutableDictionary alloc] init];
        [artistsRepo setObject:artistRepo forKey:artistKey];
    }
    
    
    // store the song in the right repository
    NSMutableArray* albumRepo = [artistRepo objectForKey:albumKey];
    if (albumRepo == nil)
    {
        albumRepo = [[NSMutableArray alloc] init];
        [artistRepo setObject:albumRepo forKey:albumKey];
    }
    
    [albumRepo addObject:song];
}









//...............................................................................................
//
// tools to handle items selection
//

- (BOOL)selectArtist:(NSString*)artistKey withIndex:(NSString*)charIndex
{
    // first, reset album selection
    self.selectedAlbum = nil;
    self.selectedAlbumRepo = nil;
    NSDictionary* artistsForSection = [self.alphaArtistsRepo objectForKey:charIndex];

    self.selectedArtist = artistKey;
    NSLog(@"selected artist %@", self.selectedArtist);
    
    NSLog(@"%@", artistsForSection);
    
    self.selectedArtistRepo = [artistsForSection objectForKey:artistKey];
    
    return YES;

}

- (BOOL)selectAlbum:(NSString*)albumKey
{
    if (self.selectedArtistRepo == nil)
        return NO;
    
    self.selectedAlbum = albumKey;
    
    NSLog(@"selected album %@", self.selectedAlbum);
    
    self.selectedAlbumRepo = [self.selectedArtistRepo objectForKey:self.selectedAlbum];
    
    return YES;
}



- (Song*)getSongAtRow:(NSInteger)row;
{
    if (self.selectedAlbumRepo == nil)
        return nil;
    
    if (row >= self.selectedAlbumRepo.count)
        return nil;
    
    return [self.selectedAlbumRepo objectAtIndex:row];
}










@end
