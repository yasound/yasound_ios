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
//@synthesize radio;
//@synthesize target;
//@synthesize action;
@synthesize matchedSongs;
@synthesize nbSongs;

@synthesize alphabeticRepo;
//@synthesize indexMap;
@synthesize alphaArtistsRepo;

@synthesize selectedArtist;
@synthesize selectedAlbum;
@synthesize selectedArtistRepo;
@synthesize selectedAlbumRepo;



//
////...............................................................................................
////
//// Singletons
////
//
//static SongCatalog* _synchronizedCatalog; // for the server's synchronized songs
//static SongCatalog* _availableCatalog;    // for the device's local iTunes songs
//
//
//+ (SongCatalog*)synchronizedCatalog
//{
//    if (_synchronizedCatalog == nil)
//    {
//        _synchronizedCatalog = [[SongCatalog alloc] init];
//
//    }
//    return _synchronizedCatalog;
//}
//
//+ (void)releaseSynchronizedCatalog
//{
//    if (_synchronizedCatalog == nil)
//        return;
//    
//    [_synchronizedCatalog release];
//    _synchronizedCatalog = nil;
//}
//
//+ (SongCatalog*)availableCatalog
//{
//    if (_availableCatalog == nil)
//    {
//        _availableCatalog = [[SongCatalog alloc] init];
//    }
//    return _availableCatalog;
//}
//
//
//+ (void)releaseAvailableCatalog
//{
//    if (_availableCatalog == nil)
//        return;
//    
//    [_availableCatalog release];
//    _availableCatalog = nil;
//}
//


- (NSString*)catalogKeyOfArtist:(NSString*)artist
{
    NSString* artistKey = artist;
    if ((artistKey == nil) || (artistKey.length == 0))
        artistKey = NSLocalizedString(@"ProgrammingView_unknownArtist", nil);
    return artistKey;
}

- (NSString*)catalogKeyOfAlbum:(NSString*)album
{
    NSString* albumKey = album;
    if ((albumKey == nil) || (albumKey.length == 0))
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
        
        
//        self.indexMap = [[NSMutableArray alloc] init];
//        [self initIndexMap];
//        
//        for (NSString* indexKey in self.indexMap)
//        {
//            NSMutableArray* letterRepo = [[NSMutableArray alloc] init];
//            [self.alphabeticRepo setObject:letterRepo forKey:indexKey];
//
//            NSMutableDictionary* letterArtistRepo = [[NSMutableDictionary alloc] init];
//            [self.alphaArtistsRepo setObject:letterArtistRepo forKey:indexKey];
//        }

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








////...............................................................................................
////
//// build catalog from the device's local iTunes songs
////
//- (void)buildAvailableComparingToSource:(NSDictionary*)synchronizedSource
//{
//
//}





//...............................................................................................
//
// common building methods for both catalogs
//










@end
