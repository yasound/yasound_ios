//
//  SongRadioCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongRadioCatalog.h"
#import "YasoundDataProvider.h"
#import "DataBase.h"
#import "RootViewController.h"


@implementation SongRadioCatalog


@synthesize radio;
@synthesize target;
@synthesize action;
@synthesize matchedSongs;

static SongRadioCatalog* _main = nil;




+ (SongRadioCatalog*)main {

    if (_main == nil) {
        _main = [[SongRadioCatalog alloc] init];
    }
    return _main;
}


+ (void)releaseCatalog {
    
    if (_main == nil)
        return;
    
    // first reset database for this catalog
    [[DataBase main] deleteRadioCatalog];

    [[DataBase main].db beginTransaction];
    [[DataBase main] createRadioCatalog];
    [[DataBase main].db commit];

    
    
    // then, reset the catalog itself
    [_main release];
    _main = nil;
}



- (void)dealloc {
    
    [super dealloc];
}


- (id)init {
    
    if (self = [super init]) {
        
        self.catalogCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dump
{
    NSLog(@"\nDB radioCatalog dump:");
    
    FMResultSet* s = [[DataBase main].db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", RADIOCATALOG_TABLE]];
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



- (void)initForRadio:(YaRadio*)radio target:(id)aTarget action:(SEL)anAction {
    
    self.radio = radio;
    self.target = aTarget;
    self.action = anAction;
    
    // return cached data
    if (self.isInCache)
    {
        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        [info setObject:[NSNumber numberWithInteger:self.matchedSongs.count] forKey:@"count"];
        [info setObject:@""  forKey:@"error"];
        [info setObject:[NSNumber numberWithBool:YES]  forKey:@"success"];
        [self.target performSelector:self.action withObject:info];
        return;
    }
    
    _data = [[NSMutableArray alloc] init];
    [_data retain];
    
    _nbReceivedData = 0;
    _nbPlaylists = 0;
    
    self.matchedSongs = [NSMutableDictionary dictionary];
    
    [[YasoundDataProvider main] playlistsForRadio:radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        NSArray* playlists = nil;
        if (error)
        {
            DLog(@"playlists for radio error: %d - %@", error.code, error.domain);
            playlists = nil;
        }
        else if (status != 200)
        {
            DLog(@"playlists for radio error: resposne status %d", status);
            playlists = nil;
        }
        else
        {
            Container* playlistContainer = [response jsonToContainer:[Playlist class]];
            if (!playlistContainer || !playlistContainer.objects)
                playlists = nil;
            else
            {
                playlists = playlistContainer.objects;
            }
        }
        if (playlists == nil)
            _nbPlaylists = 0;
        else
            _nbPlaylists = playlists.count;
        
        DLog(@"received %d playlists", _nbPlaylists);
        if (_nbPlaylists == 0)
        {
            NSMutableDictionary* info = [NSMutableDictionary dictionary];
            [info setObject:[NSNumber numberWithInteger:0] forKey:@"count"];
            [info setObject:NSLocalizedString(@"ProgrammingView_error_no_playlist_message", nil)  forKey:@"error"];
            [info setObject:[NSNumber numberWithBool:NO]  forKey:@"success"];
            [self.target performSelector:self.action withObject:info];
            return;
        }
        
        for (Playlist* playlist in playlists)
        {
            DLog(@"playlist %@ :", playlist.name);            
            [[YasoundDataProvider main] matchedSongsForPlaylist:playlist withCompletionBlock:^(int status, NSString* response, NSError* error){
                [self matchedSongsReceivedWithStatus:status response:response error:error];
            }];
        }
    }];
}

- (void)matchedSongsReceivedWithStatus:(int)status response:(NSString*)response error:(NSError*)error
{
    NSArray* receivedSongs = nil;
    if (error)
    {
        DLog(@"matched songs error: %d - %@", error.code, error.domain);
        receivedSongs = nil;
    }
    else if (status != 200)
    {
        DLog(@"matched songs error: response status %d", status);
        receivedSongs = nil;
    }
    else
    {
        Container* songContainer = [response jsonToContainer:[Song class]];
        if (!songContainer || !songContainer.objects)
        {
            DLog(@"matched songs error: cannot parse response %@", response);
            receivedSongs = nil;
        }
        else
        {
            receivedSongs = songContainer.objects;
        }
    }
    
    if (!receivedSongs)
    {
        NSMutableDictionary* actionInfo = [NSMutableDictionary dictionary];
        [actionInfo setObject:[NSNumber numberWithInteger:0] forKey:@"count"];
        [actionInfo setObject:NSLocalizedString(@"ProgrammingView_error_message", nil)  forKey:@"error"];
        [actionInfo setObject:[NSNumber numberWithBool:NO]  forKey:@"success"];
        
        DLog(@"matchedSongsReceveived : REQUEST FAILED for playlist nb %d", _nbReceivedData);
        
        if ([self.target respondsToSelector:self.action])
            [self.target performSelector:self.action withObject:actionInfo];
        return;
    }
    
    DLog(@"received playlist : nb %d : %d songs",  _nbReceivedData, receivedSongs.count);
    _nbReceivedData++;
    
    if (receivedSongs.count != 0)
        [_data addObject:receivedSongs];
    
    if (_nbReceivedData != _nbPlaylists)
        return;
    
    // merge songs
    for (NSInteger i = 0; i < _data.count; i++)
    {
        NSArray* songs = [_data objectAtIndex:i];
        for (Song* song in songs)
        {
            DevLog(@"received song '%@ - %@  - %@'", song.name, song.artist, song.album);
            // create a key for the dictionary
            NSString* localKey = [SongCatalog catalogKeyOfSong:song.name_client artistKey:song.artist_client albumKey:song.album_client];
            
            // and store the song in the dictionnary, for later convenient use
            [self.matchedSongs setObject:song forKey:localKey];
        }
    }
    
    // build catalog
    [[SongRadioCatalog main] build];
    
    DLog(@"%d matched songs", self.matchedSongs.count);
    
    NSMutableDictionary* actionInfo = [NSMutableDictionary dictionary];
    [actionInfo setObject:[NSNumber numberWithInteger:self.matchedSongs.count] forKey:@"count"];
    [actionInfo setObject:@""  forKey:@"error"];
    [actionInfo setObject:[NSNumber numberWithBool:YES]  forKey:@"success"];
    
    if ([self.target respondsToSelector:self.action])
        [self.target performSelector:self.action withObject:actionInfo];
}




//...............................................................................................
//
// build catalog from the server's synchronized songs
//

- (void)build
{
    NSArray* songs = [self.matchedSongs allValues];
    
    [self beginTransaction];
    
    for (Song* song in songs)
    {
        // be aware of empty artist names, and empty album names
        NSString* artistKey = song.artist;
        if ((artistKey == nil) || (artistKey.length == 0))
        {
            artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
            DLog(@"buildSynchronizedWithSource: empty artist found!");
        }
        NSString* albumKey = song.album;
        if ((albumKey == nil) || (albumKey.length == 0))
        {
            albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
            DLog(@"buildSynchronizedWithSource: empty album found!");
        }
        
        NSString* songKey = [SongCatalog catalogKeyOfSong:song.name artistKey:artistKey albumKey:albumKey];
        
        // store the song key into the song
        song.catalogKey = songKey;
        
        [self addSong:song forTable:RADIOCATALOG_TABLE songKey:songKey artistKey:artistKey albumKey:albumKey];
    }
    
    [self commit];

    
    self.isInCache = YES;
}








- (NSArray*)songsForLetter:(NSString*)charIndex {
    
    return [self songsForLetter:charIndex fromTable:RADIOCATALOG_TABLE];
}


- (NSArray*)artistsForLetter:(NSString*)charIndex {

    return [self artistsForLetter:charIndex fromTable:RADIOCATALOG_TABLE];
}


- (NSArray*)albumsForArtist:(NSString*)artist {

    return [self albumsForArtist:artist fromTable:RADIOCATALOG_TABLE];
}

- (NSArray*)albumsForArtist:(NSString*)artist withGenre:(NSString*)genre {
    
    return [self albumsForArtist:artist withGenre:genre fromTable:RADIOCATALOG_TABLE];
}

- (NSArray*)albumsForArtist:(NSString*)artist withPlaylist:(NSString*)playlist {
    
    return [self albumsForArtist:artist withPlaylist:playlist fromTable:RADIOCATALOG_TABLE];
}

- (NSArray*)songsForArtist:(NSString*)artist {
    
    return [self songsForArtist:artist fromTable:RADIOCATALOG_TABLE];
}



- (NSArray*)songsForArtist:(NSString*)artist withGenre:(NSString*)genre {
    return [self songsForArtist:artist withGenre:genre fromTable:RADIOCATALOG_TABLE];
}


- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist {
    
    return [self songsForAlbum:album fromArtist:artist fromTable:RADIOCATALOG_TABLE];
}



- (NSDictionary*)songsAll {
    
    return [self songsAllFromTable:RADIOCATALOG_TABLE];
}


 - (BOOL)addSong:(Song*)song songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey {
    
    return [self addSong:song forTable:RADIOCATALOG_TABLE songKey:songKey artistKey:artistKey albumKey:albumKey];
}

















#pragma mark - Notifications



- (void)updateSongAddedToProgramming:(Song*)song
{
    assert(song);

    // be aware of empty artist names, and empty album names
    NSString* artistKey = song.artist;
    if ((artistKey == nil) || (artistKey.length == 0))
    {
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
        DLog(@"buildSynchronizedWithSource: empty artist found!");
    }
    NSString* albumKey = song.album;
    if ((albumKey == nil) || (albumKey.length == 0))
    {
        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
        DLog(@"buildSynchronizedWithSource: empty album found!");
    }
    
    NSString* songKey = [SongCatalog catalogKeyOfSong:song.name artistKey:artistKey albumKey:albumKey];
    
    // store the song key into the song
    song.catalogKey = songKey;
    
    // add song to radio DB
    [self addSong:song forTable:RADIOCATALOG_TABLE songKey:songKey artistKey:artistKey albumKey:albumKey];
    
    // clear related cache
    [self clearCatalogCache];
    
    // and call for a GUI refresh
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROGAMMING_SONG_ADDED object:song];

}



- (void)updateSongRemovedFromProgramming:(Song*)song
{
    assert(song);
    
    DLog(@"updateSongRemovedFromProgramming");

    // be aware of empty artist names, and empty album names
    NSString* artistKey = song.artist;
    if ((artistKey == nil) || (artistKey.length == 0))
    {
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
        DLog(@"buildSynchronizedWithSource: empty artist found!");
    }
    NSString* albumKey = song.album;
    if ((albumKey == nil) || (albumKey.length == 0))
    {
        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
        DLog(@"buildSynchronizedWithSource: empty album found!");
    }
    
    if (song.catalogKey == nil)
        song.catalogKey = [SongCatalog catalogKeyOfSong:song.name artistKey:artistKey albumKey:albumKey];
    NSString* songKey = song.catalogKey;
    assert(songKey);
    
    // remove song from radio DB
    [self removeSong:songKey forTable:RADIOCATALOG_TABLE];

    // clear related cache
    [self clearCatalogCache];
    
    DLog(@"send delete update notification");

    // and call for a GUI refresh
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROGAMMING_SONG_REMOVED object:song];
}




- (void)updateSongUpdated:(Song*)song
{
}




@end
