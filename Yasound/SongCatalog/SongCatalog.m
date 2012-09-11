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
        
//        [self initDB];
        self.songsDb = [NSMutableDictionary dictionary];

        
        self.indexMap = [NSMutableArray array];
        [self initIndexMap];

        self.catalogCache = [NSMutableDictionary dictionary];
        
//        self.songsForLetter = [NSMutableDictionary dictionary];
//        self.artistsForLetter = [NSMutableDictionary dictionary];
//        self.albumsForArtist = [NSMutableDictionary dictionary];

        _numericSet = [[NSCharacterSet decimalDigitCharacterSet] retain];
        _lowerSet = [[NSCharacterSet lowercaseLetterCharacterSet] retain];
        _upperSet = [[NSCharacterSet uppercaseLetterCharacterSet] retain];
        

    }
    return self;
}



- (void)dealloc {
    
//    [self.db close];
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
//    NSArray* cache = [self.songsForLetter objectForKey:charIndex];
    NSString* cacheKey = [NSString stringWithFormat:@"songsForLetter|%@", charIndex];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT songKey FROM %@ WHERE nameLetter=? ORDER BY name", table], charIndex];

//#ifdef DEBUG
//    DLog(@"songsForLetter FMDB executeQuery '%@'", s.query);
//#endif
    
    while ([s next])
    {
//        Song* song = [s objectForColumnIndex:eCatalogSong];
//        NSString* name = [s stringForColumnIndex:eCatalogName];
        NSString* songKey = [s stringForColumnIndex:0];
        assert(songKey);
        Song* song = [self.songsDb objectForKey:songKey];
        assert(song);
        [results addObject:song];
    }
    
    // set cache
//    [self.songsForLetter setObject:results forKey:charIndex];
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;
}


- (NSArray*)artistsForLetter:(NSString*)charIndex fromTable:(NSString*)table
{
    charIndex = [charIndex uppercaseString];
    
    // get cache
//    NSArray* cache = [self.artistsForLetter objectForKey:charIndex];
    NSString* cacheKey = [NSString stringWithFormat:@"artistsForLetter|%@", charIndex];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT artistKey FROM %@ WHERE artistLetter=? GROUP BY artistKey ORDER BY artistKey", table], charIndex];
    while ([s next])
    {
//        NSString* artist = [s stringForColumnIndex:eCatalogArtistKey];
        //LBDEBUG
//        NSString* test = [s stringForColumnIndex:0];
        NSString* artist = [s stringForColumnIndex:0];
        assert(artist);
        [results addObject:artist];
    }
    
    // set cache
//    [self.artistsForLetter setObject:results forKey:charIndex];
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;
}












- (NSArray*)albumsForArtist:(NSString*)artist fromTable:(NSString*)table {

    // get cache
//    NSArray* cache = [self.albumsForArtist objectForKey:artist];
    NSString* cacheKey = [NSString stringWithFormat:@"albumsForArtist|%@", artist];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT albumKey FROM %@ WHERE artistKey=? ORDER BY albumKey", table], artist];
    while ([s next])
    {
        //        NSString* artist = [s stringForColumnIndex:eCatalogArtistKey];
        //LBDEBUG
        //        NSString* test = [s stringForColumnIndex:0];
        NSString* album = [s stringForColumnIndex:0];
        assert(album);
        [results addObject:album];
    }
    
    // set cache
//    [self.albumsForArtist setObject:results forKey:artist];
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;
}



- (NSArray*)albumsForArtist:(NSString*)artist withGenre:genre fromTable:(NSString*)table {
    
    // get cache
//    NSArray* cache = [self.albumsForArtist objectForKey:artist];
    NSString* cacheKey = [NSString stringWithFormat:@"albumsForArtist|%@|withGenre|%@", artist, genre];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT albumKey FROM %@ WHERE artistKey=? AND genre=? ORDER BY albumKey", table], artist, genre];
    while ([s next])
    {
        //        NSString* artist = [s stringForColumnIndex:eCatalogArtistKey];
        //LBDEBUG
        //        NSString* test = [s stringForColumnIndex:0];
        NSString* album = [s stringForColumnIndex:0];
        assert(album);
        [results addObject:album];
    }
    
    // set cache
//    [self.albumsForArtist setObject:results forKey:artist];
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;
}


