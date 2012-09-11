//
//  SongCatalog.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "FMDatabase.h"
#import "Song.h"





@interface SongCatalog : NSObject
{
    NSCharacterSet* _numericSet;
    NSCharacterSet* _lowerSet;
    NSCharacterSet* _upperSet;
}


typedef enum {
    
    eCatalogSongKey = 0,
    eCatalogName,
    eCatalogNameLetter,
    eCatalogArtistKey,
    eCatalogArtistLetter,
    eCatalogAlbumKey,
    eCatalogGenre,
} CatalogTable;




@property (nonatomic) BOOL isInCache;

@property (nonatomic, retain) NSMutableArray* indexMap; // "-", "A", "B", ...


// cache

// NSString* songKey -> Song* song
@property (nonatomic, retain) NSMutableDictionary* songsDb;

//@property (nonatomic, retain) NSMutableDictionary* songs;


@property (nonatomic, retain) NSMutableDictionary* catalogCache;

//// NSString* letter -> NSArray[NSString* songKey]
//@property (nonatomic, retain) NSMutableDictionary* songsForLetter;
//
//// NSString* letter -> NSArray[NSString* artistKey]
//@property (nonatomic, retain) NSMutableDictionary* artistsForLetter;
//
//// NSString* artistKey -> NSArray[NSString* albumKey]
//@property (nonatomic, retain) NSMutableDictionary* albumsForArtist;
//@property (nonatomic, retain) NSMutableDictionary* albumsForArtistWithGenre;
//@property (nonatomic, retain) NSMutableDictionary* albumsForArtistWithPlaylist;
//
//// NSString* artistKey -> NSDictionary [ NSString* albumKey -> NSArray[NSString* songKey]]
//@property (nonatomic, retain) NSMutableDictionary* songsForArtistAlbum;




@property (nonatomic, retain) NSString* selectedArtist;
@property (nonatomic, retain) NSString* selectedArtistIndexChar;
@property (nonatomic, retain) NSString* selectedAlbum;

@property (nonatomic, retain) NSString* selectedGenre;
@property (nonatomic, retain) NSString* selectedPlaylist;


+ (NSString*)catalogKeyOfSong:(NSString*)name artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey;
+ (NSString*)shortString:(NSString*)source;


- (NSArray*)songsForLetter:(NSString*)charIndex fromTable:(NSString*)table;
- (NSArray*)artistsForLetter:(NSString*)charIndex fromTable:(NSString*)table;

- (NSArray*)albumsForArtist:(NSString*)artist fromTable:(NSString*)table;
- (NSArray*)albumsForArtist:(NSString*)artist withGenre:genre fromTable:(NSString*)table;
- (NSArray*)albumsForArtist:(NSString*)artist withPlaylist:playlist fromTable:(NSString*)table;

- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist fromTable:(NSString*)table;
- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withGenre:(NSString*)genre fromTable:(NSString*)table;
- (NSArray*)songsForAlbum:(NSString*)album fromArtist:(NSString*)artist withPlaylist:(NSString*)playlist fromTable:(NSString*)table;

- (NSDictionary*)songsAllFromTable:(NSString*)table;


- (void)beginTransaction;
- (BOOL)addSong:(Song*)song forTable:(NSString*)table songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey;
- (void)commit;

- (BOOL)selectArtist:(NSString*)artistKey withCharIndex:(NSString*)charIndex;
- (BOOL)selectAlbum:(NSString*)albumKey;

- (BOOL)removeSong:(NSString*)songKey forTable:(NSString*)table;


@end
