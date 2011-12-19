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
#import "ASIFormDataRequest.h"

@interface Communicator (Communicator_internal)
- (ASIHTTPRequest*)getRequestForObjectsWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth;
- (ASIHTTPRequest*)getRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth;
- (ASIHTTPRequest*)postRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth;
- (ASIHTTPRequest*)putRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth;
- (ASIHTTPRequest*)deleteRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth;

- (ASIHTTPRequest*)getRequestForObjectsWithClass:(Class)objectClass withAuth:(Auth*)auth;
- (ASIHTTPRequest*)getRequestForObjectWithClass:(Class)objectClass andID:(NSNumber*)ID withAuth:(Auth*)auth;
- (ASIHTTPRequest*)postRequestForObject:(Model*)obj withAuth:(Auth*)auth;
- (ASIHTTPRequest*)putRequestForObject:(Model*)obj withAuth:(Auth*)auth;
- (ASIHTTPRequest*)deleteRequestForObject:(Model*)obj withAuth:(Auth*)auth;

@end


@implementation Communicator

- (id)initWithBaseURL:(NSString*)base
{
  self = [super init];
  if (self)
  {
    _baseURL = base;
  }
  
  return self;
}

-(NSURL*)urlWithURL:(NSString*)path absolute:(BOOL)absolute addTrailingSlash:(BOOL)slash params:(NSArray*)params
{
  if (!path || ![path isKindOfClass:[NSString class]])
    return nil;
  
  if (slash && ![path hasSuffix:@"/"])
    path = [path stringByAppendingString:@"/"];
  
  if (params && [params count] > 0)
  {
    if (![path hasSuffix:@"/"])
      path = [path stringByAppendingString:@"/"];
    
    int i = 0;
    for (NSString* s in params) 
    {
      if (i == 0)
        path = [path stringByAppendingString:@"?"];
      else
        path = [path stringByAppendingString:@"&"];
      
      path = [path stringByAppendingString:s];
      i++;
    }
  }
  
  NSURL* url;
  if (absolute)
    url = [NSURL URLWithString:path];
  else
  {
    url = [NSURL URLWithString:_baseURL];
    url = [url URLByAppendingPathComponent:path];
  }
  
  NSLog(@"url: %@", url.absoluteString);
  return url;
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
- (Container*)getObjectsWithClass:(Class)objectClass withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self getRequestForObjectsWithClass:objectClass withAuth:auth];
  Container* container = [self getObjectsWithRequest:req andClass:objectClass];
  return container;
}

- (id)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self getRequestForObjectWithClass:objectClass andID:ID withAuth:auth];
  id obj = [self getObjectWithRequest:req andClass:objectClass];
  return obj;
}

- (void)postNewObject:(Model*)obj withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self postRequestForObject:obj withAuth:auth];
  [self startPostRequest:req];
}

- (void)updateObject:(Model*)obj withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self putRequestForObject:obj withAuth:auth];
  [self startPutRequest:req];
}

- (void)deleteObject:(Model*)obj withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self deleteRequestForObject:obj withAuth:auth];
  [self startDeleteRequest:req];
}


// POST data
- (NSError*)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth
{
  NSURL* u = [self urlWithURL:url absolute:absolute addTrailingSlash:YES params:auth.urlParams];
  NSLog(@"post data url '%@'", u.absoluteString);
  if (!u)
  {
    NSLog(@"post data: invalid url");
    return;
  }
  
  ASIFormDataRequest* req = [[ASIFormDataRequest alloc] initWithURL:u];
  [req addData:data forKey:key];
  [req startSynchronous];
  NSString* response = req.responseString;
  NSLog(@"post data response: %@", response);
  NSError* error = [NSError errorWithDomain:req.responseString code:req.responseStatusCode userInfo:nil];
  return error;
}


#pragma mark - synchronous requests with URL
- (Container*)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
{
  ASIHTTPRequest* req = [self getRequestForObjectsWithURL:url absolute:absolute withAuth:auth];
  Container* container = [self getObjectsWithRequest:req andClass:objectClass];
  return container;
}

