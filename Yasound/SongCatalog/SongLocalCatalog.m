//
//  SongLocalCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongLocalCatalog.h"
#import "TimeProfile.h"

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


- (void)initFromMatchedSongs:(NSArray*)songs {
    
    [[TimeProfile main] begin:@"iTunesQuery"];
    
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    NSArray* songsArray = [allSongsQuery items];
    
    [[TimeProfile main] end:@"iTunesQuery"];
    [[TimeProfile main] logInterval:@"iTunesQuery" inMilliseconds:NO];
    
    // list all local songs from albums
    for (MPMediaItem* item in songsArray)
    {
        SongLocal* songLocal = [[SongLocal alloc] initWithMediaItem:item];
        
        Song* matchedSong = [synchronizedSource objectForKey:songLocal.catalogKey];
        
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
        
        [self catalogWithoutSorting:songLocal usingArtistKey:songLocal.artistKey andAlbumKey:songLocal.albumKey];
        
        
        self.nbSongs++;
        
    }
    
    if (self.nbSongs > 0)
        self.cached = YES;
    
}




@end
