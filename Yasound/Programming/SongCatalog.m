//
//  SongCatalog.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "Song.h"
#import "SongLocal.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SongUploadManager.h"

#import "TimeProfile.h"
#import "YasoundDataProvider.h"





#define PM_FIELD_UNKNOWN @""


@implementation SongCatalog

@synthesize artistRegister;
@synthesize albumRegister;

@synthesize cached;
@synthesize radio;
@synthesize target;
@synthesize action;
@synthesize matchedSongs;
@synthesize nbSongs;

@synthesize alphabeticRepo;
@synthesize indexMap;
@synthesize alphaArtistsRepo;

@synthesize selectedArtist;
@synthesize selectedAlbum;
@synthesize selectedArtistRepo;
@synthesize selectedAlbumRepo;




//...............................................................................................
//
// Singletons
//

static SongCatalog* _synchronizedCatalog; // for the server's synchronized songs
static SongCatalog* _availableCatalog;    // for the device's local iTunes songs


+ (SongCatalog*)synchronizedCatalog
{
    if (_synchronizedCatalog == nil)
    {
        _synchronizedCatalog = [[SongCatalog alloc] init];

    }
    return _synchronizedCatalog;
}

+ (void)releaseSynchronizedCatalog
{
    if (_synchronizedCatalog == nil)
        return;
    
    [_synchronizedCatalog release];
    _synchronizedCatalog = nil;
}

+ (SongCatalog*)availableCatalog
{
    if (_availableCatalog == nil)
    {
        _availableCatalog = [[SongCatalog alloc] init];
    }
    return _availableCatalog;
}


+ (void)releaseAvailableCatalog
{
    if (_availableCatalog == nil)
        return;
    
    [_availableCatalog release];
    _availableCatalog = nil;
}



- (NSString*)catalogKeyOfArtist:(NSString*)artist
{
    NSString* artistKey = artist;
    if (artistKey == nil)
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
    return artistKey;
}

- (NSString*)catalogKeyOfAlbum:(NSString*)album
{
    NSString* albumKey = album;
    if (albumKey == nil)
        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
    return albumKey;
}



- (NSString*)catalogKeyOfSong:(NSString*)name artist:(NSString*)artist album:(NSString*)album
{
    NSString* artistKey = [self catalogKeyOfArtist:artist];
    NSString* albumKey = [self catalogKeyOfAlbum:album];
    
    // build catalog key
    NSString* catalogKey = [NSString stringWithFormat:@"%@|%@|%@", name, artistKey, albumKey];
    
    // register artist->artistKey and album->albumKey
    // we need those to request artist and album deletion from programming
    artistKey = artist;
    albumKey = album;
    
    if (artistKey == nil)
        artistKey = @"";
    
    if (albumKey == nil)
        albumKey =  @"";
    
    [self.artistRegister setObject:artist forKey:artistKey];
    [self.albumRegister setObject:album forKey:artistKey];
    

    // return catalog key
    return catalogKey;
}




//...............................................................................................
//
// init
//


- (id)init
{
    if (self = [super init])
    {
        _numericSet = [[NSCharacterSet decimalDigitCharacterSet] retain];
        _lowerCaseSet = [[NSCharacterSet lowercaseLetterCharacterSet] retain];
        _upperCaseSet = [[NSCharacterSet uppercaseLetterCharacterSet] retain];
        
        self.cached = NO;
        self.nbSongs = 0;

        
        self.alphabeticRepo = [[NSMutableDictionary alloc] init];
        
        self.alphaArtistsRepo = [[NSMutableDictionary alloc] init];
        
        
        self.indexMap = [[NSMutableArray alloc] init];
        [self initIndexMap];
        
        for (NSString* indexKey in self.indexMap)
        {
            NSMutableArray* letterRepo = [[NSMutableArray alloc] init];
            [self.alphabeticRepo setObject:letterRepo forKey:indexKey];

            NSMutableDictionary* letterArtistRepo = [[NSMutableDictionary alloc] init];
            [self.alphaArtistsRepo setObject:letterArtistRepo forKey:indexKey];
        }

    }
    return self;
}