- (id)getObjectWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
{
  ASIHTTPRequest* req = [self getRequestForObjectWithURL:url absolute:absolute withAuth:auth];
  id obj = [self getObjectWithRequest:req andClass:objectClass];
  return obj;
}

- (void)postNewObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
{
  ASIHTTPRequest* req = [self postRequestForObject:obj withURL:url absolute:absolute withAuth:auth];
  [self startPostRequest:req];  
}

- (void)updateObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
{
  ASIHTTPRequest* req = [self putRequestForObject:obj withURL:url absolute:absolute withAuth:auth];
  [self startPutRequest:req];
}

- (void)deleteObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
{
  ASIHTTPRequest* req = [self deleteRequestForObjectWithURL:url absolute:absolute withAuth:auth];
  [self startDeleteRequest:req];
}



#pragma mark - asynchronous tools
- (void)notifytarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withObject:(id)obj andSuccess:(BOOL)succeeded
{
  NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
  
  
  NSError* err = nil;
  if (!succeeded)
    err = [NSError errorWithDomain:@"CommunicatorRequestFail" code:1 userInfo:nil];
  
  id result = obj;
  if (obj != nil && [obj class] == [Container class])
  {
    Container* container = (Container*)obj;
    Meta* meta = container.meta;
    result = container.objects;
    
    [meta retain];
    [result retain];
    [container release];
    
    [info setValue:meta forKey:@"meta"];
  }
  
  if (userData)
    [info setValue:userData forKey:@"userData"];
  
  [info setValue:err forKey:@"error"];
  [target performSelector:selector withObject:result withObject:info];
}


- (void)getObjectsWithRequest:(ASIHTTPRequest*)req class:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData
{
  if (!req)
    [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"GET_ALL", @"method", objectClass, @"objectClass", userData, @"userData", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)getObjectWithRequest:(ASIHTTPRequest*)req class:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData
{
  if (!req)
    [self notifytarget:target byCalling:selector withUserData:userData  withObject:nil andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"GET", @"method", objectClass, @"objectClass", userData, @"userData", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)postNewObject:(Model*)obj withRequest:(ASIHTTPRequest*)req notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData returnNewObject:(BOOL)returnNew withAuthForGET:(Auth*)getAuth
{
  if (!req)
    [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"POST", @"method", obj, @"object", userData, @"userData", [NSNumber numberWithBool:returnNew], @"returnNewObject", getAuth, @"authForGET", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)updateObject:(Model*)obj withRequest:(ASIHTTPRequest*)req notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData
{
  if (!req)
    [self notifytarget:target byCalling:selector withUserData:userData withObject:obj andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"PUT", @"method", obj, @"object", userData, @"userData", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

- (void)deleteObject:(Model*)obj withRequest:(ASIHTTPRequest*)req notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData
{
  if (!req)
    [self notifytarget:target byCalling:selector withUserData:userData withObject:obj andSuccess:NO];
  
  NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"DELETE", @"method", obj, @"object", userData, @"userData", nil];
  req.userInfo = userinfo;
  
  req.delegate = self;
  [req startAsynchronous];
}

#pragma mark - asynchronous requests
- (void)getObjectsWithClass:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self getRequestForObjectsWithClass:objectClass withAuth:auth];
  [self getObjectsWithRequest:req class:objectClass notifyTarget:target byCalling:selector withUserData:userData];
}

- (void)getObjectWithClass:(Class)objectClass andID:(NSNumber*)ID notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self getRequestForObjectWithClass:objectClass andID:ID withAuth:auth];
  [self getObjectWithRequest:req class:objectClass notifyTarget:target byCalling:selector withUserData:userData];
}

- (void)postNewObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth returnNewObject:(BOOL)returnNew withAuthForGET:(Auth*)getAuth
{
  ASIHTTPRequest* req = [self postRequestForObject:obj withAuth:auth];
  [self postNewObject:obj withRequest:req notifyTarget:target byCalling:selector withUserData:userData returnNewObject:(BOOL)returnNew withAuthForGET:getAuth];
}

