//
//  APNsDeviceToken.m
//  Yasound
//
//  Created by matthieu campion on 3/29/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "APNsDeviceToken.h"

#define SANDBOX @"sandbox"
#define DEVELOPMENT @"development"

@implementation APNsDeviceToken

@synthesize device_token;
@synthesize device_token_type;
@synthesize uuid;

- (BOOL)isSandbox
{
  return [self.device_token_type isEqualToString:SANDBOX];
}

- (void)setSandbox
{
  self.device_token_type = SANDBOX;
}

- (BOOL)isDevelopment
{
  return [self.device_token_type isEqualToString:DEVELOPMENT];
}

- (void)setDevelopment
{
  self.device_token_type = DEVELOPMENT;
}

@end
