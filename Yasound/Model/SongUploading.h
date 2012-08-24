//
//  SongUploading.h
//  Yasound
//
//  Created by loïc berthelot.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongLocal.h"


@interface SongUploading : NSObject

@property (nonatomic, retain) SongLocal* songLocal;
@property (nonatomic, retain) NSNumber* radio_id;

+(SongUploading*)new;

- (NSString*)artist;

@end

