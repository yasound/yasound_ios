//
//  PlaylistMoulinor.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "PlaylistMoulinor.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSData+CocoaDevUsersAdditions.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>



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



- (id)init
{
    self = [super init];
    if (self)
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        assert([paths count] > 0);
        _documentDirectory = [paths objectAtIndex:0];
        [_documentDirectory retain];
        
        // create playlist folder
        _playlistDirectory = [_documentDirectory stringByAppendingPathComponent:@"playlists"];
        [_playlistDirectory retain];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:_playlistDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:_playlistDirectory withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    return self;
}


- (void)dealloc
{
    [_documentDirectory release];
    [_playlistDirectory release];
    
    [super dealloc];
}



//...................................................................................................
//
// PROCESS, step by step : 
//
// 1 - get the list of removed playlists => DEL [playlist]
// 2 - 
//
//...................................................................................................



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

    
    // build an array with the playlists names
    if (_playlists != nil)
    {
        [_playlists release];
        _playlists = nil;
    }
    _playlists = [[NSMutableArray alloc] init];
    [_playlists retain];
    
    for (MPMediaPlaylist* playlist in mediaPlaylists)
    {
        NSString* playlistTitle = [playlist valueForProperty:MPMediaPlaylistPropertyName];
        [_playlists addObject:playlistTitle];
    }
    
    // get the playlist array that has been previously stored
    NSString* playlistFilePath = [_documentDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSLog(@"playlist list filepath : '%@'", playlistFilePath);
    NSArray* storedPlaylists = [NSArray arrayWithContentsOfFile:playlistFilePath];
    

        
    //...................................................................................................
    //
    // OPERATION 1 / 4 : see what playlist has been removed, and write DEL actions to tell the server
    //
    //...................................................................................................
    //
    for (NSString* storedPlaylist in storedPlaylists)
    {
        if (![_playlists containsObject:storedPlaylist])
        {
            NSString* actionString = [NSString stringWithFormat:@"%@;\"%@\";\n", PM_ACTION_DEL, storedPlaylist];
            NSData* actionData = [actionString dataUsingEncoding:NSUTF8StringEncoding];
            [data appendData:actionData];
        }
    }
    
    
    
    // for all playlist, build the DATA
    for (NSInteger index = 0; index < [mediaPlaylists count]; index++)
    {
        MPMediaPlaylist* playlist = [mediaPlaylists objectAtIndex:index];
        NSData* playlistData = [self dataWithPlaylist:playlist atIndex:index binary:binary];
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

- (NSData*)dataWithPlaylist:(MPMediaPlaylist*)playlist atIndex:(NSInteger)index binary:(BOOL)binary
{
    NSString* playlistName = [_playlists objectAtIndex:index];

    NSMutableData* data = [[NSMutableData alloc] init];
    
    // get sorted dictionary from the playlist contents
    NSDictionary* sortedDictionary = [self sortedDictionaryWithPlaylist:playlist];
    
    // get previously recorded dictionnary for this playlist
    NSString* storepath = [_playlistDirectory stringByAppendingPathComponent:playlistName];
    NSLog(@"playlist storepath : '%@'", storepath);

    NSDictionary* STOREDdictionary = [[NSDictionary alloc] initWithContentsOfFile:storepath];
    if (STOREDdictionary == nil)
        NSLog(@"it's a new playlist.");
    else
        NSLog(@"playlist previously stored file has been retrieved.");


    //.............................................................................................
    // an entry for the playlist name
    //
    [self writeEntryPlaylist:playlistName inData:data binary:binary];
     
    
    //...................................................................................................
    // OPERATION 2 / 4 : build dictionary of removed elements (artists/albums/songs)
    //
    NSDictionary* removedDictionary = [self removedItemsFromStored:STOREDdictionary compareToCurrent:sortedDictionary];

    
    //...................................................................................................
    // OPERATION 3 / 4 : build dictionary of added elements (artists/albums/songs)
    //
    NSDictionary* addedDictionary = [self addedItemsFromCurrent:sortedDictionary compareToStored:STOREDdictionary];
    
             
    
    
    

    // now, output the sorted list in the data buffer
    NSArray* artists = [sortedDictionary allKeys];
    // for each artist
    for (NSString* artist in artists)
    {
        NSDictionary* dicoArtist = [sortedDictionary objectForKey:artist];
        NSData* artistData = [self dataWithArtist:artist dictionary:dicoArtist binary:binary];
        [data appendData:artistData];
    }

    
    return data;
}










//**********************************************************************************************************
//
// sortedDictionaryWithPlaylist
//
// build a dictionnary with the given playlist contents,
// sorted by Artist / Album / (Song with index)
//
// (NSDictionary)Artist / (NSArray)Album / (NSDictionary)Song {index, title}
//

- (NSDictionary*)sortedDictionaryWithPlaylist:(MPMediaPlaylist*)playlist
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




- (void)emailData:(NSData*)data to:(NSString*)email mimetype:(NSString*)mimetype filename:(NSString*)filename controller:(UIViewController*)controller
{
    _emailController = controller;
    
    MFMailComposeViewController* picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set the subject of email
    [picker setSubject:@"yasound playlist data file"];
    
    // Add email addresses
    // Notice three sections: "to" "cc" and "bcc"	
    [picker setToRecipients:[NSArray arrayWithObjects:email, nil]];
//    [picker setCcRecipients:[NSArray arrayWithObject:@"emailaddress3@domainName.com"]];	
//    [picker setBccRecipients:[NSArray arrayWithObject:@"emailaddress4@domainName.com"]];
    
    // Fill out the email body text
    NSString *emailBody = @"yasound playlist data file attached.";
    
    // This is not an HTML formatted email
    [picker setMessageBody:emailBody isHTML:NO];
    
    // Attach image data to the email
    [picker addAttachmentData:data mimeType:mimetype fileName:filename];
    
    // Show email view	
    [controller.navigationController presentModalViewController:picker animated:YES];
    
    // Release picker
    [picker release];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    // Called once the email is sent
    // Remove the email view controller	
    [_emailController.navigationController dismissModalViewControllerAnimated:YES];
    _emailController = nil;
}

             
             
             















- (NSDictionary*)removedItemsFromStored:(NSDictionary*)STOREDdictionary compareToCurrent:(NSDictionary*)currentDictionary
{
    NSMutableDictionary* removedDictionary = [[NSMutableDictionary alloc] init];

    // for all artist
    NSArray* STOREDartists = [STOREDdictionary allKeys];
    for (NSString* artist in STOREDartists)
    {
        NSDictionary* dicoArtist = [currentDictionary objectForKey:artist];
        NSDictionary* STOREDdicoArtist = [STOREDdictionary objectForKey:artist];
        
        // the whole artist has been removed
        if (dicoArtist == nil)
        {
            NSDictionary* removedArtistDictionary = [NSDictionary dictionaryWithDictionary:STOREDdicoArtist];
            [removedDictionary setObject:removedArtistDictionary forKey:artist];
            continue;
        }
        
        // no, the artist is still referenced : 
        
        // for all album
        NSArray* STOREDalbums = [STOREDdicoArtist allKeys];
        for (NSString* album in STOREDalbums)
        {
            NSArray* arrayAlbum = [dicoArtist objectForKey:album];
            NSArray* STOREDarrayAlbum = [dicoArtist objectForKey:album];
            
            // the whole album has been removed
            if (arrayAlbum == nil)
            {
                NSMutableDictionary* removedArtistDictionary = [removedDictionary objectForKey:artist];
                if (removedArtistDictionary == nil)
                {
                    removedArtistDictionary = [[NSMutableDictionary alloc] init];
                    [removedDictionary setObject:removedArtistDictionary forKey:artist];
                }
                
                NSArray* removedAlbumArray = [NSArray arrayWithArray:STOREDarrayAlbum];
                [removedArtistDictionary setObject:removedAlbumArray forKey:album];
                continue;
            }
            
            // no, the album is still referenced :
            
            // for all songs
            for (NSString* song in STOREDarrayAlbum)
            {
                if ([arrayAlbum containsObject:song])
                    continue;

                // the song has been removed
                NSMutableDictionary* removedArtistDictionary = [removedDictionary objectForKey:artist];
                if (removedArtistDictionary == nil)
                {
                    removedArtistDictionary = [[NSMutableDictionary alloc] init];
                    [removedDictionary setObject:removedArtistDictionary forKey:artist];
                }
                
                NSMutableArray* removedAlbumArray = [removedArtistDictionary objectForKey:album];
                if (removedAlbumArray == nil)
                {
                    removedAlbumArray = [[NSMutableArray alloc] init];
                    [removedArtistDictionary setObject:removedAlbumArray forKey:album];
                }
                
                [removedAlbumArray addObject:song];
            } // end for all songs
        } // end for all albums
    } // end for all artists
    
    return removedDictionary;
}






             
             
             
             
 - (void)writeEntryPlaylist:(NSString*)playlistName inData:(NSMutableData*)data binary:(BOOL)binary
 {
     if (!binary)
     {
         NSString* title = [NSString stringWithFormat:@"%@;\"%@\";\n", PM_TAG_PLAYLIST, playlistName];
         NSData* titleData = [title dataUsingEncoding:NSUTF8StringEncoding];
         [data appendData:titleData];
     }
     else
     {
         const char* str = (const char*) [PM_TAG_PLAYLIST UTF8String];
         [data appendBytes:str length:strlen(str)];    
         
         str = ";\""; 
         [data appendBytes:str length:strlen(str)];    
         
         str = (const char*) [playlistName UTF8String];
         [data appendBytes:str length:strlen(str)];    
         
         str = "\";\n"; 
         [data appendBytes:str length:strlen(str)];    
     }
 }
             




@end
