//
//  RequestConfig.m
//  Yasound
//
//  Created by matthieu campion on 4/17/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RequestConfig.h"

#import "ASIHTTPRequest.h"

@implementation RequestConfig

@synthesize url = _url;
@synthesize key = _key;
@synthesize urlIsAbsolute = _urlIsAbsolute;
@synthesize method = _method;
@synthesize params = _params;
@synthesize auth = _auth;
@synthesize callbackTarget = _callbackTarget;
@synthesize callbackAction = _callbackAction;
@synthesize userData = _userData;

- (id)init
{
    self = [super init];
    if (self)
    {
        _url = nil;
        _key = nil;
        _urlIsAbsolute = NO;
        _method = @"GET";
        _params = nil;
        _auth = nil;
        _callbackTarget = nil;
        _callbackAction = nil;
        _userData = nil;
    }
    return self;
}

@end
