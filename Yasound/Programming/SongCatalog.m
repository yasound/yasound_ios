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



#define PM_FIELD_UNKNOWN @""


@implementation SongCatalog

@synthesize matchedSongs;
@synthesize nbSongs;

@synthesize alphabeticRepo;
@synthesize indexMap;
@synthesize alphaArtistsRepo;
@synthesize alphaArtistsOrder;
@synthesize alphaArtistsPREORDER;

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
        self.alphaArtistsPREORDER = [[NSMutableDictionary alloc] init];
        self.alphaArtistsOrder = [[NSMutableDictionary alloc] init];
        
        
        self.indexMap = [[NSMutableArray alloc] init];
        [self initIndexMap];
        
        for (NSString* indexKey in self.indexMap)
        {
            NSMutableArray* letterRepo = [[NSMutableArray alloc] init];
            [self.alphabeticRepo setObject:letterRepo forKey:indexKey];

            NSMutableDictionary* letterArtistRepo = [[NSMutableDictionary alloc] init];
            [self.alphaArtistsRepo setObject:letterArtistRepo forKey:indexKey];

            NSMutableDictionary* letterArtistPREORDER = [[NSMutableDictionary alloc] init];
            [self.alphaArtistsPREORDER setObject:letterArtistPREORDER forKey:indexKey];
            
            NSMutableArray* letterArtistOrder = [[NSMutableArray alloc] init];
            [self.alphaArtistsOrder setObject:letterArtistOrder forKey:indexKey];
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
        
        [self sortAndCatalog:song  usingArtistKey:artistKey andAlbumKey:albumKey];
        self.nbSongs++;    
    }
    
    [self finalizeCatalog];
}




//...............................................................................................
//
// build catalog from the device's local iTunes songs
//

- (void)buildAvailableComparingToSource:(NSDictionary*)synchronizedSource
{
    
    //NSLog(@"%@", synchronizedSource);
    
    MPMediaQuery* allAlbumsQuery = [MPMediaQuery albumsQuery];
    NSArray* allAlbumsArray = [allAlbumsQuery collections];
    
    
    // list all local albums
    for (MPMediaItemCollection* collection in allAlbumsArray) 
    {
        // list all local songs from albums
        for (MPMediaItem* item in collection.items)
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
            
            [self sortAndCatalog:songLocal usingArtistKey:songLocal.artistKey andAlbumKey:songLocal.albumKey];
            self.nbSongs++;

        }
    }
    
    [self finalizeCatalog];
}








//...............................................................................................
//
// common building methods for both catalogs
//


- (void)insertAndSortAndEnableSong:(Song*)song;
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
    
    [self sortAndCatalog:song  usingArtistKey:artistKey andAlbumKey:albumKey];
    self.nbSongs++;    
    
    [self finalizeCatalog];
}




- (void)removeSynchronizedSong:(Song*)song
{
//    NSLog(@"%@", self.alphabeticRepo);
//    NSLog(@"%@", self.alphaArtistsRepo);
//    NSLog(@"%@", self.alphaArtistsPREORDER);
//    NSLog(@"%@", self.alphaArtistsOrder);

    
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
    assert(artistRepo != nil);
    if (artistRepo == nil)
        return;
    
    // store the song in the right repository
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




//
// add a song to the catalog,
// making an alphabetic sort
//
- (void)sortAndCatalog:(Song*)song  usingArtistKey:(NSString*)artistKey andAlbumKey:(NSString*)albumKey
{

    // get what u need to sort alphabetically
    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
    
    //assert(firstRelevantWord != nil);
    //assert(firstRelevantWord.length != 0);
    
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
    
    // TODO : comprendre pourquoi l'assert se déclenche chez seb
    
    //assert(artistKey.length != 0);
    
    c = [artistKey characterAtIndex:0];
    NSMutableDictionary* artistsRepo = nil;
    NSMutableDictionary* artistsPREORDER = nil;
    if ([_numericSet characterIsMember:c])
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"-"];
        artistsPREORDER = [self.alphaArtistsPREORDER objectForKey:@"-"];
    }
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperC = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        artistsRepo = [self.alphaArtistsRepo objectForKey:upperC];
        artistsPREORDER = [self.alphaArtistsPREORDER objectForKey:upperC];
    }
    else
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"#"];
        artistsPREORDER = [self.alphaArtistsPREORDER objectForKey:@"#"];
    }
    
    // store artist name, to be alphabetically sorted later
    // => we use a dictionary here to optimize the insert operation (the inserted object must be unique)
    // => when it'll be completed, the dictionnary will be turned into a array and we will sort it alphabetically
    [artistsPREORDER setObject:artistKey forKey:artistKey];
    
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




//
// finalizing the catalog : having an alphabetic sort in the artist / albums / songs repository
//
- (void)finalizeCatalog
{
    // now, sort alphabetically each letter repository
    for (NSString* key in [self.alphabeticRepo allKeys])
    {
        // don't sort the foreign languages
        if ([key isEqualToString:@"#"])
            continue;
        
        NSMutableArray* array = [self.alphabeticRepo objectForKey:key];
        NSMutableArray* sortedArray = [NSMutableArray arrayWithArray:[array sortedArrayUsingSelector:@selector(nameCompare:)]];
        [self.alphabeticRepo setObject:sortedArray forKey:key];
    }
    
    
    // and sort the artist repository order
    for (NSString* indexKey in self.indexMap)
    {
        NSDictionary* artistPREORDER = [self.alphaArtistsPREORDER objectForKey:indexKey];
        NSArray* array = [artistPREORDER allValues];
        
        // alphabetic sort
        array = [NSMutableArray arrayWithArray:[array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        
        [self.alphaArtistsOrder setObject:array forKey:indexKey];
    }
    for (NSString* key in [self.alphaArtistsOrder allKeys])
    {
        // don't sort the foreign languages
        if ([key isEqualToString:@"#"])
            continue;
        
        NSMutableArray* array = [self.alphaArtistsOrder objectForKey:key];
        NSMutableArray* sortedArray = [NSMutableArray arrayWithArray:[array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        [self.alphaArtistsOrder setObject:sortedArray forKey:key];
    }
    
    //    NSLog(@"%@", self.alphabeticRepo);
    //    NSLog(@"%@", self.alphaArtistsRepo);
    //    NSLog(@"%@", self.alphaArtistsOrder);
    
}









//...............................................................................................
//
// tools to handle items selection
//


- (BOOL)selectArtistInSection:(NSInteger)section atRow:(NSInteger)row
{
    // first, reset album selection
    self.selectedAlbum = nil;
    self.selectedAlbumRepo = nil;
    
    if (section >= self.indexMap.count)
        return NO;
    
    // now, select artist
    NSString* charIndex = [self.indexMap objectAtIndex:section];
    NSArray* artistsForSection = [self.alphaArtistsOrder objectForKey:charIndex];
    
    if (row >= artistsForSection.count)
        return NO;

    NSString* artist = [artistsForSection objectAtIndex:row];
    
    self.selectedArtist = artist;
    
    NSLog(@"selected artist %@", self.selectedArtist);
    
    NSDictionary* artistsRepo = [self.alphaArtistsRepo objectForKey:charIndex];
    
    self.selectedArtistRepo = [artistsRepo objectForKey:artist];

    return YES;
}


- (BOOL)selectAlbumAtRow:(NSInteger)row
{
    if (self.selectedArtistRepo == nil)
        return NO;
        
    NSArray* albums = [self.selectedArtistRepo allKeys];
    
    if (row >= albums.count)
        return NO;
    
    self.selectedAlbum = [albums objectAtIndex:row];
    
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