- (NSArray*)albumsForArtist:(NSString*)artist withPlaylist:playlist fromTable:(NSString*)table {
    
    // get cache
//    NSArray* cache = [self.albumsForArtist objectForKey:artist];
    NSString* cacheKey = [NSString stringWithFormat:@"albumsForArtist|%@|withPlaylist|%@", artist, playlist];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT localCatalog.albumKey FROM %@ JOIN playlistCatalog WHERE localCatalog.songKey = playlistCatalog.songKey AND localCatalog.artistKey=? AND playlistCatalog.playlist=? ORDER BY localCatalog.albumKey", table], artist, playlist];
    while ([s next])
    {
        //        NSString* artist = [s stringForColumnIndex:eCatalogArtistKey];
        //LBDEBUG
        //        NSString* test = [s stringForColumnIndex:0];
        NSString* album = [s stringForColumnIndex:0];
        assert(album);
        [results addObject:album];
    }
    
    // set cache
//    [self.albumsForArtist setObject:results forKey:artist];
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;
}





- (NSArray*)songsForArtist:(NSString*)artist withGenre:(NSString*)genre fromTable:(NSString*)table {
    
    NSString* cacheKey = [NSString stringWithFormat:@"songsForArtist|%@|withGenre|%@", artist, genre];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT songKey FROM %@ WHERE artistKey=? AND genre=? ORDER BY name", table], artist, genre];
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



- (NSArray*)songsForArtist:(NSString*)artist withPlaylist:(NSString*)playlist fromTable:(NSString*)table {
    
    NSString* cacheKey = [NSString stringWithFormat:@"songsForArtist|%@|withPlaylist|%@", artist, playlist];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT localCatalog.songKey FROM %@ JOIN playlistCatalog WHERE localCatalog.artistKey=? AND localCatalog.songKey=playlistCatalog.songKey AND playlistCatalog.playlist=? ORDER BY name", table], artist, playlist];
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





- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist fromTable:(NSString*)table {
    
    NSString* cacheKey = [NSString stringWithFormat:@"songsForAlbum|%@|fromArtist|%@", album, artist];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
        
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT songKey FROM %@ WHERE albumKey=? AND artistKey=? ORDER BY name", table], album, artist];
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


- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withGenre:(NSString*)genre fromTable:(NSString*)table {
    
    NSString* cacheKey = [NSString stringWithFormat:@"songsForAlbum|%@|fromArtist|%@|withGenre|%@", album, artist, genre];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT songKey FROM %@ WHERE albumKey=? AND artistKey=? AND genre=? ORDER BY name", table], album, artist, genre];
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


- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withPlaylist:(NSString*)playlist fromTable:(NSString*)table {
    
    NSString* cacheKey = [NSString stringWithFormat:@"songsForAlbum|%@|fromArtist|%@", album, artist];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT localCatalog.songKey FROM %@ JOIN playlistCatalog WHERE localCatalog.albumKey=? AND localCatalog.artistKey=? AND localCatalog.songKey = playlistCatalog.songKey AND playlistCatalog.playlist=? ORDER BY localCatalog.name", table], album, artist, playlist];
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



- (void)insertAndEnableSong:(Song*)song;
{
    assert(0);
    return;
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
    assert(0);
    return;
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
    assert(0);
    return NO;
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
    assert(0);
    return;
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
    assert(0);
    return;
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

- (BOOL)selectArtist:(NSString*)artistKey withCharIndex:(NSString*)charIndex
//- (BOOL)selectArtist:(NSString*)artistKey
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








- (BOOL)removeSong:(NSString*)songKey forTable:(NSString*)table {
    
    assert(songKey);
    
    BOOL res = [[DataBase main].db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE songKey=?", table], songKey];
    
    if (!res)
        DLog(@"removeSong, %d:%@", [[DataBase main].db lastErrorCode], [[DataBase main].db lastErrorMessage]);
    else
        [self.songsDb removeObjectForKey:songKey];
    
    
    return res;

    
}


//
//@property (nonatomic, retain) NSMutableDictionary* songsDb;
//
////@property (nonatomic, retain) NSMutableDictionary* songs;
//
//// NSString* letter -> NSArray[NSString* songKey]
//@property (nonatomic, retain) NSMutableDictionary* songsForLetter;
//
//// NSString* letter -> NSArray[NSString* artistKey]
//@property (nonatomic, retain) NSMutableDictionary* artistsForLetter;
//
//// NSString* artistKey -> NSArray[NSString* albumKey]
//@property (nonatomic, retain) NSMutableDictionary* albumsForArtist;
//
//// NSString* artistKey -> NSDictionary [ NSString* albumKey -> NSArray[NSString* songKey]]
//@property (nonatomic, retain) NSMutableDictionary* songsForArtistAlbum;
//



@end
