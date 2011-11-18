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


#pragma mark -  synchronous requests

- (id)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID
{
  ASIHTTPRequest* req = [self getRequestForObjectWithClass:objectClass andID:ID];
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

- (void)postNewObject:(Model*)obj
{
  ASIHTTPRequest* req = [self postRequestForObject:obj];
  if (!req)
    return;
  [req startSynchronous];  
}

- (void)updateObject:(Model*)obj
{
  ASIHTTPRequest* req = [self putRequestForObject:obj];
  if (!req)
    return;
  [req startSynchronous];
}

- (void)deleteObject:(Model*)obj
{
  ASIHTTPRequest* req = [self deleteRequestForObject:obj];
  if (!req)
    return;
  [req startSynchronous];
}

#pragma mark - asynchronous requests

- (void)notifytarget:(id)target byCalling:(SEL)selector withObject:(Model*)obj andSuccess:(BOOL)succeeded
{
  NSError* err = nil;
  if (!succeeded)
    err = [NSError errorWithDomain:@"CommunicatorRequestFail" code:1 userInfo:nil];
  
  [target performSelector:selector withObject:obj withObject:err];
}

- (void)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self getRequestForObjectWithClass:objectClass andID:ID];
  if (!req)
    [self notifytarget:target byCalling:selector withObject:nil andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"GET", @"method", objectClass, @"objectClass", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)postNewObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self postRequestForObject:obj];
  if (!req)
    [self notifytarget:target byCalling:selector withObject:obj andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"POST", @"method", obj, @"object", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)updateObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self putRequestForObject:obj];
  if (!req)
    [self notifytarget:target byCalling:selector withObject:obj andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"PUT", @"method", obj, @"object", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)deleteObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector
{
  ASIHTTPRequest* req = [self deleteRequestForObject:obj];
  if (!req)
    [self notifytarget:target byCalling:selector withObject:obj andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"DELETE", @"method", obj, @"object", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}






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

- (void)handlePostResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Model* obj            = [userinfo valueForKey:@"object"];
  
  [self notifytarget:target byCalling:selector withObject:obj andSuccess:succeeded];
}

- (void)handlePutResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Model* obj            = [userinfo valueForKey:@"object"];
  
  [self notifytarget:target byCalling:selector withObject:obj andSuccess:succeeded];
}

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
  
  if ([method isEqualToString:@"GET"])
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

- (ASIHTTPRequest*)getRequestForObjectWithClass:(Class)objectClass andID:(NSNumber*)ID
{
  NSString* path = [_mapping objectForKey:objectClass];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
  
  url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/", ID]];
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.requestMethod = @"GET";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  
  return req;
}

- (ASIHTTPRequest*)postRequestForObject:(Model*)obj
{
  if (!obj)
    return nil;
  
  NSString* path = [_mapping objectForKey:[obj class]];
  if (!path)
    return nil;
  
  NSString* jsonDesc = [obj JSONRepresentation];
  if (!jsonDesc)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  
  path = [path stringByAppendingString:@"/"];
  url = [url URLByAppendingPathComponent:path];
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.requestMethod = @"POST";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  [req addRequestHeader:@"Content-Type" value:@"application/json"];
  
  [req appendPostData:[jsonDesc dataUsingEncoding:NSUTF8StringEncoding]];
  
  return req;
}

- (ASIHTTPRequest*)putRequestForObject:(Model*)obj
{
  if (!obj)
    return nil;
  
  NSString* path = [_mapping objectForKey:[obj class]];
  if (!path)
    return nil;
  
  NSString* jsonDesc = [obj JSONRepresentation];
  if (!jsonDesc)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
  url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/", obj.id]];
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.requestMethod = @"PUT";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  [req addRequestHeader:@"Content-Type" value:@"application/json"];
  
  [req appendPostData:[jsonDesc dataUsingEncoding:NSUTF8StringEncoding]];
  
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
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.requestMethod = @"DELETE";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  [req addRequestHeader:@"Content-Type" value:@"application/json"];
  
  return req;
}

@end

