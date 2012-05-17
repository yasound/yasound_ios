//
//  ASIHTTPRequest+Model.h
//  Yasound
//
//  Created by matthieu campion on 4/17/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "Model.h"
#import "Container.h"

#define REQUEST_CONFIG_USER_INFO_KEY @"RequestConfig"

@interface ASIHTTPRequest (ASIHTTPRequest_YasoundModel)

- (NSDictionary*)responseDict;
- (NSArray*)responseArray;
- (Model*)responseObjectWithClass:(Class)ModelClass;
- (Container*)responseObjectsWithClass:(Class)ModelClass;
- (NSObject*)responseNSObjectWithClass:(Class)ModelClass;
- (NSArray*)responseNSObjectsWithClass:(Class)ModelClass;

- (id)userData;

@end
