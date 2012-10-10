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




+ (SongLocalCatalog*)main;
+ (void)releaseCatalog;

- (void)dump;

- (void)initFromMatchedSongs:(NSDictionary*)songs target:(id)aTarget action:(SEL)anAction;
- (NSArray*)songsForLetter:(NSString*)charIndex;
- (NSArray*)artistsForLetter:(NSString*)charIndex;

- (NSArray*)albumsForArtist:(NSString*)artist;
- (NSArray*)albumsForArtist:(NSString*)artist withGenre:(NSString*)genre;
- (NSArray*)albumsForArtist:(NSString*)artist withPlaylist:(NSString*)playlist;

- (NSArray*)songsForArtist:(NSString*)artist;
- (NSArray*)songsForArtist:(NSString*)artist withGenre:(NSString*)genre;
- (NSArray*)songsForArtist:(NSString*)artist withPlaylist:(NSString*)playlist;
- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist;
- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withGenre:(NSString*)genre;
- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withPlaylist:(NSString*)playlist;

- (NSArray*)genresAll;
- (NSArray*)artistsForGenre:(NSString*)genre;
- (NSArray*)songsForGenre:(NSString*)genre;
- (NSArray*)playlistsAll;
- (NSArray*)artistsForPlaylist:(NSString*)playlist;
- (NSArray*)songsForPlaylist:(NSString*)playlist;


- (NSDictionary*)songsAll;

- (BOOL)addSong:(Song*)song songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey;
- (BOOL)addSong:(Song*)song forPlaylist:(NSString*)playlist;


- (void)updateSongAddedToProgramming:(Song*)song;
- (void)updateSongRemovedFromProgramming:(Song*)song;
- (void)updateSongUpdated:(Song*)song;


@end
