//
//  PlaylistMoulinor.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "PlaylistMoulinor.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSData+CocoaDevUsersAdditions.h"




@implementation PlaylistMoulinor


static PlaylistMoulinor* _main = nil;


+ (PlaylistMoulinor*)main
{
    if (_main == nil)
    {
        _main = [[PlaylistMoulinor alloc] init];
    }
    
    return _main;
}






//**********************************************************************************************************
//
// dataWithPlaylists
//
// build a "CSV-like" formated NSData, from the playlists contents
//
//
- (NSData*)dataWithPlaylists:(NSArray*)mediaPlaylists binary:(BOOL)binary compressed:(BOOL)compressed
{
    NSMutableData* data = [[NSMutableData alloc] init];
    
    // current time
    NSDate* BEGIN = [NSDate date];
    
    //..............................................................
    //
    // SECTION 'ADD'
    //
    
    if (!binary)
    {
        NSString* actionString = [NSString stringWithFormat:@"%@;\n", PM_ACTION_ADD];
        NSData* actionData = [actionString dataUsingEncoding:NSUTF8StringEncoding];
        [data appendData:actionData];
    }
    else
    {
        const char* str = (const char*) [PM_ACTION_ADD UTF8String];
        [data appendBytes:str length:strlen(str)];    

        str = ";\n"; 
        [data appendBytes:str length:strlen(str)];    
    }

    
    // for all playlist
    for (MPMediaPlaylist* list in mediaPlaylists)
    {
        NSData* playlistData = [self dataWithPlaylist:list binary:binary];
        [data appendData:playlistData];
    }
    
    // delay for building the data
    double timePassedForBuilding_ms = [BEGIN timeIntervalSinceNow] * -1000.0;
    BEGIN = [NSDate date];
    
    if (!compressed)
        return data;
    
    NSData* compressedData = [data zlibDeflate];

    // delay for compressing the data
    double timePassedForCompressing_ms = [BEGIN timeIntervalSinceNow] * -1000.0;
    
    NSLog(@"PlaylistMoulinor  uncompressed data : %d bytes    compressed data : %d bytes", [data length], [compressedData length]);
    NSLog(@"PlaylistMoulinor  building data in : %.2f ms    compressing data in : %.2f ms", timePassedForBuilding_ms, timePassedForCompressing_ms);

    return compressedData;
}










//**********************************************************************************************************
//
// dataWithPlaylist
//
// build a "CSV-like" formated NSData, from a given playlist
//
//

- (NSData*)dataWithPlaylist:(MPMediaPlaylist*)playlist binary:(BOOL)binary
{
    NSString* playlistTitle = [playlist valueForProperty:MPMediaPlaylistPropertyName];


    NSMutableData* data = [[NSMutableData alloc] init];

    //.............................................................................................
    // an entry for the playlist
    //
    if (!binary)
    {
        NSString* title = [NSString stringWithFormat:@"%@;\"%@\";\n", PM_TAG_PLAYLIST, playlistTitle];
        NSData* titleData = [title dataUsingEncoding:NSUTF8StringEncoding];
        [data appendData:titleData];
    }
    else
    {
        const char* str = (const char*) [PM_TAG_PLAYLIST UTF8String];
        [data appendBytes:str length:strlen(str)];    

        str = ";\""; 
        [data appendBytes:str length:strlen(str)];    

        str = (const char*) [playlistTitle UTF8String];
        [data appendBytes:str length:strlen(str)];    

        str = "\";\n"; 
        [data appendBytes:str length:strlen(str)];    
    }
    
    
    // get sorted dictionary from the playlist contents
    NSDictionary* sortedDictionnary = [self sortedDictionnaryWithPlaylist:playlist];
    

    // now, output the sorted list in the data buffer
    NSArray* artists = [sortedDictionnary allKeys];
    // for each artist
    for (NSString* artist in artists)
    {
        NSDictionary* dicoArtist = [sortedDictionnary objectForKey:artist];
        NSData* artistData = [self dataWithArtist:artist dictionary:dicoArtist binary:binary];
        [data appendData:artistData];
    }

    
    return data;
}










//**********************************************************************************************************
//
// sortedDictionnaryWithPlaylist
//
// build a dictionnary with the given playlist contents,
// sorted by Artist / Album / (Song with index)
//
// (NSDictionary)Artist / (NSArray)Album / (NSDictionary)Song {index, title}
//

