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

typedef void (^YaRequestCompletionBlock)(int, NSString*); // params: (int status_code, NSString* response)


@interface YaRequest : NSObject

- (id)initWithConfig:(YaRequestConfig*)config;

- (void)addRequestHeader:(NSString*)header value:(NSString*)value;
- (void)appendPostData:(NSData*)data;

- (void)startAsynchronous;

@property (nonatomic, copy) YaRequestCompletionBlock completionBlock;

@end
