//
//  SongRadioCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongRadioCatalog.h"
#import "YasoundDataProvider.h"

@implementation SongRadioCatalog


@synthesize radio;
@synthesize target;
@synthesize action;



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
    
    [_main release];
    _main = nil;
}




- (void)initForRadio:(Radio*)radio target:(id)aTarget action:(SEL)anAction {
    
    self.radio = radio;
    self.target = aTarget;
    self.action = anAction;
    
    // return cached data
    if (self.isInCache)
    {
//        NSMutableDictionary* actionInfo = [NSMutableDictionary dictionary];
//        [actionInfo setObject:[NSNumber numberWithInteger:self.matchedSongs.count] forKey:@"nbMatchedSongs"];
//        [actionInfo setObject:@""  forKey:@"message"];
        
        [self.target performSelector:self.action withObject:self.songs success:YES];
        return;
    }
    
//    // otherwise , create cache and build data
//    self.matchedSongs = [[NSMutableDictionary alloc] init];
//    
//    self.artistRegister = [[NSMutableDictionary alloc] init];
//    self.albumRegister = [[NSMutableDictionary alloc] init];
    
    _data = [[NSMutableArray alloc] init];
    [_data retain];
    
    _nbReceivedData = 0;
    _nbPlaylists = 0;
    
    [[YasoundDataProvider main] playlistsForRadio:radio target:self action:@selector(receivePlaylists:withInfo:)];
}




- (void)receivePlaylists:(NSArray*)playlists withInfo:(NSDictionary*)info
{
    if (playlists == nil)
        _nbPlaylists = 0;
        else
            _nbPlaylists = playlists.count;
            
            
            DLog(@"received %d playlists", _nbPlaylists);
            
            if (_nbPlaylists == 0)
            {
//                NSMutableDictionary* info = [NSMutableDictionary dictionary];
//                [info setObject:[NSNumber numberWithInteger:0] forKey:@"nbMatchedSongs"];
//                [info setObject:NSLocalizedString(@"ProgrammingView_error_no_playlist_message", nil)  forKey:@"message"];
                
                [self.target performSelector:self.action withObject:nil success:NO];
                return;
            }
    
    for (Playlist* playlist in playlists)
    {
        DLog(@"playlist %@ :", playlist.name);
        
        [[YasoundDataProvider main] matchedSongsForPlaylist:playlist target:self action:@selector(matchedSongsReceveived:info:)];
    }
}


- (void)matchedSongsReceveived:(NSArray*)songs info:(NSDictionary*)info
{
    NSNumber* succeededNb = [info objectForKey:@"succeeded"];
    assert(succeededNb != nil);
    BOOL succeeded = [succeededNb boolValue];
    
    if (!succeeded)
    {
//        NSMutableDictionary* actionInfo = [NSMutableDictionary dictionary];
//        [actionInfo setObject:[NSNumber numberWithInteger:0] forKey:@"nbMatchedSongs"];
//        [actionInfo setObject:NSLocalizedString(@"ProgrammingView_error_message", nil)  forKey:@"message"];
        
        DLog(@"matchedSongsReceveived : REQUEST FAILED for playlist nb %d", _nbReceivedData);
        DLog(@"info %@", info);
        
        [self.target performSelector:self.action withObject:nil success:NO];
        return;
        
    }
    
    
    DLog(@"received playlist : nb %d : %d songs",  _nbReceivedData, songs.count);
    
    _nbReceivedData++;
    
    if (succeeded && (songs != nil) && (songs.count != 0))
        [_data addObject:songs];
    
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
            // LBDEBUG NSString* key = [SongCatalog catalogKeyOfSong:song.name artist:song.artist album:song.album];
            NSString* key = [self catalogKeyOfSong:song.name_client artist:song.artist_client album:song.album_client];
            
            
            // and store the song in the dictionnary, for later convenient use
            //[self.matchedSongs setObject:song forKey:key];
            [self addSong:song forKey:key];
            
        }
    }
    
    // build catalog
    [[SongCatalog synchronizedCatalog] buildSynchronizedWithSource:self.matchedSongs];
    [SongCatalog synchronizedCatalog].matchedSongs = self.matchedSongs;
    
    
    DLog(@"%d matched songs", self.matchedSongs.count);
    
    NSMutableDictionary* actionInfo = [NSMutableDictionary dictionary];
    [actionInfo setObject:[NSNumber numberWithInteger:self.matchedSongs.count] forKey:@"nbMatchedSongs"];
    [actionInfo setObject:@""  forKey:@"message"];
    
    [self.target performSelector:self.action withObject:actionInfo withObject:[NSNumber numberWithBool:YES]];
    
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
            DLog(@"buildSynchronizedWithSource: empty artist found!");
        }
        NSString* albumKey = song.album;
        if ((albumKey == nil) || (albumKey.length == 0))
        {
            albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
            DLog(@"buildSynchronizedWithSource: empty album found!");
        }
        
        //        DLog(@"song.name %@", song.name);
        //        DLog(@"song.artist %@", song.artist);
        //        DLog(@"song.album %@", song.album);
        
        [self catalogWithoutSorting:song  usingArtistKey:artistKey andAlbumKey:albumKey];
        self.nbSongs++;    
    }
    
    self.isInCache = YES;
}








- (NSArray*)songsForLetter:(NSString*)charIndex {
    
    return [self songsForLetter:charIndex fromTable:RADIOCATALOG_TABLE];
}

- (NSDictionary*)songsAll {
    
    return [self songsAll fromTable:RADIOCATALOG_TABLE];
}




@end
