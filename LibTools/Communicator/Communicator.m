//
//  Communicator.m
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "Communicator.h"
#import "NSObject+PropertyDictionary.h"
#import "NSObject+SBJson.h"

@interface Communicator (Communicator_internal)
- (ASIHTTPRequest*)getRequestForObjectsWithURL:(NSString*)path absolute:(BOOL)isAbsolute;
- (ASIHTTPRequest*)getRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute;
- (ASIHTTPRequest*)postRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute;
- (ASIHTTPRequest*)putRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute;
- (ASIHTTPRequest*)deleteRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute;

- (ASIHTTPRequest*)getRequestForObjectsWithClass:(Class)objectClass;
- (ASIHTTPRequest*)getRequestForObjectWithClass:(Class)objectClass andID:(NSNumber*)ID;
- (ASIHTTPRequest*)postRequestForObject:(Model*)obj;
- (ASIHTTPRequest*)putRequestForObject:(Model*)obj;
- (ASIHTTPRequest*)deleteRequestForObject:(Model*)obj;
@end


@implementation Communicator

- (id)initWithBaseURL:(NSString*)base
{
  self = [super init];
  if (self)
  {
    _baseURL = base;
    _mapping = [[NSMutableDictionary alloc] init];
  }
  
  return self;
}

- (void)dealloc
{
  [_mapping release];
}

- (void)mapResourcePath:(NSString*)path toObject:(Class)objectClass
{
  [_mapping setObject:path forKey:objectClass];
}







#pragma mark - synchronous tools

- (Container*)getObjectsWithRequest:(ASIHTTPRequest*)req andClass:(Class)objectClass
{
  if (!req)
    return nil;
  
  [req startSynchronous];
  NSString* response = req.responseString;
  if (!response)
    return nil;
  
  Container* container = [[Container alloc] initWithObjectClass:objectClass];
  [container loadPropertiesFromJsonString:response];
  return container;
}

- (id)getObjectWithRequest:(ASIHTTPRequest*)req andClass:(Class)objectClass
{
  if (!req)
    return nil;
  
  [req startSynchronous];
  NSString* response = req.responseString;
  if (!response)
    return nil;
  
  id obj = [[objectClass alloc] init];
  [obj loadPropertiesFromJsonString:response];
  return obj;
}

- (void)startPostRequest:(ASIHTTPRequest*)req
{
  if (!req)
    return;
  [req startSynchronous]; 
}

- (void)startPutRequest:(ASIHTTPRequest*)req
{
  if (!req)
    return;
  [req startSynchronous]; 
}

- (void)startDeleteRequest:(ASIHTTPRequest*)req
{
  if (!req)
    return;
  [req startSynchronous]; 
}


#pragma mark -  synchronous requests
- (Container*)getObjectsWithClass:(Class)objectClass
{
  ASIHTTPRequest* req = [self getRequestForObjectsWithClass:objectClass];
  Container* container = [self getObjectsWithRequest:req andClass:objectClass];
  return container;
}

- (id)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID
{
  ASIHTTPRequest* req = [self getRequestForObjectWithClass:objectClass andID:ID];
  id obj = [self getObjectWithRequest:req andClass:objectClass];
  return obj;
}

- (void)postNewObject:(Model*)obj
{
  ASIHTTPRequest* req = [self postRequestForObject:obj];
  [self startPostRequest:req];
}

- (void)updateObject:(Model*)obj
{
  ASIHTTPRequest* req = [self putRequestForObject:obj];
  [self startPutRequest:req];
}

- (void)deleteObject:(Model*)obj
{
  ASIHTTPRequest* req = [self deleteRequestForObject:obj];
  [self startDeleteRequest:req];
}


#pragma mark - synchronous requests with URL
- (Container*)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute;
{
  ASIHTTPRequest* req = [self getRequestForObjectsWithURL:url absolute:absolute];
  Container* container = [self getObjectsWithRequest:req andClass:objectClass];
  return container;
}

- (id)getObjectWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute;
{
  ASIHTTPRequest* req = [self getRequestForObjectWithURL:url absolute:absolute];
  id obj = [self getObjectWithRequest:req andClass:objectClass];
  return obj;
}

- (void)postNewObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute;
{
  ASIHTTPRequest* req = [self postRequestForObject:obj withURL:url absolute:absolute];
  [self startPostRequest:req];  
}

- (void)updateObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute;
{
  ASIHTTPRequest* req = [self putRequestForObject:obj withURL:url absolute:absolute];
  [self startPutRequest:req];
}

- (void)deleteObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute;
{
  ASIHTTPRequest* req = [self deleteRequestForObjectWithURL:url absolute:absolute];
  [self startDeleteRequest:req];
}



#pragma mark - asynchronous tools
- (void)notifytarget:(id)target byCalling:(SEL)selector withObject:(id)obj andSuccess:(BOOL)succeeded
{
  NSError* err = nil;
  if (!succeeded)
    err = [NSError errorWithDomain:@"CommunicatorRequestFail" code:1 userInfo:nil];
  
  [target performSelector:selector withObject:obj withObject:err];
}


