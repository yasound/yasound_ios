//
//  Post.m
//  MappingTest
//
//  Created by matthieu campion on 11/16/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "Post.h"
#import "SBJsonStreamWriter.h"

@implementation Post

@synthesize title;
@synthesize text;
@synthesize note;
@synthesize author;

- (id)init
{
  self = [super init];
  if (self)
  {
    title = @"default title";
    text = @"default text";
    note = [NSNumber numberWithFloat:0.1];
    author = nil;
  }
  
  return self;
}

@end
