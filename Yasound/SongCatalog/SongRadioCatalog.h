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


@property (nonatomic, retain) Radio* radio;
@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;




+ (SongRadioCatalog*)main;
+ (void)releaseCatalog;

- (void)initForRadio:(Radio*)radio target:(id)aTarget action:(SEL)anAction;

- (NSArray*)songsForLetter:(NSString*)charIndex;
- (NSDictionary*)songsAll;


@end
