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

@end

@implementation AuthApiKey

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
  NSString* u = [NSString stringWithFormat:@"username=%@", username];
  NSString* a = [NSString stringWithFormat:@"api_key=%@", apiKey];
  NSArray* params = [NSArray arrayWithObjects:u, a, nil];
  return params;
}

@end




@implementation AuthSocial

- (id)initWithUsername:(NSString *)name  accountType:(NSString*)type uid:(NSString*)uid token:(NSString*)token expirationDate:(NSString*)expirationDate andEmail:(NSString*)email
{
  self = [super initWithUsername:name];
  if (self)
  {
    [self fillAccountType:type uid:uid token:token expirationDate:expirationDate tokenSecret:nil andEmail:email];
  }
  return self;
}

- (id)initWithUsername:(NSString *)name  accountType:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret andEmail:(NSString*)email
{
  self = [super initWithUsername:name];
  if (self)
  {
    [self fillAccountType:type uid:uid token:token expirationDate:nil tokenSecret:tokenSecret andEmail:email];
  }
  return self;
}

- (void)fillAccountType:(NSString*)type uid:(NSString*)uid token:(NSString*)token expirationDate:(NSString*)expirationDate tokenSecret:(NSString*)tokenSecret andEmail:(NSString*)email;
{
  _accountType = type;
  _uid = uid;
  _token = token;
    _expirationDate = expirationDate;
  _tokenSecret = tokenSecret;
  _email = email;
}

- (NSArray*)urlParams
{
  NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:4];
  
  [params addObject:[NSString stringWithFormat:@"account_type=%@", _accountType]];
  [params addObject:[NSString stringWithFormat:@"uid=%@", _uid]];
  [params addObject:[NSString stringWithFormat:@"token=%@", _token]];
  [params addObject:[NSString stringWithFormat:@"name=%@", username]];
  [params addObject:[NSString stringWithFormat:@"email=%@", _email]];
    if (_expirationDate)
        [params addObject:[NSString stringWithFormat:@"expiration_date=%@", _expirationDate]];
  if (_tokenSecret)
    [params addObject:[NSString stringWithFormat:@"token_secret=%@", _tokenSecret]];
  return params;
}

@end
