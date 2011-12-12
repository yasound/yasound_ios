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
@synthesize first_name;
@synthesize last_name;


- (NSString*)toString
{
  NSString* desc = [NSString stringWithFormat:@"id: '%@' username: '%@', first name: '%@', last name: '%@'", self.id, self.username, self.first_name, self.last_name];
  return desc;
}

@end
