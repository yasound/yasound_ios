//
//  User.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize username;
@synthesize password;
@synthesize name;
@synthesize api_key;
@synthesize email;
@synthesize picture;

- (NSString*)toString
{
  NSString* desc = [NSString stringWithFormat:@"id: '%@' username: '%@', name: '%@'", self.id, self.username, self.name];
  return desc;
}

@end