- (void)updateObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self putRequestForObject:obj withAuth:auth];
  [self updateObject:obj withRequest:req notifyTarget:target byCalling:selector withUserData:userData];
}

- (void)deleteObject:(Model*)obj notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self deleteRequestForObject:obj withAuth:auth];
  [self deleteObject:obj withRequest:req notifyTarget:target byCalling:selector withUserData:userData];
}

#pragma mark - asynchronous requests with url
- (void)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self getRequestForObjectsWithURL:url absolute:absolute withAuth:auth];
  [self getObjectsWithRequest:req class:objectClass notifyTarget:target byCalling:selector withUserData:userData];
}

- (void)getObjectWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self getRequestForObjectWithURL:url absolute:absolute withAuth:auth];
  [self getObjectWithRequest:req class:objectClass notifyTarget:target byCalling:selector withUserData:userData];
}

- (void)postNewObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth returnNewObject:(BOOL)returnNew withAuthForGET:(Auth*)getAuth
{
  ASIHTTPRequest* req = [self postRequestForObject:obj withURL:url absolute:absolute withAuth:auth];
  [self postNewObject:obj withRequest:req notifyTarget:target byCalling:selector withUserData:userData returnNewObject:returnNew withAuthForGET:getAuth];
}

- (void)updateObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self putRequestForObject:obj withURL:url absolute:absolute withAuth:auth];
  [self updateObject:obj withRequest:req notifyTarget:target byCalling:selector withUserData:userData];
}

- (void)deleteObject:(Model*)obj withURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
  ASIHTTPRequest* req = [self deleteRequestForObjectWithURL:url absolute:absolute withAuth:auth];
  [self deleteObject:obj withRequest:req notifyTarget:target byCalling:selector withUserData:userData];
}


- (void)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withAuth:(Auth*)auth
{
  NSURL* u = [self urlWithURL:url absolute:absolute addTrailingSlash:YES params:auth.urlParams];
  NSLog(@"post data url '%@'", u.absoluteString);
  if (!u)
  {
    NSLog(@"post data: invalid url");
    return;
  }
  
  NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", @"POST_DATA", @"method", nil];
  
  ASIFormDataRequest* req = [[ASIFormDataRequest alloc] initWithURL:u];
  [req addData:data forKey:key];
  req.userInfo = userInfo;
  req.delegate = self;
  [req startAsynchronous];
}



// GET_ALL handler
- (void)handleGetAllResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{  
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Class objectClass = [userinfo valueForKey:@"objectClass"];
  NSDictionary* userData = [userinfo valueForKey:@"userData"];
  
  if (!succeeded)
  {
    [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];
    return;
  }
  
  NSString* response = request.responseString;
  if (!response)
  {
    [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];
    return;
  }
  
  Container* container = [[Container alloc] initWithObjectClass:objectClass];
  [container loadPropertiesFromJsonString:response];
  
  
  if (!container)
  {
    [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];
    return;
  }
  
  [self notifytarget:target byCalling:selector withUserData:userData withObject:container andSuccess:YES];
}

// GET handler
- (void)handleGetResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{  
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Class objectClass = [userinfo valueForKey:@"objectClass"];
  NSDictionary* userData = [userinfo valueForKey:@"userData"];
  
  if (!succeeded)
  {
    [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];
    return;
  }
  
  NSString* response = request.responseString;
  if (!response)
  {
    [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];
    return;
  }
  
  Model* obj = [[objectClass alloc] init];
  [obj loadPropertiesFromJsonString:response];
  
  if (!obj)
  {
    [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];
    return;
  }

  [self notifytarget:target byCalling:selector withUserData:userData withObject:obj andSuccess:YES];
}




