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

- (NSString*)toString
{
  NSString* desc = [NSString stringWithFormat:@"id: '%@' type: '%@', text: '%@'", self.id, self.type, self.text];
  return desc;
}
@end
