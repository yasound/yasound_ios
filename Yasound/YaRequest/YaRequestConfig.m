//
//  YaRequestConfig.m
//  Yasound
//
//  Created by mat on 26/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaRequestConfig.h"

@implementation YaRequestConfig

- (id)init
{
    self = [super init];
    if (self)
    {
        self.url = nil;
        self.urlIsAbsolute = NO;
        self.method = @"GET";
        self.params = nil;
        self.payload = nil;
        self.auth = nil;
        self.groupKey = nil;
    }
    return self;
}

- (BOOL)isValid
{
    if (self.url == nil)
        return NO;
    BOOL get = [self.method isEqualToString:@"GET"];
    BOOL post = [self.method isEqualToString:@"POST"];
    BOOL put = [self.method isEqualToString:@"PUT"];
    BOOL del = [self.method isEqualToString:@"DELETE"];
    if (get == NO && post == NO && put == NO && del == NO)
        return NO;
    
    return YES;
}

@end
