//
//  SongCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "Song.h"

@implementation SongCatalog

@synthesize db;
@synthesize dbPath;

@synthesize isInCache;
@synthesize indexMap;

// cache
@synthesize cacheSongs;
@synthesize cacheSongsForLetter;
@synthesize cacheArtistsForLetter;


typedef enum {
   
    eRadioCatalogKey = 0,
    eRadioCatalogName,
    eRadioCatalogNameLetter,
    eRadioCatalogArtist,
    eRadioCatalogArtistLetter,
    eRadioCatalogAlbum,
    eRadioCatalogSong
} RadioCatalogTable;

typedef enum {
    
    eLocalCatalogKey = 0,
    eLocalCatalogName,
    eLocalCatalogNameLetter,
    eLocalCatalogArtist,
    eLocalCatalogArtistLetter,
    eLocalCatalogAlbum,
    eLocalCatalogSong
} LocalCatalogTable;






+ (NSString*)shortString:(NSString*)source
{
    if (source.length < (23))
        return source;
    
    NSString* begin = [source substringToIndex:7];
    NSString* end = [source substringFromIndex:(source.length - 16)];
    
    NSString* shortstring = [NSString stringWithFormat:@"%@[...]%@", begin, end];
    return shortstring;
}






- (void)dump
{
    NSLog(@"\nDB radioCatalog dump:");
    
    FMResultSet* s = [self.db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", RADIOCATALOG_TABLE]];
    while ([s next])
    {
        NSString* name = [SongCatalog shortString:[s stringForColumnIndex:eRadioCatalogName]];
        NSString* artist = [SongCatalog shortString:[s stringForColumnIndex:eRadioCatalogArtist]];
        NSString* album = [SongCatalog shortString:[s stringForColumnIndex:eRadioCatalogAlbum]];
        
        NSLog(@"name(%@)  artist(%@)   album(%@)", name, artist, album);
    }
    
    NSLog(@"----------------------------------\n");
    
    
    s = [self.db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", LOCALCATALOG_TABLE]];
    while ([s next])
    {
        NSString* name = [SongCatalog shortString:[s stringForColumnIndex:eLocalCatalogName]];
        NSString* artist = [SongCatalog shortString:[s stringForColumnIndex:eLocalCatalogArtist]];
        NSString* album = [SongCatalog shortString:[s stringForColumnIndex:eLocalCatalogAlbum]];
        
        NSLog(@"name(%@)  artist(%@)   album(%@)", name, artist, album);
    }
    
    NSLog(@"----------------------------------\n");
}













- (id)init {
    
    if (self = [super init]) {
        self.isInCache = NO;
        
        [self initDB];
        
        self.indexMap = [NSMutableArray array];
        [self initIndexMap];
        
        self.songsForLetter = [NSMutableDictionary dictionary];
        self.artistsForLetter = [NSMutableDictionary dictionary];

    }
    return self;
}



- (void)initDB
{
    // create the DB file
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dbPath = [paths objectAtIndex:0];
    self.dbPath = [self.dbPath stringByAppendingPathComponent:@"songCatalog.sqlite"];
    
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
        BOOL res = [self.db executeUpdate:@"CREATE TABLE ? (catalogKey TEXT, name VARCHAR(255), nameLetter CHAR, artist VARCHAR(255), artistLetter CHAR, album VARCHAR(255), song BLOB)", RADIOCATALOG_TABLE];
        if (!res)
            NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
        else
        {
            res = [self.db executeUpdate:@"CREATE INDEX catalogKeyIndex ON ? (catalogKey)", RADIOCATALOG_TABLE];
            if (!res)
                NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
        }

        
        //
        NSLog(@"database create localCatalog table");
        res = [self.db executeUpdate:@"CREATE TABLE ? (catalogKey TEXT, name VARCHAR(255), nameLetter CHAR, artist VARCHAR(255), artistLetter CHAR, album VARCHAR(255), song BLOB)", LOCALCATALOG_TABLE];
        if (!res)
            NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
        else
        {
            res = [self.db executeUpdate:@"CREATE INDEX catalogKeyIndex ON ? (catalogKey)", LOCALCATALOG_TABLE];
            if (!res)
                NSLog(@"fmdb error %@ - %d", [self.db lastErrorMessage], [self.db lastErrorCode]);
        }
        
    }
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




- (NSDictionary*)songsAllFromTable:(NSString*)table
{
    // get cache
    if (self.songs != nil)
        return self.songs;
    
    self.songs = [NSMutableDictionary array];
    
    FMResultSet* s = [self.db executeQuery:@"SELECT song FROM ?", table];
    while ([s next])
    {
        NSString* catalogKey = [s stringForColumnIndex:eRadioCatalogKey];
        Song* song = [s objectForColumnIndex:eRadioCatalogSong];
        [self.songs setObject:song forKey:catalogKey];
    }
    
    return self.songs;
}



- (NSArray*)songsForLetter:(NSString*)charIndex fromTable:(NSString*)table
{
    // get cache
    NSArray results = [self.songsForLetter objectForKey:charIndex];
    if (results != nil)
        return results;
    
    results = [NSMutableArray array];
    
    FMResultSet* s = [self.db executeQuery:@"SELECT song FROM ? WHERE nameLetter=?", table, charIndex];
    while ([s next])
    {
        Song* song = [s stringForColumnIndex:eRadioCatalogSong];
        [results addObject:song];
    }
    
    // set cache
    [self.songsForLetter setObject:results forKey:charIndex];
    
    return results;
}


- (NSArray*)artistsForLetter:(NSString*)charIndex fromTable:(NSString*)table
{
    // get cache
    NSArray results = [self.artistsForLetter objectForKey:charIndex];
    if (results != nil)
        return results;
    
    results = [NSMutableArray array];
    
    FMResultSet* s = [self.db executeQuery:@"SELECT artist FROM ? WHERE artistLetter=?", table, charIndex];
    while ([s next])
    {
        NSString* artist = [s stringForColumnIndex:eRadioCatalogArtist];
        [results addObject:song];
    }
    
    // set cache
    [self.artistsForLetter setObject:results forKey:charIndex];
    
    return results;
}











- (void)insertAndEnableSong:(Song*)song;
{
    // be aware of empty artist names, and empty album names
    NSString* artistKey = song.artist;
    if ((artistKey == nil) || (artistKey.length == 0))
    {
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
        DLog(@"insertAndEnableSong: empty artist found!");
    }
    NSString* albumKey = song.album;
    if ((albumKey == nil) || (albumKey.length == 0))
    {
        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
        DLog(@"insertAndEnableSong: empty album found!");
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
        DLog(@"removeSynchronizedSong: empty artist found!");
    }
    NSString* albumKey = song.album;
    if ((albumKey == nil) || (albumKey.length == 0))
    {
        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
        DLog(@"removeSynchronizedSong: empty album found!");
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
    DLog(@"SongCatalog removeSynchronizedSong : may have error no dictionary for the artistKy '%@'", artistKey);
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










- (BOOL)doesDeviceContainSong:(Song*)song
{
    [[TimeProfile main] begin:@"doesDeviceContainSong"];
    
    //LBDEBUG
    DLog(@"doesDeviceContainSong song.name_client %@   song.artist_client '%@'   song.album_client '%@'", song.name_client, song.artist_client, song.album_client);
    
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    
    //LBDEBUG
    NSArray* items = [allSongsQuery items];
    
    if (items.count == 0)
        return NO;
    
    for (MPMediaItem* item in items)
    {
        NSString* song = [item valueForProperty:MPMediaItemPropertyTitle];
        NSString* artist = [item valueForProperty:MPMediaItemPropertyArtist];
        NSString* album  = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
        DLog(@"catalog local.name %@   local.artist '%@'   local.album '%@'", song, artist, album);
    }
    
    
    [allSongsQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:song.artist_client forProperty:MPMediaItemPropertyArtist comparisonType:MPMediaPredicateComparisonEqualTo]];
    [allSongsQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:song.album_client forProperty:MPMediaItemPropertyAlbumTitle comparisonType:MPMediaPredicateComparisonEqualTo]];
    [allSongsQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:song.name_client forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonEqualTo]];
    
    NSArray* songsArray = [allSongsQuery items];
    
    [[TimeProfile main] end:@"doesDeviceContainSong"];
    [[TimeProfile main] logInterval:@"doesDeviceContainSong" inMilliseconds:YES];
    
    
    BOOL doesContain = (songsArray.count > 0);
    
    return doesContain;
}





//
// add a song to the catalog,
//
- (void)catalogWithoutSorting:(Song*)song  usingArtistKey:(NSString*)artistKey andAlbumKey:(NSString*)albumKey
{
    //LBDEBUG
    DevLog(@"catalogWithoutSorting   name '%@'  name_client '%@'         artistKey '%@', artistKey_client '%@'       albumKey '%@', albumKey_client '%@'", song.name, song.name_client, artistKey, song.artist_client, albumKey, song.album_client);
    
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
    DLog(@"selected artist %@", self.selectedArtist);
    
    //DLog(@"artistForSection %@", artistsForSection);
    
    self.selectedArtistRepo = [artistsForSection objectForKey:artistKey];
    
    return YES;
    
}

- (BOOL)selectAlbum:(NSString*)albumKey
{
    if (self.selectedArtistRepo == nil)
        return NO;
    
    self.selectedAlbum = albumKey;
    
    DLog(@"selected album %@", self.selectedAlbum);
    
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
