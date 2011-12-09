//
//  SongMetadata.h
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

@interface SongMetadata : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* artist_name;
@property (retain, nonatomic) NSString* album_name;
@property (retain, nonatomic) NSNumber* track_index;
@property (retain, nonatomic) NSNumber* track_count;
@property (retain, nonatomic) NSNumber* disc_index;
@property (retain, nonatomic) NSNumber* disc_count;
@property (retain, nonatomic) NSNumber* bpm;
@property (retain, nonatomic) NSDate* date;
@property (retain, nonatomic) NSNumber* score;
@property (retain, nonatomic) NSNumber* duration;
@property (retain, nonatomic) NSString* genre;


- (NSString*)toString;

@end
