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
//LBDEBUG TEMPORARLY
//#import "PlaylistMoulinor.h"

@implementation SongLocalCatalog


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
        
        NSLog(@"songKey (%@)    name(%@) nameLetter (%@)     artistKey(%@) artistLetter (%@)      albumKey(%@)", songKey, name, nameLetter, artist, artistLetter, album);
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
    [self threadMatchedSongs:songs];
}


- (void)threadMatchedSongs:(NSDictionary*)songs {
    
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
        
        Song* matchedSong = [songs objectForKey:songLocal.catalogKey];
        
        //        // don't include it if it's included in the matched songs already
        //        if (matchedSong != nil)
        //            continue;
        //
        // we don't do that anymore. We include all the songs, but a visual mark is displayed if the song is
        // in the radio's programming already
        if (matchedSong != nil)
            [songLocal setIsProgrammed:YES];
        
        
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

- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist {
    
    return [self songsForAlbum:album fromArtist:artist fromTable:LOCALCATALOG_TABLE];
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





- (NSArray*)genres {
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT genre FROM %@ ORDER BY genre", LOCALCATALOG_TABLE]];
    
    while ([s next])
    {
        NSString* genre = [s stringForColumnIndex:0];
        assert(genre);
        [results addObject:genre];
    }
    
    // set cache
//    [self.songsForLetter setObject:results forKey:charIndex];
    
    return results;    
}



- (NSArray*)artistsForGenre:(NSString*)genre {
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT DISTINCT artistKey FROM localCatalog WHERE genre=? ORDER BY artistKey", genre];
    
    while ([s next])
    {
        NSString* artist = [s stringForColumnIndex:0];
        assert(artist);
        [results addObject:artist];
    }
    
    // set cache
    //    [self.songsForLetter setObject:results forKey:charIndex];
    
    return results;
}


- (NSArray*)playlists {
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT DISTINCT playlist FROM playlistCatalog ORDER BY playlist"];
    
    //#ifdef DEBUG
    //    DLog(@"songsForLetter FMDB executeQuery '%@'", s.query);
    //#endif
    
    while ([s next])
    {
        //        Song* song = [s objectForColumnIndex:eCatalogSong];
        //        NSString* name = [s stringForColumnIndex:eCatalogName];
        NSString* playlist = [s stringForColumnIndex:0];
        assert(playlist);
        [results addObject:playlist];
    }
    
    // set cache
    //    [self.songsForLetter setObject:results forKey:charIndex];
    
    return results;
    
}


- (NSArray*)artistsForPlaylist:(NSString*)playlist {

    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet* s = [[DataBase main].db executeQuery:@"SELECT DISTINCT localCatalog.songKey, localCatalog.artistKey FROM localCatalog, playlistCatalog WHERE localCatalog.songKey = playlist.songKey  AND playlistCatalog.playlist = ? ORDER BY localCatalog.artistKey", playlist];
    
    while ([s next])
    {
        NSString* artist = [s stringForColumnIndex:1];
        assert(artist);
        [results addObject:artist];
    }
    
    // set cache
    //    [self.songsForLetter setObject:results forKey:charIndex];
    
    return results;

}





@end
