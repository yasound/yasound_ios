//
//  SongCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "TimeProfile.h"


@implementation SongCatalog

@synthesize db;
@synthesize songsDb;
@synthesize dbPath;

@synthesize isInCache;
@synthesize indexMap;

// cache
@synthesize songs;
@synthesize songsForLetter;
@synthesize artistsForLetter;

@synthesize selectedArtist;
@synthesize selectedAlbum;



//typedef enum {
//   
//    eRadioCatalogKey = 0,
//    eRadioCatalogName,
//    eRadioCatalogNameLetter,
//    eRadioCatalogArtist,
//    eRadioCatalogArtistLetter,
//    eRadioCatalogAlbum,
//    eRadioCatalogSong
//} RadioCatalogTable;
//
//typedef enum {
//    
//    eLocalCatalogKey = 0,
//    eLocalCatalogName,
//    eLocalCatalogNameLetter,
//    eLocalCatalogArtist,
//    eLocalCatalogArtistLetter,
//    eLocalCatalogAlbum,
//    eLocalCatalogSong
//} LocalCatalogTable;





+ (NSString*)catalogKeyOfSong:(NSString*)name artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey
{
    return [NSString stringWithFormat:@"%@|%@|%@", name, artistKey, albumKey];
}



+ (NSString*)shortString:(NSString*)source
{
    if (source.length < (23))
        return source;
    
    NSString* begin = [source substringToIndex:7];
    NSString* end = [source substringFromIndex:(source.length - 16)];
    
    NSString* shortstring = [NSString stringWithFormat:@"%@[...]%@", begin, end];
    return shortstring;
}



















- (id)init {
    
    if (self = [super init]) {
        self.isInCache = NO;
        
        [self initDB];
        
        self.indexMap = [NSMutableArray array];
        [self initIndexMap];
        
        self.songsForLetter = [NSMutableDictionary dictionary];
        self.artistsForLetter = [NSMutableDictionary dictionary];

        _numericSet = [[NSCharacterSet decimalDigitCharacterSet] retain];
        _lowerSet = [[NSCharacterSet lowercaseLetterCharacterSet] retain];
        _upperSet = [[NSCharacterSet uppercaseLetterCharacterSet] retain];
        

    }
    return self;
}



- (void)initDB
{
    // create the DB file
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dbPath = [paths objectAtIndex:0];
    self.dbPath = [self.dbPath stringByAppendingPathComponent:@"songCatalog.sqlite"];
    
    // delete current DB file
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dbPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.dbPath error:nil];
    }
        
    
    self.db = [FMDatabase databaseWithPath:self.dbPath];
    if (![self.db open])
    {
        NSLog(@"error : could not open the db file.");
        [self.db release];
    }
    else
    {
        //
        NSLog(@"database create radioCatalog table");
        [self createTable:RADIOCATALOG_TABLE];
        
        //
        NSLog(@"database create localCatalog table");
        [self createTable:LOCALCATALOG_TABLE];
    }
    
    self.songsDb = [NSMutableDictionary dictionary];
}


