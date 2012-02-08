//
//  Playlist.h
//  Yasound
//
//  Created by matthieu campion on 12/14/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

@interface Playlist : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* source;
@property (retain, nonatomic) NSNumber* enabled;
@property (retain, nonatomic) NSNumber* song_count;
@property (retain, nonatomic) NSNumber* matched_song_count;
@property (retain, nonatomic) NSNumber* unmatched_song_count;

@end
