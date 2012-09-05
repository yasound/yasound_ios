//
//  SongRadioCatalog.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongCatalog.h"
#import "Radio.h"

@interface SongRadioCatalog : SongCatalog
{
    NSMutableArray* _data;
    NSInteger _nbReceivedData;
    NSInteger _nbPlaylists;
}


@property (nonatomic, retain) Radio* radio;
@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;

@property (nonatomic, retain) NSMutableDictionary* matchedSongs;


+ (SongRadioCatalog*)main;
+ (void)releaseCatalog;

- (void)dump;

- (void)initForRadio:(Radio*)radio target:(id)aTarget action:(SEL)anAction;

- (NSArray*)songsForLetter:(NSString*)charIndex;
- (NSDictionary*)songsAll;
- (BOOL)addSong:(Song*)song songKey:(NSString*)songKey artistKey:(NSString*)artistKey albumKey:(NSString*)albumKey;


@end