- (void)dealloc
{
    [_numericSet release];
    [_lowerCaseSet release];
    [_upperCaseSet release];

    if (_data)
    {
        [_data release];
        _data = nil;
    }
    
    if (self.radio)
        [self.radio release];
    if (self.artistRegister)
        [self.artistRegister release];
    if (self.albumRegister)
        [self.albumRegister release];
    if (self.matchedSongs)
        [self.matchedSongs release];
    if (self.indexMap)
        [self.indexMap release];
    if (self.alphabeticRepo)
        [self.alphabeticRepo release];
    if (self.selectedArtist)
        [self.selectedArtist release];
    if (self.selectedAlbum)
        [self.selectedAlbum release];
    if (self.selectedArtistRepo)
        [self.selectedArtistRepo release];
    if (self.selectedAlbumRepo)
        [self.selectedAlbumRepo release];
    

    
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









- (void)downloadMatchedSongsForRadio:(Radio*)radio target:(id)aTarget action:(SEL)anAction
{
    self.radio = radio;
    self.target = aTarget;
    self.action = anAction;
    
    // return cached data
    if (self.matchedSongs != nil)
    {
        NSMutableDictionary* actionInfo = [NSMutableDictionary dictionary];
        [actionInfo setObject:[NSNumber numberWithInteger:self.matchedSongs.count] forKey:@"nbMatchedSongs"];
        [actionInfo setObject:@""  forKey:@"message"];
        
        [self.target performSelector:self.action withObject:actionInfo withObject:[NSNumber numberWithBool:YES]];
        return;
    }
    
    // otherwise , create cache and build data
    self.matchedSongs = [[NSMutableDictionary alloc] init];
    
    self.artistRegister = [[NSMutableDictionary alloc] init];
    self.albumRegister = [[NSMutableDictionary alloc] init];

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
        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        [info setObject:[NSNumber numberWithInteger:0] forKey:@"nbMatchedSongs"];
        [info setObject:NSLocalizedString(@"ProgrammingView_error_no_playlist_message", nil)  forKey:@"message"];
        
        [self.target performSelector:self.action withObject:info withObject:[NSNumber numberWithBool:NO]];
        return;
    }
    
    for (Playlist* playlist in playlists)
    {
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
        NSMutableDictionary* actionInfo = [NSMutableDictionary dictionary];
        [actionInfo setObject:[NSNumber numberWithInteger:0] forKey:@"nbMatchedSongs"];
        [actionInfo setObject:NSLocalizedString(@"ProgrammingView_error_message", nil)  forKey:@"message"];
        
        DLog(@"matchedSongsReceveived : REQUEST FAILED for playlist nb %d", _nbReceivedData);
        DLog(@"%@", info);

        [self.target performSelector:self.action withObject:actionInfo withObject:[NSNumber numberWithBool:NO]];
        return;

    }
    
    
    DLog(@"received playlist nb %d : %d songs", _nbReceivedData, songs.count);
    
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
            // create a key for the dictionary
            // LBDEBUG NSString* key = [SongCatalog catalogKeyOfSong:song.name artist:song.artist album:song.album];
            NSString* key = [self catalogKeyOfSong:song.name_client artist:song.artist_client album:song.album_client];
            
            
            // and store the song in the dictionnary, for later convenient use
            [self.matchedSongs setObject:song forKey:key];
            
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
        
        DLog(@"%@", song.name);
        DLog(@"%@", song.artist);
        DLog(@"%@", song.album);
        
        [self catalogWithoutSorting:song  usingArtistKey:artistKey andAlbumKey:albumKey];
        self.nbSongs++;    
    }
    
    self.cached = YES;
}




//...............................................................................................
//
// build catalog from the device's local iTunes songs
//
- (void)buildAvailableComparingToSource:(NSDictionary*)synchronizedSource
{
    
    //DLog(@"%@", synchronizedSource);
    
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
        
        
        // before putting this song into the catalog,
        // check if it's not uploading already.
        Song* uploadingSong = [[SongUploadManager main] getUploadingSong:songLocal.name artist:songLocal.artist album:songLocal.album];
        if (uploadingSong != nil)
            [songLocal setUploading:YES];
        
        // REMEMBER THAT HERE, songLocal is SongLocal* 
        
        [self catalogWithoutSorting:songLocal usingArtistKey:songLocal.artistKey andAlbumKey:songLocal.albumKey];
        
        
        self.nbSongs++;
        
    }
    
    if (self.nbSongs > 0)
        self.cached = YES;

}





