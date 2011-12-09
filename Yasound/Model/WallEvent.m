//
//  WallEvent.m
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WallEvent.h"

@implementation WallEvent

@synthesize type;
@synthesize text;
@synthesize animated_emoticon;
@synthesize start_date;
@synthesize end_date;
@synthesize song;
@synthesize radio;
@synthesize user;

- (NSString*)toString
{
//  NSString* desc = [NSString stringWithFormat:@"id: '%@' type: '%@', text: '%@'", self.id, self.type, self.text];
  NSString* desc;
  if ([self.type compare:@"J"] == NSOrderedSame)
  {
    desc = [NSString stringWithFormat:@"'%@' joined radio '%@'", [self.user toString], [self.radio toString]];
  }
  else if ([self.type compare:@"L"] == NSOrderedSame)
  {
    desc = [NSString stringWithFormat:@"'%@' left radio '%@'", [self.user toString], [self.radio toString]];
  }
  else if ([self.type compare:@"M"] == NSOrderedSame)
  {
    desc = [NSString stringWithFormat:@"message from '%@'   text: '%@' emoticon: '%@'", [self.user toString], self.text, self. animated_emoticon];
  }
  else if ([self.type compare:@"S"] == NSOrderedSame)
  {
    desc = [NSString stringWithFormat:@"song: '%@'", [self.song toString]];
  }
  return desc;
}

@end
