//
//  Song.m
//  Yasound
//
//  Created by matthieu campion on 1/27/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Song.h"

@implementation Song

@synthesize name;
@synthesize artist;
@synthesize album;
@synthesize cover;
@synthesize song;
@synthesize need_sync;
@synthesize likes;
@synthesize last_play_time;
@synthesize frequency;
@synthesize enabled;

- (SongFrequencyType)frequencyType
{
  if (!self.frequency)
    return eSongFrequencyTypeNone;
  
  float f = [self.frequency floatValue];
  if (f > 0.75)
    return eSongFrequencyTypeHigh;
  
  return eSongFrequencyTypeNormal;
}

- (void)setFrequencyType:(SongFrequencyType)f
{
  switch (f) 
  {
    case eSongFrequencyTypeNormal:
      self.frequency = [NSNumber numberWithFloat:0.5];
      break;
      
    case eSongFrequencyTypeHigh:
      self.frequency = [NSNumber numberWithFloat:1];
      break;
      
    case eSongFrequencyTypeNone:
    default:
      self.frequency = [NSNumber numberWithFloat:0];
      break;
  }
}

- (BOOL)isSongEnabled
{
  return [self.enabled boolValue];
}

- (void)enableSong:(BOOL)on
{
  self.enabled = [NSNumber numberWithBool:on];
}


- (NSComparisonResult)nameCompare:(Song*)second
{
    return [self.name compare:second.name];
}

- (NSComparisonResult)ArtistNameCompare:(Song*)second
{
    return [self.artist compare:second.artist];
}

- (NSComparisonResult)AlbumNameCompare:(Song*)second
{
    return [self.album compare:second.album];
}






@end


@implementation SongStatus

@synthesize likes;
@synthesize dislikes;

@end
