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

- (void)initFromMatchedSongs:(NSArray*)songs;


@end