- (void)dealloc {
    
    [self.db close];
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








//...................................................................
//
// creaters
//

- (void)createTable:(NSString*)table {
    
    BOOL res = [self.db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE %@ (songKey TEXT, name VARCHAR(255), nameLetter VARCHAR(1), artistKey VARCHAR(255), artistLetter VARCHAR(1), albumKey VARCHAR(255))", table]];
    if (!res)
    NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
    else
    {
        res = [self.db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX catalogKeyIndex ON %@ (songKey)", table]];
        if (!res)
            NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
    }
}








//...................................................................
//
// getters
//

- (NSDictionary*)songsAllFromTable:(NSString*)table
{
    return self.songsDb;
    
//    // get cache
//    if (self.songs != nil)
//        return self.songs;
//    
//    self.songs = [NSMutableDictionary dictionary];
//    
//    FMResultSet* s = [self.db executeQuery:[NSString stringWithFormat:@"SELECT song FROM %@", table]];
//    while ([s next])
//    {
//        NSString* catalogKey = [s stringForColumnIndex:eCatalogSongKey];
////        Song* song = [s objectForColumnIndex:eCatalogSong];
//        Song* song = [self.songsDb objectForKey:catalogKey];
//        [self.songs setObject:song forKey:catalogKey];
//    }
//    
//    return self.songs;
}



- (NSArray*)songsForLetter:(NSString*)charIndex fromTable:(NSString*)table
{
    charIndex = [charIndex uppercaseString];
    
    // get cache
    NSArray* cache = [self.songsForLetter objectForKey:charIndex];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
//    FMResultSet* s = [self.db executeQuery:[NSString stringWithFormat:@"SELECT songKey FROM %@ WHERE nameLetter=?", table], charIndex];
    FMResultSet* s = [self.db executeQuery:@"SELECT * FROM radioCatalog WHERE nameLetter=?", charIndex];

//#ifdef DEBUG
//    DLog(@"songsForLetter FMDB executeQuery '%@'", s.query);
//#endif
    
    while ([s next])
    {
//        Song* song = [s objectForColumnIndex:eCatalogSong];
//        NSString* name = [s stringForColumnIndex:eCatalogName];
        NSString* songKey = [s stringForColumnIndex:eCatalogSongKey];
        assert(songKey);
        Song* song = [self.songsDb objectForKey:songKey];
        assert(song);
        [results addObject:song];
    }
    
    // set cache
    [self.songsForLetter setObject:results forKey:charIndex];
    
    return results;
}


- (NSArray*)artistsForLetter:(NSString*)charIndex fromTable:(NSString*)table
{
    // get cache
    NSArray* cache = [self.artistsForLetter objectForKey:charIndex];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [self.db executeQuery:[NSString stringWithFormat:@"SELECT artist FROM %@ WHERE artistLetter=?", table], charIndex];
    while ([s next])
    {
        NSString* artist = [s stringForColumnIndex:eCatalogArtistKey];
        [results addObject:artist];
    }
    
    // set cache
    [self.artistsForLetter setObject:results forKey:charIndex];
    
    return results;
}









//...................................................................
//
// setters
//


- (BOOL)addSong:(Song*)song forTable:(NSString*)table songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey {
    
    assert(song);
    assert(songKey);
    assert(artistKey);
    assert(albumKey);
    
    // first letter of song's name
    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
    firstRelevantWord = [firstRelevantWord uppercaseString];

    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
        firstRelevantWord = @"#";

    unichar nameLetter = [firstRelevantWord characterAtIndex:0];

    if ([_numericSet characterIsMember:nameLetter])
        nameLetter = '-';
    else if (![_lowerSet characterIsMember:nameLetter] && ![_upperSet characterIsMember:nameLetter])
        nameLetter = '#';
        

    
    // first letter of artist's name
    firstRelevantWord = [song.artist uppercaseString];
    unichar artistLetter = [firstRelevantWord characterAtIndex:0];
    
    if ([_numericSet characterIsMember:artistLetter])
        artistLetter = '-';
    else if (![_lowerSet characterIsMember:artistLetter] && ![_upperSet characterIsMember:artistLetter])
        artistLetter = '#';
    
    
    NSString* nameChar = [NSString stringWithFormat:@"%C", nameLetter];
    NSString* artistChar = [NSString stringWithFormat:@"%C", artistLetter];

    [self.db beginTransaction];
//    BOOL res = [self.db executeUpdate:@"INSERT INTO ? VALUES (?,?,?,?,?,?,?)", table, songKey, song.name, nameLetter, song.artist, artistLetter, song.album, song];
//    BOOL res = [self.db executeUpdate:@"INSERT INTO ? VALUES (?,?,?,?,?,?,?)", table, songKey, song.name, nameChar, song.artist, artistChar, song.album, song];
    BOOL res = [self.db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ VALUES (?,?,?,?,?,?)", table], songKey, song.name, nameChar, song.artist, artistChar, song.album];
    [self.db commit];
    
    if (!res)
        DLog(@"addSong, %d:%@", [self.db lastErrorCode], [self.db lastErrorMessage]);
    else
        [self.songsDb setObject:song forKey:songKey];
    
    
    return res;
}



- (void)insertAndEnableSong:(Song*)song;
{
//    // be aware of empty artist names, and empty album names
//    NSString* artistKey = song.artist;
//    if ((artistKey == nil) || (artistKey.length == 0))
//    {
//        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
//        DLog(@"insertAndEnableSong: empty artist found!");
//    }
//    NSString* albumKey = song.album;
//    if ((albumKey == nil) || (albumKey.length == 0))
//    {
//        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
//        DLog(@"insertAndEnableSong: empty album found!");
//    }
//    
//    [song enableSong:YES];
//    
//    [self catalogWithoutSorting:song  usingArtistKey:artistKey andAlbumKey:albumKey];
//    self.nbSongs++;
}




- (void)removeSynchronizedSong:(Song*)song
{
//    //
//    // process alphaeticRepo
//    //
//    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
//    
//    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
//        firstRelevantWord = @"#";
//    
//    unichar c = [firstRelevantWord characterAtIndex:0];
//    
//    NSMutableArray* letterRepo = nil;
//    
//    if ([_numericSet characterIsMember:c])
//    {
//        letterRepo = [self.alphabeticRepo objectForKey:@"-"];
//    }
//    // first letter is [a .. z] || [A .. Z]
//    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
//    {
//        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
//        letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
//    }
//    // other cases (foreign languages, ...)
//    else
//    {
//        letterRepo = [self.alphabeticRepo objectForKey:@"#"];
//    }
//
//    for (NSInteger index = 0; index < letterRepo.count; index++)
//    {
//        Song* letterSong = [letterRepo objectAtIndex:index];
//        if ([letterSong.name isEqualToString:song.name])
//        {
//            [letterRepo removeObjectAtIndex:index];
//            break;
//        }
//    }
//    
//    
//    //
//    // process artistsRepo
//    //
//    
//    NSString* artistKey = song.artist;
//    if ((artistKey == nil) || (artistKey.length == 0))
//    {
//        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
//        DLog(@"removeSynchronizedSong: empty artist found!");
//    }
//    NSString* albumKey = song.album;
//    if ((albumKey == nil) || (albumKey.length == 0))
//    {
//        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
//        DLog(@"removeSynchronizedSong: empty album found!");
//    }
//    
//    
//    
//    c = [artistKey characterAtIndex:0];
//    NSMutableDictionary* artistsRepo = nil;
//    if ([_numericSet characterIsMember:c])
//    {
//        artistsRepo = [self.alphaArtistsRepo objectForKey:@"-"];
//    }
//    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
//    {
//        NSString* upperC = [[NSString stringWithCharacters:&c length:1] uppercaseString];
//        artistsRepo = [self.alphaArtistsRepo objectForKey:upperC];
//    }
//    else
//    {
//        artistsRepo = [self.alphaArtistsRepo objectForKey:@"#"];
//    }
//    
//    NSMutableDictionary* artistRepo = [artistsRepo objectForKey:artistKey];
//    DLog(@"SongCatalog removeSynchronizedSong : may have error no dictionary for the artistKy '%@'", artistKey);
//    if (artistRepo == nil)
//        return;
//    
//    
//    NSMutableArray* albumRepo = [artistRepo objectForKey:albumKey];
//    
//    for (NSInteger index = 0; index < albumRepo.count; index++)
//    {
//        Song* albumSong = [albumRepo objectAtIndex:index];
//        if ([albumSong.name isEqualToString:song.name])
//        {
//            [albumRepo removeObjectAtIndex:index];
//            break;
//        }
//    }
//    
//    
//    
    
}





- (BOOL)doesContainSong:(Song*)song
{
//    //
//    // process alphaeticRepo
//    //
//    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
//    
//    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
//        firstRelevantWord = @"#";
//    
//    unichar c = [firstRelevantWord characterAtIndex:0];
//    
//    NSMutableArray* letterRepo = nil;
//    
//    if ([_numericSet characterIsMember:c])
//    {
//        letterRepo = [self.alphabeticRepo objectForKey:@"-"];
//    }
//    // first letter is [a .. z] || [A .. Z]
//    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
//    {
//        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
//        letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
//    }
//    // other cases (foreign languages, ...)
//    else
//    {
//        letterRepo = [self.alphabeticRepo objectForKey:@"#"];
//    }
//    
//    for (NSInteger index = 0; index < letterRepo.count; index++)
//    {
//        Song* letterSong = [letterRepo objectAtIndex:index];
//        if ([letterSong.name isEqualToString:song.name])
//        {
//            return YES;
//        }
//    }
//    
//    return NO;
}





- (void)removeSynchronizedArtist:(NSString*)artistNameFromClient
{
    // TODO
    //    NSString* artistKey = [self catalogKeyOfArtist:artistNameFromClient];
    //
    //    //
    //    // process artistsRepo
    //    //
    //
    //    NSString* artistKey = song.artist;
    //    if ((artistKey == nil) || (artistKey.length == 0))
    //    {
    //        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
    //        DLog(@"removeSynchronizedSong: empty artist found!");
    //    }
    //    NSString* albumKey = song.album;
    //    if ((albumKey == nil) || (albumKey.length == 0))
    //    {
    //        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
    //        DLog(@"removeSynchronizedSong: empty album found!");
    //    }
    //
    //
    //
    //    c = [artistKey characterAtIndex:0];
    //    NSMutableDictionary* artistsRepo = nil;
    //    if ([_numericSet characterIsMember:c])
    //    {
    //        artistsRepo = [self.alphaArtistsRepo objectForKey:@"-"];
    //    }
    //    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    //    {
    //        NSString* upperC = [[NSString stringWithCharacters:&c length:1] uppercaseString];
    //        artistsRepo = [self.alphaArtistsRepo objectForKey:upperC];
    //    }
    //    else
    //    {
    //        artistsRepo = [self.alphaArtistsRepo objectForKey:@"#"];
    //    }
    //
    //    NSMutableDictionary* artistRepo = [artistsRepo objectForKey:artistKey];
    //    DLog(@"SongCatalog removeSynchronizedSong : may have error no dictionary for the artistKy '%@'", artistKey);
    //    if (artistRepo == nil)
    //        return;
    //
    //
    //    NSMutableArray* albumRepo = [artistRepo objectForKey:albumKey];
    //
    //    for (NSInteger index = 0; index < albumRepo.count; index++)
    //    {
    //        Song* albumSong = [albumRepo objectAtIndex:index];
    //        if ([albumSong.name isEqualToString:song.name])
    //        {
    //            [albumRepo removeObjectAtIndex:index];
    //            break;
    //        }
    //    }
    //
    //
    //
    //    //
    //    // process alphaeticRepo
    //    //
    //    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
    //
    //    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
    //        firstRelevantWord = @"#";
    //
    //    unichar c = [firstRelevantWord characterAtIndex:0];
    //
    //    NSMutableArray* letterRepo = nil;
    //
    //    if ([_numericSet characterIsMember:c])
    //    {
    //        letterRepo = [self.alphabeticRepo objectForKey:@"-"];
    //    }
    //    // first letter is [a .. z] || [A .. Z]
    //    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    //    {
    //        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
    //        letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
    //    }
    //    // other cases (foreign languages, ...)
    //    else
    //    {
    //        letterRepo = [self.alphabeticRepo objectForKey:@"#"];
    //    }
    //
    //    for (NSInteger index = 0; index < letterRepo.count; index++)
    //    {
    //        Song* letterSong = [letterRepo objectAtIndex:index];
    //        if ([letterSong.name isEqualToString:song.name])
    //        {
    //            [letterRepo removeObjectAtIndex:index];
    //            break;
    //        }
    //    }
    
}

- (void)removeSynchronizedAlbum:(NSString*)albumNameFromClient
{
    // TODO
}












//
////
//// add a song to the catalog,
////
//- (void)catalogWithoutSorting:(Song*)song  usingArtistKey:(NSString*)artistKey andAlbumKey:(NSString*)albumKey
//{
//    //LBDEBUG
//    DevLog(@"catalogWithoutSorting   name '%@'  name_client '%@'         artistKey '%@', artistKey_client '%@'       albumKey '%@', albumKey_client '%@'", song.name, song.name_client, artistKey, song.artist_client, albumKey, song.album_client);
//    
//    // get what u need to sort alphabetically
//    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
//    
//    // just in case of
//    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
//        firstRelevantWord = @"#";
//    
//    
//    unichar c = [firstRelevantWord characterAtIndex:0];
//    
//    // we spread the songs, in a dictionnary, and group them depending on their first letter
//    // => each table view section will be related to a letter
//    
//    // first letter is [0 .. 9]
//    if ([_numericSet characterIsMember:c])
//    {
//        NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:@"-"];
//        [letterRepo addObject:song];
//    }
//    // first letter is [a .. z] || [A .. Z]
//    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
//    {
//        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
//        NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
//        [letterRepo addObject:song];
//    }
//    // other cases (foreign languages, ...)
//    else
//    {
//        NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:@"#"];
//        [letterRepo addObject:song];
//    }
//    
//    
//    
//    
//    
//    // now the Artist / Album / Song catalog
//    
//    c = [artistKey characterAtIndex:0];
//    NSMutableDictionary* artistsRepo = nil;
//    
//    if ([_numericSet characterIsMember:c])
//    {
//        artistsRepo = [self.alphaArtistsRepo objectForKey:@"-"];
//    }
//    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
//    {
//        NSString* upperC = [[NSString stringWithCharacters:&c length:1] uppercaseString];
//        artistsRepo = [self.alphaArtistsRepo objectForKey:upperC];
//    }
//    else
//    {
//        artistsRepo = [self.alphaArtistsRepo objectForKey:@"#"];
//    }
//    
//    NSMutableDictionary* artistRepo = [artistsRepo objectForKey:artistKey];
//    if (artistRepo == nil)
//    {
//        artistRepo = [[NSMutableDictionary alloc] init];
//        [artistsRepo setObject:artistRepo forKey:artistKey];
//    }
//    
//    
//    // store the song in the right repository
//    NSMutableArray* albumRepo = [artistRepo objectForKey:albumKey];
//    if (albumRepo == nil)
//    {
//        albumRepo = [[NSMutableArray alloc] init];
//        [artistRepo setObject:albumRepo forKey:albumKey];
//    }
//    
//    [albumRepo addObject:song];
//}
//








//...............................................................................................
//
// tools to handle items selection
//

//- (BOOL)selectArtist:(NSString*)artistKey withIndex:(NSString*)charIndex
- (BOOL)selectArtist:(NSString*)artistKey
{
    // first, reset album selection
    self.selectedAlbum = nil;
//    self.selectedAlbumRepo = nil;
//    NSDictionary* artistsForSection = [self.alphaArtistsRepo objectForKey:charIndex];
    
//    self.selectedArtist = artistKey;
//    DLog(@"selected artist %@", self.selectedArtist);
//    
//    //DLog(@"artistForSection %@", artistsForSection);
//
//    self.selectedArtistRepo = [artistsForSection objectForKey:artistKey];
    
    DLog(@"selected artist '%@'", artistKey);

    self.selectedArtist = artistKey;
    
    return YES;
    
}

- (BOOL)selectAlbum:(NSString*)albumKey
{
    if (self.selectedArtist == nil)
        return NO;
    
    self.selectedAlbum = albumKey;
    
    DLog(@"selected album %@", self.selectedAlbum);
    
    return YES;
}



- (Song*)getSongAtRow:(NSInteger)row;
{
//    if (self.selectedAlbumRepo == nil)
//        return nil;
//    
//    if (row >= self.selectedAlbumRepo.count)
//        return nil;
//    
//    return [self.selectedAlbumRepo objectAtIndex:row];
    return nil;
}





@end
