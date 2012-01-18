//
//  Song.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Song.h"

@implementation Song

@synthesize song;
@synthesize metadata;
@synthesize likes;
@synthesize dislikes;


- (NSString*)toString
{
  NSString* desc = [NSString stringWithFormat:@"id: '%@' song: '%@', metadata: '%@'", self.id, self.song, [self.metadata toString]];
  return desc;
}

@end
