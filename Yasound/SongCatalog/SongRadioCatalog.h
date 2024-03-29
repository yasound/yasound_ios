//
//  SongRadioCatalog.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "YaRadio.h"

@interface SongRadioCatalog : SongCatalog
{
    NSMutableArray* _data;
    NSInteger _nbReceivedData;
    NSInteger _nbPlaylists;
}


@property (nonatomic, retain) YaRadio* radio;
@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;

@property (nonatomic, retain) NSMutableDictionary* matchedSongs;


+ (SongRadioCatalog*)main;
+ (void)releaseCatalog;

- (void)dump;

- (void)initForRadio:(YaRadio*)radio target:(id)aTarget action:(SEL)anAction;

- (NSDictionary*)songsAll;
- (NSArray*)songsForLetter:(NSString*)charIndex;
- (NSArray*)artistsForLetter:(NSString*)charIndex;

- (NSArray*)albumsForArtist:(NSString*)artist;
- (NSArray*)albumsForArtist:(NSString*)artist withGenre:(NSString*)genre;
- (NSArray*)albumsForArtist:(NSString*)artist withPlaylist:(NSString*)playlist;

- (NSArray*)songsForArtist:(NSString*)artist;
- (NSArray*)songsForArtist:(NSString*)artist withGenre:(NSString*)genre;
- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist;

- (BOOL)addSong:(Song*)song songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey;


- (void)updateSongAddedToProgramming:(Song*)song;
- (void)updateSongRemovedFromProgramming:(Song*)song;
- (void)updateSongUpdated:(Song*)song;



@end