- (void)getObjectsWithRequest:(ASIHTTPRequest*)req class:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector
{
  if (!req)
    [self notifytarget:target byCalling:selector withObject:nil andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"GET_ALL", @"method", objectClass, @"objectClass", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)getObjectWithRequest:(ASIHTTPRequest*)req class:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector
{
  if (!req)
    [self notifytarget:target byCalling:selector withObject:nil andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"GET", @"method", objectClass, @"objectClass", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)postNewObject:(Model*)obj withRequest:(ASIHTTPRequest*)req notifyTarget:(id)target byCalling:(SEL)selector
{
  if (!req)
    [self notifytarget:target byCalling:selector withObject:obj andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"POST", @"method", obj, @"object", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)updateObject:(Model*)obj withRequest:(ASIHTTPRequest*)req notifyTarget:(id)target byCalling:(SEL)selector
{
  if (!req)
    [self notifytarget:target byCalling:selector withObject:obj andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"PUT", @"method", obj, @"object", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)deleteObject:(Model*)obj withRequest:(ASIHTTPRequest*)req notifyTarget:(id)target byCalling:(SEL)selector
{
  if (!req)
    [self notifytarget:target byCalling:selector withObject:obj andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"DELETE", @"method", obj, @"object", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

#pragma mark - asynchronous requests
- (void)getObjectsWithClass:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self getRequestForObjectsWithClass:objectClass];
  [self getObjectsWithRequest:req class:objectClass notifyTarget:target byCalling:selector];
}

- (void)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self getRequestForObjectWithClass:objectClass andID:ID];
  [self getObjectWithRequest:req class:objectClass notifyTarget:target byCalling:selector];
}

- (void)postNewObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self postRequestForObject:obj];
  [self postNewObject:obj withRequest:req notifyTarget:target byCalling:selector];
}

- (void)updateObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self putRequestForObject:obj];
  [self updateObject:obj withRequest:req notifyTarget:target byCalling:selector];
}

- (void)deleteObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self deleteRequestForObject:obj];
  [self deleteObject:obj withRequest:req notifyTarget:target byCalling:selector];
}

#pragma mark - asynchronous requests with url
- (void)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self getRequestForObjectsWithURL:url absolute:absolute];
  [self getObjectsWithRequest:req class:objectClass notifyTarget:target byCalling:selector];
}

- (void)getObjectWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self getRequestForObjectWithURL:url absolute:absolute];
  [self getObjectWithRequest:req class:objectClass notifyTarget:target byCalling:selector];
}

- (void)postNewObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self postRequestForObject:obj withURL:url absolute:absolute];
  [self postNewObject:obj withRequest:req notifyTarget:target byCalling:selector];
}

- (void)updateObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self putRequestForObject:obj withURL:url absolute:absolute];
  [self updateObject:obj withRequest:req notifyTarget:target byCalling:selector];
}

- (void)deleteObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self deleteRequestForObjectWithURL:url absolute:absolute];
  [self deleteObject:obj withRequest:req notifyTarget:target byCalling:selector];
}




// GET_ALL handler
- (void)handleGetAllResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{  
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Class objectClass = [userinfo valueForKey:@"objectClass"];
  
  if (!succeeded)
  {
    [self notifytarget:target byCalling:selector withObject:nil andSuccess:NO];
    return;
  }
  
  NSString* response = request.responseString;
  if (!response)
  {
    [self notifytarget:target byCalling:selector withObject:nil andSuccess:NO];
    return;
  }
  
  Container* container = [[Container alloc] initWithObjectClass:objectClass];
  [container loadPropertiesFromJsonString:response];
  
  if (!container)
  {
    [self notifytarget:target byCalling:selector withObject:nil andSuccess:NO];
    return;
  }
  
  [self notifytarget:target byCalling:selector withObject:container andSuccess:YES];
}

// GET handler
- (void)handleGetResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{  
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Class objectClass = [userinfo valueForKey:@"objectClass"];
 
  if (!succeeded)
  {
    [self notifytarget:target byCalling:selector withObject:nil andSuccess:NO];
    return;
  }
  
  NSString* response = request.responseString;
  if (!response)
  {
    [self notifytarget:target byCalling:selector withObject:nil andSuccess:NO];
    return;
  }
  
  Model* obj = [[objectClass alloc] init];
  [obj loadPropertiesFromJsonString:response];
  
  if (!obj)
  {
    [self notifytarget:target byCalling:selector withObject:nil andSuccess:NO];
    return;
  }

  [self notifytarget:target byCalling:selector withObject:obj andSuccess:YES];
}

// POST handler
- (void)handlePostResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Model* obj            = [userinfo valueForKey:@"object"];
  
  [self notifytarget:target byCalling:selector withObject:obj andSuccess:succeeded];
}

// PUT handler
- (void)handlePutResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Model* obj            = [userinfo valueForKey:@"object"];
  
  [self notifytarget:target byCalling:selector withObject:obj andSuccess:succeeded];
}

// DELETE handler
- (void)handleDeleteResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Model* obj            = [userinfo valueForKey:@"object"];
  
  [self notifytarget:target byCalling:selector withObject:obj andSuccess:succeeded];
}


