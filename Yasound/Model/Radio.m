//
//  Radio.m
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Radio.h"

@implementation Radio

@synthesize name;
@synthesize creator;
@synthesize description;
@synthesize genre;
@synthesize theme;
@synthesize url;
@synthesize playlists;

-(NSString*)toString
{
  NSString* desc = [NSString stringWithFormat:@"name: '%@', creator: '%@', description: '%@', genre: '%@', theme: '%@', url: '%@' playlist count: '%d", self.name, self.creator, self.description, self.genre, self.theme, self.url, [self.playlists count]];
  return desc;
}

@end