//...............................................................................................
//
// common building methods for both catalogs
//


- (void)insertAndEnableSong:(Song*)song;
{
    // be aware of empty artist names, and empty album names
    NSString* artistKey = song.artist;
    if ((artistKey == nil) || (artistKey.length == 0))
    {
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
        DLog(@"insertAndEnableSong: empty artist found!");
    }
    NSString* albumKey = song.album;
    if ((albumKey == nil) || (albumKey.length == 0))
    {
        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
        DLog(@"insertAndEnableSong: empty album found!");
    }
    
    [song enableSong:YES];
    
    [self catalogWithoutSorting:song  usingArtistKey:artistKey andAlbumKey:albumKey];
    self.nbSongs++;    
}




- (void)removeSynchronizedSong:(Song*)song
{
    //
    // process alphaeticRepo
    //
    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
    
    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
        firstRelevantWord = @"#";
    
    unichar c = [firstRelevantWord characterAtIndex:0];

    NSMutableArray* letterRepo = nil;
    
    if ([_numericSet characterIsMember:c]) 
    {
        letterRepo = [self.alphabeticRepo objectForKey:@"-"];
    }
    // first letter is [a .. z] || [A .. Z]
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
    }
    // other cases (foreign languages, ...)
    else
    {
        letterRepo = [self.alphabeticRepo objectForKey:@"#"];
    }
    
    for (NSInteger index = 0; index < letterRepo.count; index++)
    {
        Song* letterSong = [letterRepo objectAtIndex:index];
        if ([letterSong.name isEqualToString:song.name])
        {
            [letterRepo removeObjectAtIndex:index];
            break;
        }
    }
    
    
    //
    // process artistsRepo
    //
    
    NSString* artistKey = song.artist;
    if ((artistKey == nil) || (artistKey.length == 0))
    {
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
        DLog(@"removeSynchronizedSong: empty artist found!");
    }
    NSString* albumKey = song.album;
    if ((albumKey == nil) || (albumKey.length == 0))
    {
        albumKey = NSLocalizedString(@"ProgrammingView_unknownAlbum", nil);
        DLog(@"removeSynchronizedSong: empty album found!");
    }
    
    
    
    c = [artistKey characterAtIndex:0];
    NSMutableDictionary* artistsRepo = nil;
    if ([_numericSet characterIsMember:c])
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"-"];
    }
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperC = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        artistsRepo = [self.alphaArtistsRepo objectForKey:upperC];
    }
    else
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"#"];
    }
    
    NSMutableDictionary* artistRepo = [artistsRepo objectForKey:artistKey];
    DLog(@"SongCatalog removeSynchronizedSong : may have error no dictionary for the artistKy '%@'", artistKey);
    if (artistRepo == nil)
        return;
    

    NSMutableArray* albumRepo = [artistRepo objectForKey:albumKey];
    
    for (NSInteger index = 0; index < albumRepo.count; index++)
    {
        Song* albumSong = [albumRepo objectAtIndex:index];
        if ([albumSong.name isEqualToString:song.name])
        {
            [albumRepo removeObjectAtIndex:index];
            break;
        }
    }
    
    
    
    
}





- (BOOL)doesContainSong:(Song*)song
{
    //
    // process alphaeticRepo
    //
    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
    
    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
        firstRelevantWord = @"#";
    
    unichar c = [firstRelevantWord characterAtIndex:0];
    
    NSMutableArray* letterRepo = nil;
    
    if ([_numericSet characterIsMember:c]) 
    {
        letterRepo = [self.alphabeticRepo objectForKey:@"-"];
    }
    // first letter is [a .. z] || [A .. Z]
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
    }
    // other cases (foreign languages, ...)
    else
    {
        letterRepo = [self.alphabeticRepo objectForKey:@"#"];
    }
    
    for (NSInteger index = 0; index < letterRepo.count; index++)
    {
        Song* letterSong = [letterRepo objectAtIndex:index];
        if ([letterSong.name isEqualToString:song.name])
        {
            return YES;
        }
    }
    
    return NO;
}