- (void)handleResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  NSString* method  = [userinfo valueForKey:@"method"];
  
  if ([method isEqualToString:@"GET_ALL"])
  {
    [self handleGetAllResponse:request success:succeeded];
  }
  else if ([method isEqualToString:@"GET"])
  {
    [self handleGetResponse:request success:succeeded];
  }
  else if ([method isEqualToString:@"POST"])
  {
    [self handlePostResponse:request success:succeeded];
  }
  else if ([method isEqualToString:@"PUT"])
  {
    [self handlePutResponse:request success:succeeded];
  }
  else if ([method isEqualToString:@"DELETE"])
  {
    [self handleDeleteResponse:request success:succeeded];
  }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
  [self handleResponse:request success:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
  [self handleResponse:request success:NO];
}

@end




@implementation Communicator (Communicator_internal)

- (ASIHTTPRequest*)getRequestForObjectsWithURL:(NSString*)path absolute:(BOOL)isAbsolute
{
  NSURL* url;
  if (isAbsolute)
    url = [NSURL URLWithString:path];
  else
  {
    url = [NSURL URLWithString:_baseURL];
    url = [url URLByAppendingPathComponent:path];
  }
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.requestMethod = @"GET";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  
  return req;
}

- (ASIHTTPRequest*)getRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute
{
  NSURL* url;
  if (isAbsolute)
    url = [NSURL URLWithString:path];
  else
  {
    url = [NSURL URLWithString:_baseURL];
    url = [url URLByAppendingPathComponent:path];
  }
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.requestMethod = @"GET";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  
  return req;
}


- (ASIHTTPRequest*)postRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute
{
  if (!obj)
    return nil;
  
  NSString* jsonDesc = [obj JSONRepresentation];
  if (!jsonDesc)
    return nil;
  
  NSURL* url;
  if (isAbsolute)
    url = [NSURL URLWithString:path];
  else
  {
    url = [NSURL URLWithString:_baseURL];
    url = [url URLByAppendingPathComponent:path];
  }
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.requestMethod = @"POST";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  [req addRequestHeader:@"Content-Type" value:@"application/json"];
  
  [req appendPostData:[jsonDesc dataUsingEncoding:NSUTF8StringEncoding]];
  
  return req;
}


- (ASIHTTPRequest*)putRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute
{
  if (!obj)
    return nil;
  
  NSString* jsonDesc = [obj JSONRepresentation];
  if (!jsonDesc)
    return nil;
  
  NSURL* url;
  if (isAbsolute)
    url = [NSURL URLWithString:path];
  else
  {
    url = [NSURL URLWithString:_baseURL];
    url = [url URLByAppendingPathComponent:path];
  }
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.requestMethod = @"PUT";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  [req addRequestHeader:@"Content-Type" value:@"application/json"];
  
  [req appendPostData:[jsonDesc dataUsingEncoding:NSUTF8StringEncoding]];
  
  return req;
}

- (ASIHTTPRequest*)deleteRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute
{
  NSURL* url;
  if (isAbsolute)
    url = [NSURL URLWithString:path];
  else
  {
    url = [NSURL URLWithString:_baseURL];
    url = [url URLByAppendingPathComponent:path];
  }
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.requestMethod = @"DELETE";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  [req addRequestHeader:@"Content-Type" value:@"application/json"];
  
  return req;
}


//////////////////////////////









- (ASIHTTPRequest*)getRequestForObjectsWithClass:(Class)objectClass
{
  NSString* path = [_mapping objectForKey:objectClass];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
  
  ASIHTTPRequest* req = [self getRequestForObjectsWithURL:[url absoluteString] absolute:YES];  
  return req;
}

- (ASIHTTPRequest*)getRequestForObjectWithClass:(Class)objectClass andID:(NSNumber*)ID
{
  NSString* path = [_mapping objectForKey:objectClass];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
  url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/", ID]];
  
  ASIHTTPRequest* req = [self getRequestForObjectWithURL:[url absoluteString] absolute:YES];
  return req;
}

- (ASIHTTPRequest*)postRequestForObject:(Model*)obj
{
  NSString* path = [_mapping objectForKey:[obj class]];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  path = [path stringByAppendingString:@"/"];
  url = [url URLByAppendingPathComponent:path];
  
  ASIHTTPRequest* req = [self postRequestForObject:obj withURL:[url absoluteString] absolute:YES];
  return req;
}

- (ASIHTTPRequest*)putRequestForObject:(Model*)obj
{
  NSString* path = [_mapping objectForKey:[obj class]];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
  url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/", obj.id]];
  
  ASIHTTPRequest* req = [self putRequestForObject:obj withURL:[url absoluteString] absolute:YES];
  return req;
}

- (ASIHTTPRequest*)deleteRequestForObject:(Model*)obj
{
  if (!obj)
    return nil;
  
  NSString* path = [_mapping objectForKey:[obj class]];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
  url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/", obj.id]];
  
  ASIHTTPRequest* req = [self deleteRequestForObjectWithURL:[url absoluteString] absolute:YES];
  return req;
}

@end

