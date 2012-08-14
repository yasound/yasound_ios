//
//  SongCatalog.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"
#import "Radio.h"




@interface SongCatalog : NSObject
{
    NSCharacterSet* _numericSet;
    NSCharacterSet* _lowerCaseSet;
    NSCharacterSet* _upperCaseSet;
    
    NSMutableArray* _data;
    NSInteger _nbReceivedData;
    NSInteger _nbPlaylists;
    
}


@property (nonatomic) NSInteger nbSongs;

@property (nonatomic, retain) Radio* radio;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action; // - (void)matchedSongsDownloaded:(NSDictionary*)info success:(NSNumber* BOOL)success;
                                    // info : (NSInteger)nbMatchedSongs infoMessage:(NSString*)infoMessage

@property (nonatomic) BOOL cached;

@property (nonatomic, retain) NSMutableDictionary* matchedSongs;

@property (nonatomic, retain) NSMutableArray* indexMap; // "-", "A", "B", ...
@property (nonatomic, retain) NSMutableDictionary* alphabeticRepo;  // "A" => [song1, song2, ...], "B" ... }
@property (nonatomic, retain) NSMutableDictionary* alphaArtistsRepo; // "A" => {artist1 => {album1 => [song1, ...], ... }, ...}, ...



@property (nonatomic, retain) NSString* selectedArtist;
@property (nonatomic, retain) NSString* selectedAlbum;
@property (nonatomic, assign) NSDictionary* selectedArtistRepo;
@property (nonatomic, assign) NSArray* selectedAlbumRepo;


+ (SongCatalog*)synchronizedCatalog; // for the server's synchronized songs
+ (void)releaseSynchronizedCatalog; // for the device's local iTunes songs

+ (SongCatalog*)availableCatalog;
+ (void)releaseAvailableCatalog;


+ (NSString*)catalogKeyOfSong:(NSString*)name artist:(NSString*)artist album:(NSString*)album;

- (BOOL)doesContainSong:(Song*)song;
- (BOOL)doesDeviceContainSong:(Song*)song;

- (void)downloadMatchedSongsForRadio:(Radio*)radio target:(id)target action:(SEL)action;
- (void)buildSynchronizedWithSource:(NSDictionary*)synchronizedSource;
- (void)buildAvailableComparingToSource:(NSDictionary*)synchronizedSource;

- (void)insertAndEnableSong:(Song*)song;
- (void)removeSynchronizedSong:(Song*)song;



- (BOOL)selectArtist:(NSString*)artistKey withIndex:(NSString*)charIndex;
- (BOOL)selectAlbum:(NSString*)albumKey;


- (Song*)getSongAtRow:(NSInteger)row;


@end
