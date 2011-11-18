//
//  Entry.m
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "Entry.h"

@implementation Entry

@synthesize title;
@synthesize slug;
@synthesize body;
@synthesize user;

- (id)init
{
  self = [super init];
  if (self)
  {
    title = @"default title";
    slug = @"defaultSlug";
    body = @"this is the default body text";
    user = nil;
  }
  return self;
}

@end