// POST handler
- (void)handlePostResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Model* obj            = [userinfo valueForKey:@"object"];
  BOOL returnNewObject = [[userinfo valueForKey:@"returnNewObject"] boolValue];
  Auth* authForGET = [userinfo valueForKey:@"authForGET"];
  NSDictionary* userData = [userinfo valueForKey:@"userData"];
  
  NSString* location = [request.responseHeaders valueForKey:@"Location"];
  if (returnNewObject)
  {
    [self getObjectWithClass:[obj class] withURL:location absolute:YES notifyTarget:target byCalling:selector withUserData:userData withAuth:authForGET];
  }
  else
  {
    [self notifytarget:target byCalling:selector withUserData:userData withObject:location andSuccess:succeeded];
  }
}

// PUT handler
- (void)handlePutResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Model* obj            = [userinfo valueForKey:@"object"];
  NSDictionary* userData = [userinfo valueForKey:@"userData"];
  
  [self notifytarget:target byCalling:selector withUserData:userData withObject:obj andSuccess:succeeded];
}

// DELETE handler
- (void)handleDeleteResponse:(ASIHTTPRequest *)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  Model* obj            = [userinfo valueForKey:@"object"];
  NSDictionary* userData = [userinfo valueForKey:@"userData"];
  
  [self notifytarget:target byCalling:selector withUserData:userData withObject:obj andSuccess:succeeded];
}

// POST data handler
- (void)handlePostDataResponse:(ASIHTTPRequest*)request success:(BOOL)succeeded
{
  NSDictionary* userinfo = request.userInfo;
  id target         = [userinfo valueForKey:@"target"];
  SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
  
  NSString* response = request.responseString;
  NSLog(@"post data response: %@", response);
  
  NSError* error = nil;
  if (!succeeded)
    error = [NSError errorWithDomain:response code:request.responseStatusCode userInfo:nil];
  
  [target performSelector:selector withObject:error];
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
  else if ([method isEqualToString:@"POST_DATA"])
  {
    [self handlePostDataResponse:request success:succeeded];
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

- (ASIHTTPRequest*)getRequestForObjectsWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth
{
  NSArray* params = nil;
  if (auth && [auth isKindOfClass:[AuthApiKey class]])
  {
    AuthApiKey* a = (AuthApiKey*)auth;
    params = a.urlParams;
  }
  
  NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:params];
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.validatesSecureCertificate = FALSE;
  req.requestMethod = @"GET";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  if (auth && [auth isKindOfClass:[AuthPassword class]])
  {
    AuthPassword* a = (AuthPassword*)auth;
    req.username = a.username;
    req.password = a.password;
  }
  
  return req;
}

- (ASIHTTPRequest*)getRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth
{
  NSArray* params = nil;
  if (auth && [auth isKindOfClass:[AuthApiKey class]])
  {
    AuthApiKey* a = (AuthApiKey*)auth;
    params = a.urlParams;
  }
  
  NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:params];
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.validatesSecureCertificate = FALSE;
  req.requestMethod = @"GET";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  if (auth && [auth isKindOfClass:[AuthPassword class]])
  {
    AuthPassword* a = (AuthPassword*)auth;
    req.username = a.username;
    req.password = a.password;
  }
  
  return req;
}


- (ASIHTTPRequest*)postRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth
{
  if (!obj)
    return nil;
  
  NSString* jsonDesc = [obj JSONRepresentation];
  if (!jsonDesc)
    return nil;
  
  NSArray* params = nil;
  if (auth && [auth isKindOfClass:[AuthApiKey class]])
  {
    AuthApiKey* a = (AuthApiKey*)auth;
    params = a.urlParams;
  }
  
  NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:params];
  
  // todo AUTH
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.validatesSecureCertificate = FALSE;
  req.requestMethod = @"POST";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  [req addRequestHeader:@"Content-Type" value:@"application/json"];
  
  [req appendPostData:[jsonDesc dataUsingEncoding:NSUTF8StringEncoding]];
  
  if (auth && [auth isKindOfClass:[AuthPassword class]])
  {
    AuthPassword* a = (AuthPassword*)auth;
    req.username = a.username;
    req.password = a.password;
  }
  
  return req;
}


