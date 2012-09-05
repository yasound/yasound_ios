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



#define RADIOCATALOG_TABLE @"radioCatalog"
#define LOCALCATALOG_TABLE @"localCatalog"


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
    eCatalogSong
} CatalogTable;



@property (nonatomic, retain) FMDatabase* db;
@property (nonatomic, retain) NSString* dbPath;

@property (nonatomic) BOOL isInCache;

@property (nonatomic, retain) NSMutableArray* indexMap; // "-", "A", "B", ...

// cache
@property (nonatomic, retain) NSMutableDictionary* songs;
@property (nonatomic, retain) NSMutableDictionary* songsForLetter;
@property (nonatomic, retain) NSMutableDictionary* artistsForLetter;

@property (nonatomic, retain) NSString* selectedArtist;
@property (nonatomic, retain) NSString* selectedAlbum;


+ (NSString*)catalogKeyOfSong:(NSString*)name artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey;
+ (NSString*)shortString:(NSString*)source;


- (NSArray*)songsForLetter:(NSString*)charIndex fromTable:(NSString*)table;
- (NSDictionary*)songsAllFromTable:(NSString*)table;
- (BOOL)addSong:(Song*)song forTable:(NSString*)table songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey;



@end