- (void)removeSynchronizedArtist:(NSString*)artistNameFromClient
{
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
  // TODO
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





//
// add a song to the catalog,
//
- (void)catalogWithoutSorting:(Song*)song  usingArtistKey:(NSString*)artistKey andAlbumKey:(NSString*)albumKey
{
    //LBDEBUG
    DevLog(@"catalogWithoutSorting   name '%@'  name_client '%@'         artistKey '%@', artistKey_client '%@'       albumKey '%@', albumKey_client '%@'", song.name, song.name_client, artistKey, song.artist_client, albumKey, song.album_client);
    
    // get what u need to sort alphabetically
    NSString* firstRelevantWord = [song getFirstRelevantWord]; // first title's word, excluding the articles
    
    // just in case of
    if ((firstRelevantWord == nil) || (firstRelevantWord.length == 0))
        firstRelevantWord = @"#";
    
    
    unichar c = [firstRelevantWord characterAtIndex:0];
    
    // we spread the songs, in a dictionnary, and group them depending on their first letter
    // => each table view section will be related to a letter
    
    // first letter is [0 .. 9]
    if ([_numericSet characterIsMember:c]) 
    {
        NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:@"-"];
        [letterRepo addObject:song];
    }
    // first letter is [a .. z] || [A .. Z]
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperCaseChar = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:upperCaseChar];
        [letterRepo addObject:song];
    }
    // other cases (foreign languages, ...)
    else
    {
        NSMutableArray* letterRepo = [self.alphabeticRepo objectForKey:@"#"];
        [letterRepo addObject:song];
    }
    
    
    
    
    
    // now the Artist / Album / Song catalog
    
    c = [artistKey characterAtIndex:0];
    NSMutableDictionary* artistsRepo = nil;

    if ([_numericSet characterIsMember:c])
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"-"];
    }
    else if ([_lowerCaseSet characterIsMember:c] || [_upperCaseSet characterIsMember:c])
    {
        NSString* upperC = [[NSString stringWithCharacters:&c length:1] uppercaseString];
        artistsRepo = [self.alphaArtistsRepo objectForKey:upperC];
    }
    else
    {
        artistsRepo = [self.alphaArtistsRepo objectForKey:@"#"];
    }
    
    NSMutableDictionary* artistRepo = [artistsRepo objectForKey:artistKey];
    if (artistRepo == nil)
    {
        artistRepo = [[NSMutableDictionary alloc] init];
        [artistsRepo setObject:artistRepo forKey:artistKey];
    }
    
    
    // store the song in the right repository
    NSMutableArray* albumRepo = [artistRepo objectForKey:albumKey];
    if (albumRepo == nil)
    {
        albumRepo = [[NSMutableArray alloc] init];
        [artistRepo setObject:albumRepo forKey:albumKey];
    }
    
    [albumRepo addObject:song];
}









//...............................................................................................
//
// tools to handle items selection
//

- (BOOL)selectArtist:(NSString*)artistKey withIndex:(NSString*)charIndex
{
    // first, reset album selection
    self.selectedAlbum = nil;
    self.selectedAlbumRepo = nil;
    NSDictionary* artistsForSection = [self.alphaArtistsRepo objectForKey:charIndex];

    self.selectedArtist = artistKey;
    DLog(@"selected artist %@", self.selectedArtist);
    
    DLog(@"%@", artistsForSection);
    
    self.selectedArtistRepo = [artistsForSection objectForKey:artistKey];
    
    return YES;

}

- (BOOL)selectAlbum:(NSString*)albumKey
{
    if (self.selectedArtistRepo == nil)
        return NO;
    
    self.selectedAlbum = albumKey;
    
    DLog(@"selected album %@", self.selectedAlbum);
    
    self.selectedAlbumRepo = [self.selectedArtistRepo objectForKey:self.selectedAlbum];
    
    return YES;
}



- (Song*)getSongAtRow:(NSInteger)row;
{
    if (self.selectedAlbumRepo == nil)
        return nil;
    
    if (row >= self.selectedAlbumRepo.count)
        return nil;
    
    return [self.selectedAlbumRepo objectAtIndex:row];
}










@end
