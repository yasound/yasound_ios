//
//  YaRequestConfig.h
//  Yasound
//
//  Created by mat on 26/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Auth.h"

@interface YaRequestConfig : NSObject

@property (retain, nonatomic) NSString* url;
@property BOOL urlIsAbsolute;
@property (retain, nonatomic) NSString* method;

@property (retain, nonatomic) NSDictionary* params;
@property (retain, nonatomic) NSData* payload;

@property (retain, nonatomic) Auth* auth;

@property (retain, nonatomic) NSString* groupKey;

@property BOOL external; // YES if the request is not destinated to yaapp

- (BOOL)isValid;

+ (YaRequestConfig*)requestConfig;

@end
