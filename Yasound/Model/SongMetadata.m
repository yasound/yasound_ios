//
//  SongMetadata.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SongMetadata.h"

@implementation SongMetadata

@synthesize name;
@synthesize artist_name;
@synthesize album_name;
@synthesize track_index;
@synthesize track_count;
@synthesize disc_index;
@synthesize disc_count;
@synthesize bpm;
@synthesize date;
@synthesize score;
@synthesize duration;
@synthesize genre;


- (NSString*)toString
{
  NSString* desc = [NSString stringWithFormat:@"id: '%@' name: '%@', artist: '%@', album: '%@'", self.id, self.name, self.artist_name, self.album_name];
  return desc;
}

@end