- (NSDictionary*)sortedDictionnaryWithPlaylist:(MPMediaPlaylist*)playlist
{

    // dico to sort the playlist's items
    NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];

    NSInteger index = 0;
    // for each item
    for (MPMediaItem* item in [playlist items])
    {
        NSString* song = [item valueForProperty:MPMediaItemPropertyTitle];
        if (song == nil)
            song = [NSString stringWithString:PM_FIELD_UNKNOWN];
        NSString* artist = [item valueForProperty:MPMediaItemPropertyArtist];
        if (artist == nil)
            artist = [NSString stringWithString:PM_FIELD_UNKNOWN];
        NSString* album  = [item valueForProperty:MPMediaItemPropertyAlbumTitle];  
        if (album == nil)
            album = [NSString stringWithString:PM_FIELD_UNKNOWN];
        //NSLog(@"%d : %@  |  %@  |  %@", index, artist, album, song);
        
        // sort by artist
        NSMutableDictionary* dicoArtist = [dico objectForKey:artist];
        if (dicoArtist == nil)
        {
            dicoArtist = [[NSMutableDictionary alloc] init];
            [dico setObject:dicoArtist forKey:artist];
        }
        
        // sort by album
        NSMutableArray* arrayAlbum = [dicoArtist objectForKey:album];
        if (arrayAlbum == nil)
        {
            arrayAlbum = [[NSMutableArray alloc] init];
            [dicoArtist setObject:arrayAlbum forKey:album];
        }
        
        // add the item's song
        NSMutableDictionary* dicoSong = [[NSMutableDictionary alloc] init];
        [arrayAlbum addObject:dicoSong];
        
        // song's index in playlist
        [dicoSong setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
        // song's title
        [dicoSong setObject:song forKey:@"title"];
        
        index++;
    }
    
    return dico;
}










//**********************************************************************************************************
//
// dataWithArtist
//
// build a "CSV-like" formated NSData, from a given artist dictionary
//
//

- (NSData*) dataWithArtist:(NSString*)artist dictionary:(NSDictionary*)dicoArtist binary:(BOOL)binary
{
    NSMutableData* data = [[NSMutableData alloc] init];

    
    //..................................................................................
    // an entry for the artist
    //
    if (!binary)
    {
        NSString* output = [NSString stringWithFormat:@"%@;\"%@\";\n", PM_TAG_ARTIST, artist];
        NSData* outputData = [output dataUsingEncoding:NSUTF8StringEncoding];
        [data appendData:outputData];
    }
    else
    {
        const char* str = (const char*) [PM_TAG_ARTIST UTF8String];
        [data appendBytes:str length:strlen(str)];    

        str = ";\""; 
        [data appendBytes:str length:strlen(str)];    

        str = (const char*) [artist UTF8String];
        [data appendBytes:str length:strlen(str)];    

        str = "\";\n";
        [data appendBytes:str length:strlen(str)];    
    }

    // for each album
    NSArray* albums = [dicoArtist allKeys];
    for (NSString* album in albums)
    {
        NSArray* arrayAlbum = [dicoArtist objectForKey:album];
        NSData* albumData = [self dataWithAlbum:album array:arrayAlbum binary:binary];
        [data appendData:albumData];
    }
    
    return data;
}






//**********************************************************************************************************
//
// dataWithAlbum
//
// build a "CSV-like" formated NSData, from a given album array
//
//

- (NSData*) dataWithAlbum:(NSString*)album array:(NSArray*)arrayAlbum binary:(BOOL)binary
{
    NSMutableData* data = [[NSMutableData alloc] init];

    
    if (!binary)
    {
        //..................................................................................
        // an entry for the album
        //
        NSString* output = [NSString stringWithFormat:@"%@;\"%@\";\n", PM_TAG_ALBUM, album];
        NSData* outputData = [output dataUsingEncoding:NSUTF8StringEncoding];
        [data appendData:outputData];

        // for each song
        for (NSDictionary* dicoSong in arrayAlbum)
        {
            NSInteger index = [[dicoSong objectForKey:@"index"] integerValue];
            NSString* title = [dicoSong objectForKey:@"title"];
            
            //..................................................................................
            // an entry for the song
            //
            NSString* output = [NSString stringWithFormat:@"%@;%d;\"%@\";\n", PM_TAG_SONG, index, title];
            NSData* outputData = [output dataUsingEncoding:NSUTF8StringEncoding];
            [data appendData:outputData];
        }
    }
    else
    {
        //..................................................................................
        // an entry for the album
        //
        const char* str = (const char*) [PM_TAG_ALBUM UTF8String];
        [data appendBytes:str length:strlen(str)];    

        str = ";\""; 
        [data appendBytes:str length:strlen(str)];    

        str = (const char*) [album UTF8String];
        [data appendBytes:str length:strlen(str)];    

        str = "\";\n";
        [data appendBytes:str length:strlen(str)];   
        

        // for each song
        for (NSDictionary* dicoSong in arrayAlbum)
        {
            int index = [[dicoSong objectForKey:@"index"] intValue];
            NSString* title = [dicoSong objectForKey:@"title"];
            
            //..................................................................................
            // an entry for the song
            //
            const char* str = (const char*) [PM_TAG_SONG UTF8String];
            [data appendBytes:str length:strlen(str)];    
            
            str = ";"; 
            [data appendBytes:str length:strlen(str)];    
            
            str = &index;
            int size = sizeof(int);
            [data appendBytes:str length:size];    
            
            str = ";\""; 
            [data appendBytes:str length:strlen(str)];    

            str = (const char*) [title UTF8String];
            [data appendBytes:str length:strlen(str)];    

            str = "\";\n";
            [data appendBytes:str length:strlen(str)];   
        }
    }
    
    
    return data;
}


@end
