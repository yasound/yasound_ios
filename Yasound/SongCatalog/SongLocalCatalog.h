//
//  SongLocalCatalog.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"


@interface SongLocalCatalog : SongCatalog


+ (SongLocalCatalog*)main;
+ (void)releaseCatalog;

- (void)initFromMatchedSongs:(NSDictionary*)songs;
- (NSArray*)songsForLetter:(NSString*)charIndex;
- (NSDictionary*)songsAll;
- (void)addSong:(Song*)song songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey;


@end
