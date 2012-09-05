//
//  SongCatalog.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "FMDatabase.h"

#define RADIOCATALOG_TABLE @"radioCatalog"
#define LOCALCATALOG_TABLE @"localCatalog"


@interface SongCatalog : NSObject

@property (nonatomic, retain) FMDatabase* db;
@property (nonatomic, retain) NSString* dbPath;

@property (nonatomic) BOOL isInCache;

@property (nonatomic, retain) NSMutableArray* indexMap; // "-", "A", "B", ...

// cache
@property (nonatomic, retain) NSMutableDictionary* cacheSongs;
@property (nonatomic, retain) NSMutableDictionary* cacheSongsForLetter;
@property (nonatomic, retain) NSMutableDictionary* cacheArtistsForLetter;


- (NSArray*)songsForLetter:(NSString*)charIndex fromTable:(NSString*)table;
- (NSDictionary*)songsAllFromTable:(NSString*)table;



@end
