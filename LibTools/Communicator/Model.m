//
//  Model.m
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "Model.h"

@implementation Model

@synthesize id = _id;

- (id)init
{
  self = [super init];
  if (self)
  {
    _id = [NSNumber numberWithInt:0];
  }
  return self;
}
@end
