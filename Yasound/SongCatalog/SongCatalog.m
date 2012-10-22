//
//  SongCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "TimeProfile.h"
#import "DataBase.h"


//#define DB_LOG 1

@implementation SongCatalog

@synthesize songsDb;
@synthesize isInCache;
@synthesize indexMap;

// cache
@synthesize catalogCache;

@synthesize selectedArtist;
@synthesize selectedArtistIndexChar;
@synthesize selectedAlbum;
@synthesize selectedGenre = _selectedGenre;
@synthesize selectedPlaylist = _selectedPlaylist;



+ (NSString*)catalogKeyOfSong:(NSString*)name artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey
{
    return [NSString stringWithFormat:@"%@|%@|%@", [name lowercaseString], [artistKey lowercaseString], [albumKey lowercaseString]];
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



- (void)clearCatalogCache {

    // clear related cache
    self.catalogCache = nil;
    self.catalogCache = [NSMutableDictionary dictionary];
}


- (void)setSelectedGenre:(NSString *)selectedGenre {
    
    _selectedGenre = selectedGenre;
    [_selectedGenre retain];
    if (_selectedPlaylist) {
        [_selectedPlaylist release];
        _selectedPlaylist = nil;
    }
}

- (void)setSelectedPlaylist:(NSString *)selectedPlaylist {
    
    _selectedPlaylist = selectedPlaylist;
    [_selectedPlaylist retain];
    if (_selectedGenre) {
        [_selectedGenre release];
        _selectedGenre = nil;
    }
}


















- (id)init {
    
    if (self = [super init]) {
        self.isInCache = NO;
        
        self.songsDb = [NSMutableDictionary dictionary];

        
        self.indexMap = [NSMutableArray array];
        [self initIndexMap];

        self.catalogCache = [NSMutableDictionary dictionary];
        
        _numericSet = [[NSCharacterSet decimalDigitCharacterSet] retain];
        _lowerSet = [[NSCharacterSet lowercaseLetterCharacterSet] retain];
        _upperSet = [[NSCharacterSet uppercaseLetterCharacterSet] retain];
    }
    return self;
}



- (void)dealloc {
    
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
// getters
//

- (NSDictionary*)songsAllFromTable:(NSString*)table
{
    return self.songsDb;
}



- (NSArray*)songsForLetter:(NSString*)charIndex fromTable:(NSString*)table
{
    @synchronized(self) {

        charIndex = [charIndex uppercaseString];
    
        // get cache
        NSString* cacheKey = [NSString stringWithFormat:@"songsForLetter|%@", charIndex];
        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT songKey FROM %@ WHERE nameLetter=? ORDER BY name", table], charIndex];

        
    #ifdef DB_LOG
        DLog(@"\nDB songsForLetter cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)", [s query], charIndex, [charIndex class]);
    #endif
        
        while ([s next])
        {
            NSString* songKey = [s stringForColumnIndex:0];
            assert(songKey);
            Song* song = [self.songsDb objectForKey:songKey];
            
            assert(song);
            [results addObject:song];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        
        return results;
    }
}


- (NSArray*)artistsForLetter:(NSString*)charIndex fromTable:(NSString*)table
{
    @synchronized(self) {

        charIndex = [charIndex uppercaseString];
    
        // get cache
        NSString* cacheKey = [NSString stringWithFormat:@"artistsForLetter|%@", charIndex];
        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT artistKey FROM %@ WHERE artistLetter=? GROUP BY artistKey ORDER BY artistKey", table], charIndex];

    #ifdef DB_LOG
        DLog(@"\nDB artistsForLetter cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)", [s query], charIndex, [charIndex class]);
    #endif
        
        while ([s next])
        {
            NSString* artist = [s stringForColumnIndex:0];
            assert(artist);
            [results addObject:artist];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        
        return results;
    }
}












- (NSArray*)albumsForArtist:(NSString*)artist fromTable:(NSString*)table {

    @synchronized(self) {

        // get cache
        NSString* cacheKey = [NSString stringWithFormat:@"albumsForArtist|%@", artist];
        
        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
    
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT albumKey FROM %@ WHERE artistKey=? ORDER BY albumKey", table], artist];

    #ifdef DB_LOG
        DLog(@"\nDB albumsForArtist cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)", [s query], artist, [artist class]);
    #endif

        while ([s next])
        {
            NSString* album = [s stringForColumnIndex:0];
            assert(album);
            [results addObject:album];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        
        return results;
    }
}



- (NSArray*)albumsForArtist:(NSString*)artist withGenre:genre fromTable:(NSString*)table {
    
    @synchronized(self) {

        // get cache
        NSString* cacheKey = [NSString stringWithFormat:@"albumsForArtist|%@|withGenre|%@", artist, genre];

        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT albumKey FROM %@ WHERE artistKey=? AND genre=? ORDER BY albumKey", table], artist, genre];
        
    #ifdef DB_LOG
        DLog(@"\nDB albumsForArtist cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)    param '%@' (%@)", [s query], artist, [artist class], genre, [genre class]);
    #endif
        
        while ([s next])
        {
            NSString* album = [s stringForColumnIndex:0];
            assert(album);
            [results addObject:album];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        
        return results;
    }
}


- (NSArray*)albumsForArtist:(NSString*)artist withPlaylist:playlist fromTable:(NSString*)table {
    
    @synchronized(self) {

        // get cache
        NSString* cacheKey = [NSString stringWithFormat:@"albumsForArtist|%@|withPlaylist|%@", artist, playlist];

        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT localCatalog.albumKey FROM %@ JOIN playlistCatalog WHERE localCatalog.songKey = playlistCatalog.songKey AND localCatalog.artistKey=? AND playlistCatalog.playlist=? ORDER BY localCatalog.albumKey", table], artist, playlist];
        
    #ifdef DB_LOG
        DLog(@"\nDB albumsForArtist cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)    param '%@' (%@)", [s query], artist, [artist class], playlist, [playlist class]);
    #endif
        
        while ([s next])
        {
            NSString* album = [s stringForColumnIndex:0];
            assert(album);
            [results addObject:album];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        
        return results;
    }
}




- (NSArray*)songsForArtist:(NSString*)artist fromTable:(NSString*)table {
    
    @synchronized(self) {

        NSString* cacheKey = [NSString stringWithFormat:@"songsForArtist|%@", artist];
        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT songKey FROM %@ WHERE artistKey=? ORDER BY name", table], artist];
        
    #ifdef DB_LOG
        DLog(@"\nDB songsForArtist cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)", [s query], artist, [artist class]);
    #endif
        
        while ([s next])
        {
            NSString* songKey = [s stringForColumnIndex:0];
            assert(songKey);
            [results addObject:songKey];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        return results;
    }
}



- (NSArray*)songsForArtist:(NSString*)artist withGenre:(NSString*)genre fromTable:(NSString*)table {

    @synchronized(self) {

        NSString* cacheKey = [NSString stringWithFormat:@"songsForArtist|%@|withGenre|%@", artist, genre];
        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
        NSMutableArray* results = [NSMutableArray array];
        
       FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT songKey FROM localCatalog WHERE artistKey=? AND genre=? ORDER BY name", artist, genre];
        
        
    #ifdef DB_LOG
        DLog(@"\nDB songsForArtist cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)    param '%@' (%@)", [s query], artist, [artist class], genre, [genre class]);
    #endif
        
        while ([s next])
        {
            NSString* songKey = [s stringForColumnIndex:0];
            assert(songKey);
            [results addObject:songKey];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        return results;
    }
}



- (NSArray*)songsForArtist:(NSString*)artist withPlaylist:(NSString*)playlist fromTable:(NSString*)table {
    
    @synchronized(self) {

        NSString* cacheKey = [NSString stringWithFormat:@"songsForArtist|%@|withPlaylist|%@", artist, playlist];
        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT localCatalog.songKey FROM %@ JOIN playlistCatalog WHERE localCatalog.artistKey=? AND localCatalog.songKey=playlistCatalog.songKey AND playlistCatalog.playlist=? ORDER BY name", table], artist, playlist];
        
    #ifdef DB_LOG
        DLog(@"\nDB songsForArtist cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)    param '%@' (%@)", [s query], artist, [artist class], playlist, [playlist class]);
    #endif
        
        while ([s next])
        {
            NSString* songKey = [s stringForColumnIndex:0];
            assert(songKey);
            [results addObject:songKey];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        return results;
    }
}





- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist fromTable:(NSString*)table {
    
    @synchronized(self) {

        NSString* cacheKey = [NSString stringWithFormat:@"songsForAlbum|%@|fromArtist|%@", album, artist];
        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
        
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT songKey FROM %@ WHERE albumKey=? AND artistKey=? ORDER BY name", table], album, artist];
        
    #ifdef DB_LOG
        DLog(@"\nDB songsForAlbum cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)    param '%@' (%@)", [s query], album, [album class], artist, [artist class]);
    #endif
        
        while ([s next])
        {
            NSString* songKey = [s stringForColumnIndex:0];
            assert(songKey);
            [results addObject:songKey];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        return results;
    }
}


- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withGenre:(NSString*)genre fromTable:(NSString*)table {
    
    @synchronized(self) {

        NSString* cacheKey = [NSString stringWithFormat:@"songsForAlbum|%@|fromArtist|%@|withGenre|%@", album, artist, genre];
        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT songKey FROM %@ WHERE albumKey=? AND artistKey=? AND genre=? ORDER BY name", table], album, artist, genre];
        
    #ifdef DB_LOG
        DLog(@"\nDB songsForAlbum cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)    param '%@' (%@)   param '%@' (%@)", [s query], album, [album class], artist, [artist class], genre, [genre class]);
    #endif
        
        while ([s next])
        {
            NSString* songKey = [s stringForColumnIndex:0];
            assert(songKey);
            [results addObject:songKey];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        return results;
    }
}


- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withPlaylist:(NSString*)playlist fromTable:(NSString*)table {
    
    @synchronized(self) {

        NSString* cacheKey = [NSString stringWithFormat:@"songsForAlbum|%@|fromArtist|%@", album, artist];
        NSArray* cache = [self.catalogCache objectForKey:cacheKey];
        if (cache != nil)
            return cache;
    
        NSMutableArray* results = [NSMutableArray array];
        
        FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT localCatalog.songKey FROM %@ JOIN playlistCatalog WHERE localCatalog.albumKey=? AND localCatalog.artistKey=? AND localCatalog.songKey = playlistCatalog.songKey AND playlistCatalog.playlist=? ORDER BY localCatalog.name", table], album, artist, playlist];
        
    #ifdef DB_LOG
        DLog(@"\nDB songsForAlbum cacheKey '%@'", cacheKey);
        DLog(@"DB request '%@'   param '%@' (%@)    param '%@' (%@)   param '%@' (%@)", [s query], album, [album class], artist, [artist class], playlist, [playlist class]);
    #endif
        
        while ([s next])
        {
            NSString* songKey = [s stringForColumnIndex:0];
            assert(songKey);
            [results addObject:songKey];
        }
        
        // set cache
        [self.catalogCache setObject:results forKey:cacheKey];
        return results;
    }
}







//...................................................................
//
// setters
//


- (void)beginTransaction {

    [[DataBase main].db beginTransaction];
}

- (void)commit {
    
    [[DataBase main].db commit];
}



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
        
    NSString* nameChar = [NSString stringWithFormat:@"%C", nameLetter];

    
    // first letter of artist's name
    firstRelevantWord = [artistKey uppercaseString];
    assert(firstRelevantWord.length > 0);
    unichar artistLetter = [firstRelevantWord characterAtIndex:0];
    
    if ([_numericSet characterIsMember:artistLetter])
        artistLetter = '-';
    else if (![_lowerSet characterIsMember:artistLetter] && ![_upperSet characterIsMember:artistLetter])
        artistLetter = '#';
    
    NSString* artistChar = [NSString stringWithFormat:@"%C", artistLetter];

    BOOL res = [[DataBase main].db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ VALUES (?,?,?,?,?,?,?)", table], songKey, song.name, nameChar, song.artist, artistChar, song.album, song.genre];
    
    
    // waiting for better a way to do that
    [song setEnabled:[NSNumber numberWithBool:YES]];
    

    if (!res)
        DLog(@"addSong, %d:%@", [[DataBase main].db lastErrorCode], [[DataBase main].db lastErrorMessage]);
    else
        [self.songsDb setObject:song forKey:songKey];
    

    return res;
}







//...............................................................................................
//
// tools to handle items selection
//

- (BOOL)selectArtist:(NSString*)artistKey withCharIndex:(NSString*)charIndex
{
    // first, reset album selection
    self.selectedAlbum = nil;
    
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
    return nil;
}



- (BOOL)removeSong:(NSString*)songKey forTable:(NSString*)table {
    
    assert(songKey);
    
    BOOL res = [[DataBase main].db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE songKey=?", table], songKey];
    
    if (!res)
        DLog(@"removeSong, %d:%@", [[DataBase main].db lastErrorCode], [[DataBase main].db lastErrorMessage]);
    else
        [self.songsDb removeObjectForKey:songKey];
    
    
    return res;

    
}





@end
