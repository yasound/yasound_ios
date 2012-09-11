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

// list of NSString* genre
//@property (nonatomic, retain) NSArray* genres;
//
//// list of NSString* playlist
//@property (nonatomic, retain) NSArray* playlists;
//
//// list of NSString* genre -> NSArray* [NSString* artists]
//@property (nonatomic, retain) NSMutableDictionary* artistsForGenre;
//
//// list of NSString* genre -> NSArray* [NSString* songs songKey] 
//@property (nonatomic, retain) NSMutableDictionary* songsForGenre;
//
//// list of NSString* playlist -> NSArray* [NSString* artists]
//@property (nonatomic, retain) NSMutableDictionary* artistsForPlaylist;
//
//// list of NSString* playlist -> NSArray* [NSString* songs name]  // take care : songs name is not songKey
//@property (nonatomic, retain) NSMutableDictionary* songsForPlaylist;


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

//- (BOOL)removeSong:(NSString*)songKey;

- (void)updateSongAddedToProgramming:(Song*)song;
- (void)updateSongRemovedFromProgramming:(Song*)song;
- (void)updateSongUpdated:(Song*)song;


@end
