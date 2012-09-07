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
    FMResultSet* s = [self.db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", LOCALCATALOG_TABLE]];
    while ([s next])
    {
        NSString* name = [SongCatalog shortString:[s stringForColumnIndex:eCatalogName]];
        NSString* artist = [SongCatalog shortString:[s stringForColumnIndex:eCatalogArtistKey]];
        NSString* album = [SongCatalog shortString:[s stringForColumnIndex:eCatalogAlbumKey]];
        
        NSLog(@"name(%@)  artist(%@)   album(%@)", name, artist, album);
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
    
    [NSThread detachNewThreadSelector:@selector(threadMatchedSongs:) toTarget:self withObject:songs];
}


- (void)threadMatchedSongs:(NSDictionary*)songs {
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	
    
    [[TimeProfile main] begin:@"iTunesQuery"];
    
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    NSArray* songsArray = [allSongsQuery items];
    
    [[TimeProfile main] end:@"iTunesQuery"];
    [[TimeProfile main] logInterval:@"iTunesQuery" inMilliseconds:NO];
    
    NSInteger nbSongs = 0;
    
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
        
        
        //LBDEBUG TODO : CLEANING
        //        // before putting this song into the catalog,
        //        // check if it's not uploading already.
        //        Song* uploadingSong = [[SongUploadManager main] getUploadingSong:songLocal.name artist:songLocal.artist album:songLocal.album];
        //        if (uploadingSong != nil)
        //            [songLocal setUploading:YES];
        
        // REMEMBER THAT HERE, songLocal is SongLocal*
        
//        [self catalogWithoutSorting:songLocal usingArtistKey:songLocal.artistKey andAlbumKey:songLocal.albumKey];

        BOOL res = [self addSong:songLocal forTable:RADIOCATALOG_TABLE songKey:songLocal.catalogKey artistKey:songLocal.artistKey albumKey:songLocal.albumKey];
        nbSongs++;
    }
        
    
//    if (nbSongs > 0)
        self.isInCache = YES;
    
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    [info setObject:[NSNumber numberWithInteger:nbSongs] forKey:@"count"];
    [info setObject:@""  forKey:@"error"];
    [info setObject:[NSNumber numberWithBool:YES]  forKey:@"success"];
    [self.target performSelectorOnMainThread:self.action withObject:info waitUntilDone:false];
    
    [pool release];
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
    
    return [self songsForAlbum:album fromArtist:artist fromTable:RADIOCATALOG_TABLE];
}

- (NSDictionary*)songsAll {
    
    return [self songsAllFromTable:LOCALCATALOG_TABLE];
}


- (BOOL)addSong:(Song*)song songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey {
    
    return [self addSong:song forTable:RADIOCATALOG_TABLE songKey:songKey artistKey:artistKey albumKey:albumKey];
}



@end
