//
//  SongLocalCatalog.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"


@interface SongLocalCatalog : SongCatalog

@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;


// cache
@property (nonatomic, retain) NSArray* genres;
@property (nonatomic, retain) NSArray* playlists;
@property (nonatomic, retain) NSMutableDictionary* artistsForGenre;
@property (nonatomic, retain) NSMutableDictionary* songsForGenre;
@property (nonatomic, retain) NSMutableDictionary* artistsForPlaylist;
@property (nonatomic, retain) NSMutableDictionary* songsForPlaylist;


+ (SongLocalCatalog*)main;
+ (void)releaseCatalog;

- (void)dump;

- (void)initFromMatchedSongs:(NSDictionary*)songs target:(id)aTarget action:(SEL)anAction;
- (NSArray*)songsForLetter:(NSString*)charIndex;
- (NSArray*)artistsForLetter:(NSString*)charIndex;
- (NSArray*)albumsForArtist:(NSString*)artist;
- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist;

- (NSArray*)genresAll;
- (NSArray*)artistsForGenre:(NSString*)genre;
- (NSArray*)songsForGenre:(NSString*)genre;
- (NSArray*)playlistsAll;
- (NSArray*)artistsForPlaylist:(NSString*)playlist;
- (NSArray*)songsForPlaylist:(NSString*)playlist;


- (NSDictionary*)songsAll;

- (BOOL)addSong:(Song*)song songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey;
- (BOOL)addSong:(Song*)song forPlaylist:(NSString*)playlist;


@end
