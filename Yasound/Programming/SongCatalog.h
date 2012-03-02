//
//  SongCatalog.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 02/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"

@interface SongCatalog : NSObject
{
    NSCharacterSet* _numericSet;
    NSCharacterSet* _lowerCaseSet;
    NSCharacterSet* _upperCaseSet;
}

@property (nonatomic, retain) NSMutableDictionary* matchedSongs;

@property (nonatomic, retain) NSMutableArray* indexMap; // "-", "A", "B", ...
@property (nonatomic, retain) NSMutableDictionary* alphabeticRepo;  // "A" => {song1, song2, ...}, "B" ... }
@property (nonatomic, retain) NSMutableDictionary* alphaArtistsRepo; // "A" => {artist1 => { album1 => [song1, ...], ... }, ...}, ...

@property (nonatomic, retain) NSMutableDictionary* alphaArtistsPREORDER; // the dictionary of dictionary which is used during the building, to optimize the building of alphaArtistsOrder
@property (nonatomic, retain) NSMutableDictionary* alphaArtistsOrder; // "A" => [artist1, artist2, ...], "B" ...

@property (nonatomic, retain) NSString* selectedArtist;
@property (nonatomic, retain) NSString* selectedAlbum;
@property (nonatomic, assign) NSDictionary* selectedArtistRepo;
@property (nonatomic, assign) NSArray* selectedAlbumRepo;


+ (SongCatalog*)programmingCatalog;
+ (void)releaseProgrammingCatalog;

- (void)buildWithSource:(NSDictionary*)source;

- (BOOL)selectArtistInSection:(NSInteger)section atRow:(NSInteger)row;
- (BOOL)selectAlbumAtRow:(NSInteger)row;
- (Song*)getSongAtRow:(NSInteger)row;


@end
