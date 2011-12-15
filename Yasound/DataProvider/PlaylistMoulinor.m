//
//  PlaylistMoulinor.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "PlaylistMoulinor.h"
#import <MediaPlayer/MediaPlayer.h>




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
- (NSData*)dataWithPlaylists:(NSArray*)mediaPlaylists
{
    NSMutableData* data = [[NSMutableData alloc] init];
    
    //..............................................................
    //
    // SECTION 'ADD'
    //
    
    NSString* actionString = [NSString stringWithFormat:@"%@;\n", PM_ACTION_ADD];
    NSData* actionData = [actionString dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:actionData];

    
    // for all playlist
    for (MPMediaPlaylist* list in mediaPlaylists)
    {
        NSData* playlistData = [self dataWithPlaylist:list];
        [data appendData:playlistData];
    }
    
    return data;
}











//**********************************************************************************************************
//
// dataWithPlaylist
//
// build a "CSV-like" formated NSData, from a given playlist
//
//

- (NSData*)dataWithPlaylist:(MPMediaPlaylist*)playlist
{
    NSString* playlistTitle = [playlist valueForProperty:MPMediaPlaylistPropertyName];


    NSMutableData* data = [[NSMutableData alloc] init];

    //.............................................................................................
    // an entry for the playlist
    //
    NSString* title = [NSString stringWithFormat:@"%@;\"%@\";\n", PM_TAG_PLAYLIST, playlistTitle];
    NSData* titleData = [title dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:titleData];
    
    
    // get sorted dictionary from the playlist contents
    NSDictionary* sortedDictionnary = [self sortedDictionnaryWithPlaylist:playlist];
    

    // now, output the sorted list in the data buffer
    NSArray* artists = [sortedDictionnary allKeys];
    // for each artist
    for (NSString* artist in artists)
    {
        NSDictionary* dicoArtist = [sortedDictionnary objectForKey:artist];
        NSData* artistData = [self dataWithArtist:artist dictionary:dicoArtist];
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
        NSString* artist = [item valueForProperty:MPMediaItemPropertyArtist];
        NSString* album  = [item valueForProperty:MPMediaItemPropertyAlbumTitle];  
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

- (NSData*) dataWithArtist:(NSString*)artist dictionary:(NSDictionary*)dicoArtist
{
    NSMutableData* data = [[NSMutableData alloc] init];

    
    //..................................................................................
    // an entry for the artist
    //
    NSString* output = [NSString stringWithFormat:@"%@;\"%@\";\n", PM_TAG_ARTIST, artist];
    NSData* outputData = [output dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:outputData];

    // for each album
    NSArray* albums = [dicoArtist allKeys];
    for (NSString* album in albums)
    {
        NSArray* arrayAlbum = [dicoArtist objectForKey:album];
        NSData* albumData = [self dataWithAlbum:album array:arrayAlbum];
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

- (NSData*) dataWithAlbum:(NSString*)album array:(NSArray*)arrayAlbum
{
    NSMutableData* data = [[NSMutableData alloc] init];

    
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
    
    return data;
}


@end
