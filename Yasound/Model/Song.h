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
  eSongFrequencyTypeNormal = 0,
  eSongFrequencyTypeHigh,
  eSongFrequencyTypeNone,
} SongFrequencyType;

@interface Song : Model
{
    NSString* _name;
    NSString* _nameWithoutArticle;
    NSString* _firstRelevantWord;
    BOOL _uploading;
}

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* artist;
@property (retain, nonatomic) NSString* album;
@property (retain, nonatomic) NSString* cover;
@property (retain, nonatomic) NSNumber* song;
@property (retain, nonatomic) NSNumber* need_sync;
@property (retain, nonatomic) NSNumber* likes;
@property (retain, nonatomic) NSDate* last_play_time;
@property (retain, nonatomic) NSNumber* frequency;
@property (retain, nonatomic) NSNumber* enabled;

- (SongFrequencyType)frequencyType;
- (void)setFrequencyType:(SongFrequencyType)f;

- (BOOL)isSongEnabled;
- (void)enableSong:(BOOL)on;

- (BOOL)isUploading;
- (void)setUploading:(BOOL)set;

- (NSString*)getFirstRelevantWord;
- (NSString*)getNameWithoutArticle;

- (NSComparisonResult)nameCompare:(Song*)second;
- (NSComparisonResult)artistCompare:(Song*)second;
- (NSComparisonResult)albumCompare:(Song*)second;

@end





@interface SongStatus : Model

@property (retain, nonatomic) NSNumber* likes;
@property (retain, nonatomic) NSNumber* dislikes;

@end
