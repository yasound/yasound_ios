//
//  User.m
//  MappingTest
//
//  Created by matthieu campion on 11/16/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize firstName;
@synthesize lastName;

- (id)init
{
  self = [super init];
  if (self)
  {
    firstName = @"defaultFirstName";
    lastName = @"defaultLastName";
  }
  return self;
}

@end
