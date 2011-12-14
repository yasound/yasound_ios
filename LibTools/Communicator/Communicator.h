//
//  Communicator.h
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "Container.h"
#import "ASIHttpRequest.h"

@interface Communicator : NSObject <ASIHTTPRequestDelegate>
{
  NSString* _baseURL;
}

- (id)initWithBaseURL:(NSString*)base;

-(NSURL*)urlWithURL:(NSString*)path absolute:(BOOL)absolute addTrailingSlash:(BOOL)slash;

#pragma mark - synchronous requests
- (Container*)getObjectsWithClass:(Class)objectClass;
- (id)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID;
- (void)postNewObject:(Model*)obj;
- (void)updateObject:(Model*)obj;
- (void)deleteObject:(Model*)obj;

- (Container*)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute;
- (id)getObjectWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute;
- (void)postNewObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute;
- (void)updateObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute;
- (void)deleteObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute;


#pragma mark - asynchronous requests
- (void)getObjectsWithClass:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector;
- (void)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID notifyTarget:(id)target byCalling:(SEL)selector;
- (void)postNewObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector;
- (void)updateObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector;
- (void)deleteObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector;

- (void)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector;
- (void)getObjectWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector;
- (void)postNewObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector;
- (void)updateObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector;
- (void)deleteObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector;

@end
