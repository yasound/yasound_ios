//
//  Song.m
//  Yasound
//
//  Created by matthieu campion on 1/27/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Song.h"

#define FREQUENCY_TYPE_LOW_STRING     @"L"
#define FREQUENCY_TYPE_NORMAL_STRING  @"N"
#define FREQUENCY_TYPE_HIGH_STRING    @"H"

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

- (SongFrequencyType)frequencyType
{
  if ([self.frequency isEqualToString:FREQUENCY_TYPE_LOW_STRING])
    return eSongFrequencyTypeLow;
  else if ([self.frequency isEqualToString:FREQUENCY_TYPE_NORMAL_STRING])
    return eSongFrequencyTypeNormal;
  else if ([self.frequency isEqualToString:FREQUENCY_TYPE_HIGH_STRING])
    return eSongFrequencyTypeHigh;
  
  return eSongFrequencyTypeNone;
}

- (void)setFrequencyType:(SongFrequencyType)f
{
  switch (f) 
  {
    case eSongFrequencyTypeLow:
      self.frequency = FREQUENCY_TYPE_LOW_STRING;
      break;
      
    case eSongFrequencyTypeNormal:
      self.frequency = FREQUENCY_TYPE_NORMAL_STRING;
      break;
      
    case eSongFrequencyTypeHigh:
      self.frequency = FREQUENCY_TYPE_HIGH_STRING;
      break;
      
    case eSongFrequencyTypeNone:
    default:
      self.frequency = @"";
      break;
  }
}

@end


@implementation SongStatus

@synthesize likes;
@synthesize dislikes;

@end
