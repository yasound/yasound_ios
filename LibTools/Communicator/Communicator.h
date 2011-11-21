//
//  Communicator.h
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "ASIHttpRequest.h"

@interface Communicator : NSObject <ASIHTTPRequestDelegate>
{
  NSString* _baseURL;
  
  NSMutableDictionary* _mapping;
}

- (id)initWithBaseURL:(NSString*)base;

- (void)mapResourcePath:(NSString*)path toObject:(Class)objectClass;


#pragma mark - synchronous requests
- (NSArray*)getObjectsWithClass:(Class)objectClass;
- (id)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID;
- (void)postNewObject:(Model*)obj;
- (void)updateObject:(Model*)obj;
- (void)deleteObject:(Model*)obj;


#pragma mark - asynchronous requests
- (void)getObjectsWithClass:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector;
- (void)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID notifyTarget:(id)target byCalling:(SEL)selector;
- (void)postNewObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector;
- (void)updateObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector;
- (void)deleteObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector;

@end
