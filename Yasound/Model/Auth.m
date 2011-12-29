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


@implementation AuthCookie

- (id)initWithUsername:(NSString *)name andCookieValue:(NSString*)val
{
  self = [super initWithUsername:name];
  if (self)
  {
    _cookieValue = val;
  }
  return self;
}

- (NSHTTPCookie*)cookie
{
  NSDictionary* properties = [[[NSMutableDictionary alloc] init] autorelease];
  [properties setValue:_cookieValue forKey:NSHTTPCookieValue];
  [properties setValue:username forKey:NSHTTPCookieName];
  [properties setValue:@"yasound.com" forKey:NSHTTPCookieDomain];
  [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
  [properties setValue:@"/yasound/app_auth" forKey:NSHTTPCookiePath];
  NSHTTPCookie* cookie = [[NSHTTPCookie alloc] initWithProperties:properties];

  return cookie;
}

@end