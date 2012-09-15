//
//  SongLocalCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongLocalCatalog.h"
#import "TimeProfile.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SongLocal.h"
#import "DataBase.h"
#import "RootViewController.h"
#import "SongRadioCatalog.h"
//LBDEBUG TEMPORARLY
//#import "PlaylistMoulinor.h"

@implementation SongLocalCatalog


//@synthesize genres;
//@synthesize playlists;
//@synthesize artistsForGenre;
//@synthesize songsForGenre;
//@synthesize artistsForPlaylist;
//@synthesize songsForPlaylist;


static SongLocalCatalog* _main = nil;


+ (SongLocalCatalog*)main {
    
    if (_main == nil) {
        _main = [[SongLocalCatalog alloc] init];
    }
    return _main;
}


+ (void)releaseCatalog {
    
    if (_main == nil)
        return;
    
    [_main release];
    _main = nil;
}

- (void)dealloc {
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (id)init {
    
    if (self = [super init]) {
     
//        self.artistsForGenre = [NSMutableDictionary dictionary];
//        self.songsForGenre = [NSMutableDictionary dictionary];
//        self.artistsForPlaylist = [NSMutableDictionary dictionary];
//        self.songsForPlaylist = [NSMutableDictionary dictionary];

//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongAddToProgramming:) name:NOTIF_PROGAMMING_SONG_ADDED object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongRemoveFromProgramming:) name:NOTIF_PROGAMMING_SONG_REMOVED object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifSongUpdated:) name:NOTIF_PROGAMMING_SONG_UPDATED object:nil];
    }
    return self;
}


- (void)dump
{
    FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT * FROM localCatalog"];
    while ([s next])
    {
        NSString* songKey = [SongCatalog shortString:[s stringForColumnIndex:eCatalogSongKey]];
        NSString* name = [SongCatalog shortString:[s stringForColumnIndex:eCatalogName]];
        NSString* nameLetter = [SongCatalog shortString:[s stringForColumnIndex:eCatalogNameLetter]];
        NSString* artist = [SongCatalog shortString:[s stringForColumnIndex:eCatalogArtistKey]];
        NSString* artistLetter = [SongCatalog shortString:[s stringForColumnIndex:eCatalogArtistLetter]];
        NSString* album = [SongCatalog shortString:[s stringForColumnIndex:eCatalogAlbumKey]];
        NSString* genre = [SongCatalog shortString:[s stringForColumnIndex:eCatalogGenre]];
        
        NSLog(@"songKey (%@)    name(%@) nameLetter (%@)     artistKey(%@) artistLetter (%@)      albumKey(%@)     genre(%@)", songKey, name, nameLetter, artist, artistLetter, album, genre);
    }

    
    NSLog(@"----------------------------------\n");
}





- (void)initFromMatchedSongs:(NSDictionary*)songs target:(id)aTarget action:(SEL)anAction {
    
    self.target = aTarget;
    self.action = anAction;
    
    // return cached data
    if (self.isInCache)
    {
        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        [info setObject:[NSNumber numberWithInteger:self.songsDb.count] forKey:@"count"];
        [info setObject:@""  forKey:@"error"];
        [info setObject:[NSNumber numberWithBool:YES]  forKey:@"success"];
        [self.target performSelector:self.action withObject:info];
        return;
    }

    //[NSThread detachNewThreadSelector:@selector(threadMatchedSongs:) toTarget:self withObject:songs];
//    [self threadMatchedSongs:songs];
    [self threadMatchedSongs];
}


//- (void)threadMatchedSongs:(NSDictionary*)songs {
- (void)threadMatchedSongs {
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	
    
    [[TimeProfile main] begin:@"iTunesQuery"];
    
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    NSArray* songsArray = [allSongsQuery items];
    
    [[TimeProfile main] end:@"iTunesQuery"];
    [[TimeProfile main] logInterval:@"iTunesQuery" inMilliseconds:NO];
    
    NSInteger nbSongs = 0;
    
    [self beginTransaction];
    
    // list all local songs from albums
    for (MPMediaItem* item in songsArray)
    {
        SongLocal* songLocal = [[SongLocal alloc] initWithMediaItem:item];
        
//        Song* matchedSong = [songs objectForKey:songLocal.catalogKey];
        
        //        // don't include it if it's included in the matched songs already
        //        if (matchedSong != nil)
        //            continue;
        //
        // we don't do that anymore. We include all the songs, but a visual mark is displayed if the song is
        // in the radio's programming already
//        if (matchedSong != nil)
//            [songLocal setIsProgrammed:YES];
        
        
        // REMEMBER THAT HERE, songLocal is SongLocal*
        
        BOOL res = [self addSong:songLocal forTable:LOCALCATALOG_TABLE songKey:songLocal.catalogKey artistKey:songLocal.artistKey albumKey:songLocal.albumKey];
        nbSongs++;
    }
    

    // list all playlists
    MPMediaQuery* playlistQuery = [MPMediaQuery playlistsQuery];
    NSArray* playlists = [playlistQuery collections];
    
    // for each playlist
    for (MPMediaPlaylist* playlist in playlists) {
        
        // playlist name
        NSString* playlistName = [playlist valueForProperty: MPMediaPlaylistPropertyName];

        // for all items from playlist
        NSArray* items = [playlist items];
        for (MPMediaItem* item in items) {
     
            NSString* songName = [item valueForProperty:MPMediaItemPropertyTitle];
            NSString* artistKey = [item valueForProperty:MPMediaItemPropertyArtist];
            NSString* albumKey = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
            
            if ((artistKey == nil) || (artistKey.length == 0))
                artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
            
            if ((albumKey == nil) || (albumKey.length == 0))
                albumKey =  NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
            
            // get songKey
            NSString* songKey = [SongCatalog catalogKeyOfSong:songName artistKey:artistKey albumKey:albumKey];
            
            // and associate the playlist and the song, in the playlist database
            [self addSong:songKey forPlaylist:playlistName];
        }
    }

    
    
    [self commit];
    
    
//    if (nbSongs > 0)
        self.isInCache = YES;
    
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    [info setObject:[NSNumber numberWithInteger:self.songsDb.count] forKey:@"count"];
    [info setObject:@""  forKey:@"error"];
    [info setObject:[NSNumber numberWithBool:YES]  forKey:@"success"];
    [self.target performSelectorOnMainThread:self.action withObject:info waitUntilDone:false];
    
    [pool release];
}






- (BOOL)doesDeviceContainSong:(Song*)song
{
    [[TimeProfile main] begin:@"doesDeviceContainSong"];
    
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    
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



- (NSArray*)songsForLetter:(NSString*)charIndex {
    
    return [self songsForLetter:charIndex fromTable:LOCALCATALOG_TABLE];
}


- (NSArray*)artistsForLetter:(NSString*)charIndex {
    
    return [self artistsForLetter:charIndex fromTable:LOCALCATALOG_TABLE];
}


- (NSArray*)albumsForArtist:(NSString*)artist {
    
    return [self albumsForArtist:artist fromTable:LOCALCATALOG_TABLE];
}
- (NSArray*)albumsForArtist:(NSString*)artist withGenre:(NSString*)genre {
    
    return [self albumsForArtist:artist withGenre:genre fromTable:LOCALCATALOG_TABLE];
}
- (NSArray*)albumsForArtist:(NSString*)artist withPlaylist:(NSString*)playlist {
    
    return [self albumsForArtist:artist withPlaylist:playlist fromTable:LOCALCATALOG_TABLE];
}




- (NSArray*)songsForArtist:(NSString*)artist {
    
    return [self songsForArtist:artist fromTable:LOCALCATALOG_TABLE];
}

- (NSArray*)songsForArtist:(NSString*)artist withGenre:(NSString*)genre {
    
    return [self songsForArtist:artist withGenre:genre fromTable:LOCALCATALOG_TABLE];
}

- (NSArray*)songsForArtist:(NSString*)artist withPlaylist:(NSString*)playlist {
    
    return [self songsForArtist:artist withPlaylist:playlist fromTable:LOCALCATALOG_TABLE];
}



- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist {
    
    return [self songsForAlbum:album fromArtist:artist fromTable:LOCALCATALOG_TABLE];
}

- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withGenre:(NSString*)genre {
    
    return [self songsForAlbum:album fromArtist:artist withGenre:genre fromTable:LOCALCATALOG_TABLE];
}

- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withPlaylist:(NSString*)playlist {
    
    return [self songsForAlbum:album fromArtist:artist withPlaylist:playlist fromTable:LOCALCATALOG_TABLE];
}


- (NSDictionary*)songsAll {
    
    return [self songsAllFromTable:LOCALCATALOG_TABLE];
}


- (BOOL)addSong:(Song*)song songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey {
    
    return [self addSong:song forTable:LOCALCATALOG_TABLE songKey:songKey artistKey:artistKey albumKey:albumKey];
}

- (BOOL)addSong:(NSString*)songKey forPlaylist:(NSString*)playlist {
    
    assert(songKey);
    assert(playlist);
    
    BOOL res = [[DataBase main].db executeUpdate:@"INSERT INTO playlistCatalog VALUES (?,?)", songKey, playlist];
    
    if (!res)
        DLog(@"addSongForPlaylist, %d:%@", [[DataBase main].db lastErrorCode], [[DataBase main].db lastErrorMessage]);
    
    return res;    
}





- (NSArray*)genresAll {
    
//    if (self.genres != nil)
//        return self.genres;
    NSString* cacheKey = [NSString stringWithFormat:@"genres"];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;

    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT genre FROM %@ ORDER BY genre", LOCALCATALOG_TABLE]];
    
    while ([s next])
    {
        NSString* genre = [s stringForColumnIndex:0];
        assert(genre);
        [results addObject:genre];
    }
    
    // set cache
//    self.genres = results;
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;    
}



- (NSArray*)artistsForGenre:(NSString*)genre {
    
//    NSMutableArray* results = [self.artistsForGenre objectForKey:genre];
    NSString* cacheKey = [NSString stringWithFormat:@"artistsForGenre|%@", genre];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT DISTINCT artistKey FROM localCatalog WHERE genre=? ORDER BY artistKey", genre];
    
    while ([s next])
    {
        NSString* artist = [s stringForColumnIndex:0];
        assert(artist);
        [results addObject:artist];
    }
    
    // set cache
//    [self.artistsForGenre setObject:results forKey:genre];
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;
}


- (NSArray*)songsForGenre:(NSString*)genre {
    
//    NSMutableArray* results = [self.songsForGenre objectForKey:genre];
    NSString* cacheKey = [NSString stringWithFormat:@"songsForGenre|%@", genre];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT songKey FROM localCatalog WHERE genre=? ORDER BY name", genre];
    
    while ([s next])
    {
        NSString* songKey = [s stringForColumnIndex:0];
        assert(songKey);
        [results addObject:songKey];
    }
    
    // set cache
//    [self.songsForGenre setObject:results forKey:genre];
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;
}




- (NSArray*)playlistsAll {
    
//    if (self.playlists != nil)
//        return self.playlists;
    NSString* cacheKey = [NSString stringWithFormat:@"playlists"];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT DISTINCT playlist FROM playlistCatalog ORDER BY playlist"];
    
    while ([s next])
    {
        NSString* playlist = [s stringForColumnIndex:0];
        assert(playlist);
        [results addObject:playlist];
    }
    
    // set cache
//    self.playlists = results;
    [self.catalogCache setObject:results forKey:cacheKey];

    return results;
    
}


- (NSArray*)artistsForPlaylist:(NSString*)playlist {

//    NSMutableArray* results = [self.artistsForPlaylist objectForKey:playlist];
//    
//    if (results != nil)
//        return results;
    NSString* cacheKey = [NSString stringWithFormat:@"artistsForPlaylist|%@", playlist];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT DISTINCT localCatalog.artistKey FROM localCatalog JOIN playlistCatalog WHERE localCatalog.songKey = playlistCatalog.songKey  AND playlistCatalog.playlist = ? ORDER BY localCatalog.artistKey", playlist];
    
    while ([s next])
    {
        NSString* artist = [s stringForColumnIndex:0];
        assert(artist);
        [results addObject:artist];
    }
    
    // set cache
//    [self.artistsForPlaylist setObject:results forKey:playlist];
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;

}


- (NSArray*)songsForPlaylist:(NSString*)playlist {
    
//    NSMutableArray* results = [self.songsForPlaylist objectForKey:playlist];
//    
//    if (results != nil)
//        return results;
    NSString* cacheKey = [NSString stringWithFormat:@"songsForPlaylist|%@", playlist];
    NSArray* cache = [self.catalogCache objectForKey:cacheKey];
    if (cache != nil)
        return cache;
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT localCatalog.songKey FROM localCatalog JOIN playlistCatalog WHERE localCatalog.songKey = playlistCatalog.songKey  AND playlistCatalog.playlist = ? ORDER BY localCatalog.name", playlist];
    
    while ([s next])
    {
        NSString* songKey = [s stringForColumnIndex:0];
        assert(songKey);
        [results addObject:songKey];
    }
    
    // set cache
//    [self.songsForPlaylist setObject:results forKey:playlist];
    [self.catalogCache setObject:results forKey:cacheKey];
    
    return results;
    
}












#pragma mark - Notifications



- (void)updateSongAddedToProgramming:(Song*)song {
    
    assert(song);
    assert([song isKindOfClass:[SongLocal class]]);
    
//    [song setIsProgrammed:YES];
}


- (void)updateSongRemovedFromProgramming:(Song*)song {
    
    assert(song);
    assert([song isKindOfClass:[Song class]]);

//    [song setIsProgrammed:NO];
}


- (void)updateSongUpdated:(SongLocal*)song {
    
    assert(song);
    assert([song isKindOfClass:[SongLocal class]]);

    Song* matchedSong = [[SongRadioCatalog main].matchedSongs objectForKey:song.catalogKey];
    
//    if (matchedSong != nil)
//        [song setIsProgrammed:YES];
//    else
//        [song setIsProgrammed:NO];
}



//- (BOOL)removeSong:(NSString*)songKey {
//    
//    [self removeSong:songKey forTable:LOCALCATALOG_TABLE];
//}



@end
