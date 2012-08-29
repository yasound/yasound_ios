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
#import "Auth.h"
#import "RequestConfig.h"

@class ASIFormDataRequest;

@interface Communicator : NSObject <ASIHTTPRequestDelegate>
{
    NSString* _baseURL;
    NSHTTPCookie* appCookie;
    
    NSMutableDictionary* requests;
}

@property (retain) NSHTTPCookie* appCookie;

- (id)initWithBaseURL:(NSString*)base;

-(NSURL*)urlWithURL:(NSString*)path absolute:(BOOL)absolute addTrailingSlash:(BOOL)slash params:(NSArray*)params;

- (int)cancelRequestsForTarget:(id)target;
- (void)addRequest:(ASIHTTPRequest*)req forTarget:(id)target;
- (void)removeRequest:(ASIHTTPRequest*)req forTarget:(id)target;

#pragma mark - synchronous requests
- (Container*)getObjectsWithClass:(Class)objectClass withAuth:(Auth*)auth;
- (id)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID withAuth:(Auth*)auth;
- (void)postNewObject:(Model*)obj withAuth:(Auth*)auth;
- (void)updateObject:(Model*)obj withAuth:(Auth*)auth;
- (void)deleteObject:(Model*)obj withAuth:(Auth*)auth;

- (Container*)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
- (id)getObjectWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
- (void)postNewObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
- (void)updateObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
- (void)deleteObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;

- (NSString*)getURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
- (NSError*)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;


#pragma mark - asynchronous requests
- (void)getObjectsWithClass:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;
- (void)getObjectsWithClass:(Class)objectClass withParams:(NSArray*)params notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;
- (void)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;

- (ASIFormDataRequest*)buildPostRequestToURL:(NSString *)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary *)userData withAuth:(Auth *)auth;

- (void)postNewObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth returnNewObject:(BOOL)returnNew withAuthForGET:(Auth*)getAuth;

- (void)updateObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;
- (void)deleteObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;

- (void)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;
- (ASIHTTPRequest*)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute withParams:(NSArray*)params notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;

- (void)getObjectWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;
- (void)postNewObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth  returnNewObject:(BOOL)returnNew withAuthForGET:(Auth*)getAuth;
- (void)updateObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;
- (void)deleteObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;

- (void)getURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;
- (ASIFormDataRequest*)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;
- (ASIFormDataRequest*)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth withProgress:(id)progressDelegate;
- (ASIFormDataRequest*)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth withProgress:(id)progressDelegate withAdditionalJsonData:(NSString*)jsonData;

- (void)postToURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth;


- (void)postToURL:(NSString*)url absolute:(BOOL)absolute withStringData:(NSString*)stringData objectClass:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth  returnNewObject:(BOOL)returnNew withAuthForGET:(Auth*)getAuth;



#pragma mark - API v2
- (ASIHTTPRequest*)buildRequestWithConfig:(RequestConfig*)config;
- (ASIFormDataRequest*)buildFormDataRequestWithConfig:(RequestConfig*)config;

@end