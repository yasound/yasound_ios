//
//  YaRequest.h
//  Yasound
//
//  Created by mat on 26/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YaRequestConfig.h"
#import "Model.h"
#import "Container.h"
#import "ASIHTTPRequest.h"

typedef void (^YaRequestCompletionBlock)(int, NSString*, NSError*); // params: (int status_code, NSString* response, NSError* error)
typedef void (^YaRequestProgressBlock)(unsigned long long size, unsigned long long total);



@interface YaRequest : NSObject
{
    YaRequestConfig* _config;
    ASIHTTPRequest* _request;
}

+ (void)globalInit;
+ (void)setBaseURL:(NSString*)url;
+ (NSString*)baseURL;

- (id)initWithConfig:(YaRequestConfig*)config;

- (BOOL)start:(YaRequestCompletionBlock)completionBlock;
- (BOOL)start:(YaRequestCompletionBlock)completionBlock progressBlock:(YaRequestProgressBlock) progressBlock;

- (void)cancel;
+ (void)cancelWithKey:(NSString*)key;


@end
