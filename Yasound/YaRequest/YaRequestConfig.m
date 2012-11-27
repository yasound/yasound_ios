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
        self.key = nil;
        self.urlIsAbsolute = NO;
        self.method = @"GET";
        self.params = nil;
        self.auth = nil;
        self.key = nil;
    }
    return self;
}

@end
