//
//  User.m
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize first_name;
@synthesize last_name;
@synthesize username;

- (id)init
{
  self = [super init];
  if (self)
  {
    first_name = @"defaultFirstName";
    last_name = @"defaultLastName";
    username = @"defaultUsername";
  }
  return self;
}

@end
