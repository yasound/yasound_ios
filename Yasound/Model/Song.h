//
//  Song.h
//  Yasound
//
//  Created by matthieu campion on 1/27/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"

typedef enum 
{
  eSongFrequencyTypeLow = 0,
  eSongFrequencyTypeNormal,
  eSongFrequencyTypeHigh,
  eSongFrequencyTypeNone,
} SongFrequencyType;

@interface Song : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* artist;
@property (retain, nonatomic) NSString* album;
@property (retain, nonatomic) NSString* cover;
@property (retain, nonatomic) NSNumber* song;
@property (retain, nonatomic) NSNumber* need_sync;
@property (retain, nonatomic) NSNumber* likes;
@property (retain, nonatomic) NSDate* last_play_time;
@property (retain, nonatomic) NSString* frequency;

- (SongFrequencyType)frequencyType;
- (void)setFrequencyType:(SongFrequencyType)f;

@end

@interface SongStatus : Model

@property (retain, nonatomic) NSNumber* likes;
@property (retain, nonatomic) NSNumber* dislikes;

@end