- (ASIHTTPRequest*)putRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth
{
  if (!obj)
    return nil;
  
  NSString* jsonDesc = [obj JSONRepresentation];
  if (!jsonDesc)
    return nil;
  
  NSArray* params = nil;
  if (auth && [auth isKindOfClass:[AuthApiKey class]])
  {
    AuthApiKey* a = (AuthApiKey*)auth;
    params = a.urlParams;
  }
  
  NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:params];
  
  // todo AUTH
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.validatesSecureCertificate = FALSE;
  req.requestMethod = @"PUT";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  [req addRequestHeader:@"Content-Type" value:@"application/json"];
  
  [req appendPostData:[jsonDesc dataUsingEncoding:NSUTF8StringEncoding]];
  
  if (auth && [auth isKindOfClass:[AuthPassword class]])
  {
    AuthPassword* a = (AuthPassword*)auth;
    req.username = a.username;
    req.password = a.password;
  }
  
  return req;
}

- (ASIHTTPRequest*)deleteRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth
{
  NSArray* params = nil;
  if (auth && [auth isKindOfClass:[AuthApiKey class]])
  {
    AuthApiKey* a = (AuthApiKey*)auth;
    params = a.urlParams;
  }
  
  NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:params];
  
  // todo AUTH
  
  ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
  req.validatesSecureCertificate = FALSE;
  req.requestMethod = @"DELETE";
  [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
  [req addRequestHeader:@"Content-Type" value:@"application/json"];
  if (auth && [auth isKindOfClass:[AuthPassword class]])
  {
    AuthPassword* a = (AuthPassword*)auth;
    req.username = a.username;
    req.password = a.password;
  }
  
  return req;
}


//////////////////////////////









- (ASIHTTPRequest*)getRequestForObjectsWithClass:(Class)objectClass withAuth:(Auth*)auth
{
//  NSString* path = [_mapping objectForKey:objectClass];
  NSString* path = [Model uriForObjectClass:objectClass];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
  
  ASIHTTPRequest* req = [self getRequestForObjectsWithURL:[url absoluteString] absolute:YES withAuth:auth];  
  return req;
}

- (ASIHTTPRequest*)getRequestForObjectWithClass:(Class)objectClass andID:(NSNumber*)ID withAuth:(Auth*)auth
{
  NSString* path = [Model uriForObjectClass:objectClass andID:ID];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
  
  ASIHTTPRequest* req = [self getRequestForObjectWithURL:[url absoluteString] absolute:YES withAuth:auth];
  return req;
}

- (ASIHTTPRequest*)postRequestForObject:(Model*)obj withAuth:(Auth*)auth
{
  NSString* path = [Model uriForObjectClass:[obj class]];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  path = [path stringByAppendingString:@"/"];
  url = [url URLByAppendingPathComponent:path];
  
  ASIHTTPRequest* req = [self postRequestForObject:obj withURL:[url absoluteString] absolute:YES withAuth:auth];
  return req;
}

- (ASIHTTPRequest*)putRequestForObject:(Model*)obj withAuth:(Auth*)auth
{
  NSString* path = [Model uriForObject:obj];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
  
  ASIHTTPRequest* req = [self putRequestForObject:obj withURL:[url absoluteString] absolute:YES withAuth:auth];
  return req;
}

- (ASIHTTPRequest*)deleteRequestForObject:(Model*)obj withAuth:(Auth*)auth
{
  if (!obj)
    return nil;
  
  NSString* path = [Model uriForObject:obj];
  if (!path)
    return nil;
  
  NSURL* url = [NSURL URLWithString:_baseURL];
  url = [url URLByAppendingPathComponent:path];
//  url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/", obj.id]];
  
  ASIHTTPRequest* req = [self deleteRequestForObjectWithURL:[url absoluteString] absolute:YES withAuth:auth];
  return req;
}

@end

