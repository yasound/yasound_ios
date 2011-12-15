//
//  Auth.m
//  Yasound
//
//  Created by matthieu campion on 12/15/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Auth.h"

@implementation Auth

@synthesize username;

- (id)initWithUsername:(NSString*)name
{
  self = [super init];
  if (self)
  {
    username = name;
  }
  return self;
}

- (NSArray*)urlParams
{
  NSString* s = [NSString stringWithFormat:@"username=%@", username];
  NSArray* params = [NSArray arrayWithObject:s];
  return params;
}

@end

@implementation AuthPassword

@synthesize password;

- (id)initWithUsername:(NSString *)name andPassword:(NSString*)pwd
{
  self = [super initWithUsername:name];
  if (self)
  {
    password = pwd;
  }
  return self;
}

- (NSArray*)urlParams
{
  NSArray* parentParams = [super urlParams];
  NSMutableArray* params = [NSMutableArray arrayWithArray:parentParams];
 
  NSString* s = [NSString stringWithFormat:@"password=%@", password];
  [params addObject:s];
  return params;
}

@end

@implementation AuthApiKey

@synthesize apiKey;

- (id)initWithUsername:(NSString *)name andApiKey:(NSString*)key
{
  self = [super initWithUsername:name];
  if (self)
  {
    apiKey = key;
  }
  return self;
}

- (NSArray*)urlParams
{
  NSArray* parentParams = [super urlParams];
  NSMutableArray* params = [NSMutableArray arrayWithArray:parentParams];
  
  NSString* s = [NSString stringWithFormat:@"api_key=%@", apiKey];
  [params addObject:s];
  return params;
}

@end
