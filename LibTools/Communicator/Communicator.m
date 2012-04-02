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
- (ASIHTTPRequest*)getRequestForObjectsWithURL:(NSString*)path absolute:(BOOL)isAbsolute withUrlParams:(NSArray*)params withAuth:(Auth*)auth;
- (ASIHTTPRequest*)getRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth;
- (ASIHTTPRequest*)postRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth;
- (ASIHTTPRequest*)putRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth;
- (ASIHTTPRequest*)deleteRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth;

- (ASIHTTPRequest*)postRequestForURL:(NSString*)path absolute:(BOOL)isAbsolute withStringData:(NSString*)stringData withAuth:(Auth*)auth;
- (ASIHTTPRequest*)putRequestForURL:(NSString*)path absolute:(BOOL)isAbsolute withStringData:(NSString*)stringData withAuth:(Auth*)auth;

- (ASIHTTPRequest*)getRequestForObjectsWithClass:(Class)objectClass withAuth:(Auth*)auth;
- (ASIHTTPRequest*)getRequestForObjectsWithClass:(Class)objectClass withUrlParams:(NSArray*)urlParams withAuth:(Auth*)auth;
- (ASIHTTPRequest*)getRequestForObjectWithClass:(Class)objectClass andID:(NSNumber*)ID withAuth:(Auth*)auth;
- (ASIHTTPRequest*)postRequestForObject:(Model*)obj withAuth:(Auth*)auth;
- (ASIHTTPRequest*)putRequestForObject:(Model*)obj withAuth:(Auth*)auth;
- (ASIHTTPRequest*)deleteRequestForObject:(Model*)obj withAuth:(Auth*)auth;

- (void)applyAuth:(Auth*)auth toRequest:(ASIHTTPRequest*)request;
- (void)fillRequest:(ASIHTTPRequest*)request;
- (NSURL*)URLWithURL:(NSURL*)url andParams:(NSArray*)params;
@end


@implementation Communicator

@synthesize appCookie;

- (void)callAction:(SEL)action onTarget:(id)target withObject:(id)obj1 withObject:(id)obj2
{
    if (!target)
        return;
    
    if (action)
        [target performSelector:action withObject:obj1 withObject:obj2];
    
    //LBDEBUG heuuuu c'est un peu chaud chaud de faire ça non? à voir avec mat...
    [target release];
}

- (id)initWithBaseURL:(NSString*)base
{
    self = [super init];
    if (self)
    {
        _baseURL = base;
        [ASIHTTPRequest setDefaultTimeOutSeconds:30];
    }
    
    return self;
}

-(NSURL*)urlWithURL:(NSString*)path absolute:(BOOL)absolute addTrailingSlash:(BOOL)slash params:(NSArray*)params
{
    if (!path || ![path isKindOfClass:[NSString class]])
        return nil;
    
    if (slash && ![path hasSuffix:@"/"])
        path = [path stringByAppendingString:@"/"];

    NSURL* url;
    if (absolute)
        url = [NSURL URLWithString:path];
    else
    {
        url = [NSURL URLWithString:_baseURL];
        if ([path hasPrefix:@"/"] && path.length > 1)
            path = [path substringFromIndex:1];
        url = [url URLByAppendingPathComponent:path];
    }
    
    url = [self URLWithURL:url andParams:params];
    
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


- (NSString*)getURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth
{
    NSURL* u = [self urlWithURL:url absolute:absolute addTrailingSlash:YES params:nil];
    if (!u)
    {
        return nil;
    }
    
    ASIHTTPRequest* req = [[ASIHTTPRequest alloc] initWithURL:u];
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    [req startSynchronous];
    NSString* response = req.responseString;
    return response;
}

// POST data
- (NSError*)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth
{
    NSURL* u = [self urlWithURL:url absolute:absolute addTrailingSlash:YES params:nil];
    NSLog(@"post data url '%@'", u.absoluteString);
    if (!u)
    {
        NSLog(@"post data: invalid url");
    }
    
    ASIFormDataRequest* req = [[ASIFormDataRequest alloc] initWithURL:u];
    [req addData:data forKey:key];
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    [req startSynchronous];
    NSString* response = req.responseString;
    NSLog(@"post data response: %@", response);
    NSError* error = [NSError errorWithDomain:req.responseString code:req.responseStatusCode userInfo:nil];
    return error;
}


#pragma mark - synchronous requests with URL
- (Container*)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute withAuth:(Auth*)auth;
{
    ASIHTTPRequest* req = [self getRequestForObjectsWithURL:url absolute:absolute withUrlParams:nil withAuth:auth];
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
    
    [info setObject:[NSNumber numberWithBool:succeeded] forKey:@"succeeded"];
    
    [info setValue:err forKey:@"error"];
    [self callAction:selector onTarget:target withObject:result withObject:info];
}


- (void)getObjectsWithRequest:(ASIHTTPRequest*)req class:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData
{
    if (!req)
        [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];

    NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] init];

    [userinfo setValue:target forKey:@"target"];
    [userinfo setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [userinfo setValue:@"GET_ALL" forKey:@"method"];
    [userinfo setValue:objectClass forKey:@"objectClass"];
    [userinfo setValue:userData forKey:@"userData"];
    
    req.userInfo = userinfo;
    
    req.delegate = self;
    [req startAsynchronous];
}

- (void)getObjectWithRequest:(ASIHTTPRequest*)req class:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData
{
    if (!req)
        [self notifytarget:target byCalling:selector withUserData:userData  withObject:nil andSuccess:NO];
    
    NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] init];
    [userinfo setValue:target forKey:@"target"];
    [userinfo setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [userinfo setValue:@"GET" forKey:@"method"];
    [userinfo setValue:objectClass forKey:@"objectClass"];
    [userinfo setValue:userData forKey:@"userData"];
    
    req.userInfo = userinfo;
    
    req.delegate = self;
    [req startAsynchronous];
}

- (void)postNewObject:(Class)objectClass withRequest:(ASIHTTPRequest*)req notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData returnNewObject:(BOOL)returnNew withAuthForGET:(Auth*)getAuth
{
    if (!req)
        [self notifytarget:target byCalling:selector withUserData:userData withObject:nil andSuccess:NO];
    
    NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] init];
    [userinfo setValue:target forKey:@"target"];
    [userinfo setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [userinfo setValue:@"POST" forKey:@"method"];
    [userinfo setValue:objectClass forKey:@"objectClass"];
    [userinfo setValue:userData forKey:@"userData"];
    [userinfo setValue:returnNew forKey:@"returnNewObject"];
    [userinfo setValue:getAuth forKey:@"authForGET"];
    
    req.userInfo = userinfo;
    
    req.delegate = self;
    [req startAsynchronous];
}

- (void)updateObject:(Model*)obj withRequest:(ASIHTTPRequest*)req notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData
{
    if (!req)
        [self notifytarget:target byCalling:selector withUserData:userData withObject:obj andSuccess:NO];
    
    NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] init];
    [userinfo setValue:target forKey:@"target"];
    [userinfo setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [userinfo setValue:@"PUT" forKey:@"method"];
    [userinfo setValue:obj forKey:@"object"];
    [userinfo setValue:userData forKey:@"userData"];
    
    req.userInfo = userinfo;
    
    req.delegate = self;
    [req startAsynchronous];
}


- (void)deleteObject:(Model*)obj withRequest:(ASIHTTPRequest*)req notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData
{
    if (!req)
        [self notifytarget:target byCalling:selector withUserData:userData withObject:obj andSuccess:NO];
    
    NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] init];
    [userinfo setValue:target forKey:@"target"];
    [userinfo setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [userinfo setValue:@"DELETE" forKey:@"method"];
    [userinfo setValue:obj forKey:@"object"];
    [userinfo setValue:userData forKey:@"userData"];
    
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

- (void)getObjectsWithClass:(Class)objectClass withParams:(NSArray*)params notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
    ASIHTTPRequest* req = [self getRequestForObjectsWithClass:objectClass withUrlParams:params withAuth:auth];
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
    [self postNewObject:[obj class] withRequest:req notifyTarget:target byCalling:selector withUserData:userData returnNewObject:(BOOL)returnNew withAuthForGET:getAuth];
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
    [self getObjectsWithClass:objectClass withURL:url absolute:absolute withParams:nil notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
}

- (void)getObjectsWithClass:(Class)objectClass withURL:(NSString*)url absolute:(BOOL)absolute withParams:(NSArray*)params notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
    ASIHTTPRequest* req = [self getRequestForObjectsWithURL:url absolute:absolute withUrlParams:params withAuth:auth];
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
    [self postNewObject:[obj class] withRequest:req notifyTarget:target byCalling:selector withUserData:userData returnNewObject:returnNew withAuthForGET:getAuth];
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


- (void)getURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
    NSURL* u = [self urlWithURL:url absolute:absolute addTrailingSlash:YES params:nil];
    if (!u)
    {
        return;
    }
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:target                         forKey:@"target"];
    [userInfo setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [userInfo setValue:@"GET_URL"                     forKey:@"method"];
    [userInfo setValue:userData                       forKey:@"userData"];
    
    ASIHTTPRequest* req = [[ASIHTTPRequest alloc] initWithURL:u];
    req.delegate = self;
    req.userInfo = userInfo;
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    [req startAsynchronous];
}

- (ASIFormDataRequest*)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
    NSURL* u = [self urlWithURL:url absolute:absolute addTrailingSlash:YES params:nil];
    NSLog(@"post data url '%@'", u.absoluteString);
    if (!u)
    {
        NSLog(@"post data: invalid url");
        return;
    }
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:target forKey:@"target"];
    [userInfo setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [userInfo setValue:@"POST_DATA" forKey:@"method"];
    [userInfo setValue:userData forKey:@"userData"];
    
    ASIFormDataRequest* req = [[ASIFormDataRequest alloc] initWithURL:u];
    [req addData:data forKey:key];
    req.userInfo = userInfo;
    req.delegate = self;
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    [req startAsynchronous];
    
    return req;
}


- (ASIFormDataRequest*)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth withProgress:(id)progressDelegate
{
    NSURL* u = [self urlWithURL:url absolute:absolute addTrailingSlash:YES params:nil];
    NSLog(@"post data url '%@'", u.absoluteString);
    if (!u)
    {
        NSLog(@"post data: invalid url");
        return;
    }
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:target forKey:@"target"];
    [userInfo setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [userInfo setValue:@"POST_DATA" forKey:@"method"];
    [userInfo setValue:userData forKey:@"userData"];
    
    
    ASIFormDataRequest* req = [[ASIFormDataRequest alloc] initWithURL:u];
    [req addData:data forKey:key];
    req.userInfo = userInfo;
    req.delegate = self;
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    [req setUploadProgressDelegate:progressDelegate];
    [req startAsynchronous];
    
    return req;
}

- (ASIFormDataRequest*)postData:(NSData*)data withKey:(NSString*)key toURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth withProgress:(id)progressDelegate withAdditionalJsonData:(NSString*)jsonData
{
    NSURL* u = [self urlWithURL:url absolute:absolute addTrailingSlash:YES params:nil];
    NSLog(@"post data url '%@'", u.absoluteString);
    if (!u)
    {
        NSLog(@"post data: invalid url");
        return;
    }
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:target forKey:@"target"];
    [userInfo setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [userInfo setValue:@"POST_DATA" forKey:@"method"];
    [userInfo setValue:userData forKey:@"userData"];
    
    
    ASIFormDataRequest* req = [[ASIFormDataRequest alloc] initWithURL:u];
    [req addData:data forKey:key];
    [req addPostValue:jsonData forKey:@"data"];
    req.userInfo = userInfo;
    req.delegate = self;
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    [req setUploadProgressDelegate:progressDelegate];
    [req startAsynchronous]; 
    
    return req;
}



- (void)postToURL:(NSString*)url absolute:(BOOL)absolute notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth
{
    [self postNewObject:nil withURL:url absolute:absolute notifyTarget:target byCalling:selector withUserData:userData withAuth:auth returnNewObject:NO withAuthForGET:nil];
}

- (void)postToURL:(NSString*)url absolute:(BOOL)absolute withStringData:(NSString*)stringData objectClass:(Class)objectClass notifyTarget:(id)target byCalling:(SEL)selector withUserData:(NSDictionary*)userData withAuth:(Auth*)auth  returnNewObject:(BOOL)returnNew withAuthForGET:(Auth*)getAuth
{
    ASIHTTPRequest* req = [self postRequestForURL:url absolute:absolute withStringData:stringData withAuth:auth];
    [self postNewObject:objectClass withRequest:req notifyTarget:target byCalling:selector withUserData:userData returnNewObject:returnNew withAuthForGET:getAuth];
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
    Class objectClass            = [userinfo valueForKey:@"objectClass"];
    BOOL returnNewObject = [[userinfo valueForKey:@"returnNewObject"] boolValue];
    Auth* authForGET = [userinfo valueForKey:@"authForGET"];
    NSDictionary* userData = [userinfo valueForKey:@"userData"];
    
    NSString* response = request.responseString;
    
    NSString* location = [request.responseHeaders valueForKey:@"Location"];
    if (returnNewObject)
    {
        [self getObjectWithClass:objectClass withURL:location absolute:YES notifyTarget:target byCalling:selector withUserData:userData withAuth:authForGET];
    }
    else
    {
        NSString* res = (location != nil) ? location : response;
        [self notifytarget:target byCalling:selector withUserData:userData withObject:res andSuccess:succeeded];
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
    NSDictionary* userData = [userinfo valueForKey:@"userData"];
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:userData forKey:@"userData"];
    [data setObject:[NSNumber numberWithBool:succeeded] forKey:@"succeeded"];
    if (!succeeded)
        [data setObject:[NSString stringWithString:@"SongUpload_failedUploading"] forKey:@"detailedInfo"];
    
    NSString* response = request.responseString;
    
    NSError* error = nil;
    if (!succeeded)
    {
        NSString* domain = response;
        if (!domain)
            domain = @"no response";
        error = [NSError errorWithDomain:domain code:request.responseStatusCode userInfo:nil];
        [data setValue:error forKey:@"error"];
    }
    
    [self callAction:selector onTarget:target withObject:response withObject:data];
}


- (void)handleGetURLResponse:(ASIHTTPRequest*)request success:(BOOL)succeeded
{
    NSDictionary* userinfo = request.userInfo;
    id target         = [userinfo valueForKey:@"target"];
    SEL selector      = NSSelectorFromString([userinfo valueForKey:@"selector"]);
    NSDictionary* userData = [userinfo valueForKey:@"userData"];
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:userData forKey:@"userData"];
    
    NSString* response = request.responseString;
    NSError* error = nil;
    if (!succeeded)
    {
        error = [NSError errorWithDomain:response code:request.responseStatusCode userInfo:nil];
        [data setValue:error forKey:@"error"];
    }
    
    [self callAction:selector onTarget:target withObject:response withObject:data];
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
    else if ([method isEqualToString:@"GET_URL"])
    {
        [self handleGetURLResponse:request success:succeeded];
    }
    else if ([method isEqualToString:@"POST_DATA"])
    {
        [self handlePostDataResponse:request success:succeeded];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
  NSLog(@"request (%p) FINISHED", request);
  BOOL success = YES;
  if (request.responseStatusCode / 100 == 4 || request.responseStatusCode / 100 == 5)
    success = NO;
  
  [self handleResponse:request success:success];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
  NSLog(@"request.url = %@  request.response.statusCode = %d", request.url.absoluteString, request.responseStatusCode);
  NSLog(@"request (%p) FAILED", request);
    [self handleResponse:request success:NO];
}

//- (void)requestStarted:(ASIHTTPRequest *)request
//{
//  NSLog(@"request (%p) STARTED", request);
//}
//
//- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
//{
//  NSLog(@"request (%p) RECIEVED response headers", request);
//}
//
//- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
//{
//  [request redirectToURL:newURL];
//  NSLog(@"request (%p) will REDIRECT to url '%@'", request, newURL.absoluteString);
//}
//
//- (void)requestRedirected:(ASIHTTPRequest *)request
//{
//  NSLog(@"request (%p) REDIRECTED", request);
//}
//
//- (void)authenticationNeededForRequest:(ASIHTTPRequest *)request
//{
//  NSLog(@"request (%p) AUTHENTICATION needed", request);
//}
//
//- (void)proxyAuthenticationNeededForRequest:(ASIHTTPRequest *)request
//{
//  NSLog(@"request (%p) PROXY AUTHENTICATION needed", request);
//}

@end




@implementation Communicator (Communicator_internal)

- (NSURL*)URLWithURL:(NSURL*)url andParams:(NSArray*)params
{
    if (!params || [params count] == 0)
        return url;
    
    NSString* urlStr = [url absoluteString];
    
    bool firstParam = false;
    NSRange range = [urlStr rangeOfString:@"?"];
    if (NSEqualRanges(range, NSMakeRange(NSNotFound, 0)))
    {
        // '?' has not been found
        // there is no param yet
        firstParam = true;
    }
    
    if (firstParam && ![urlStr hasSuffix:@"/"])
        urlStr = [urlStr stringByAppendingString:@"/"];
    
    for (NSString* p in params)
    {
        if (firstParam)
        {
            urlStr = [urlStr stringByAppendingString:@"?"];
            firstParam = false;
        }
        else
        {
            urlStr = [urlStr stringByAppendingString:@"&"];
        }
        urlStr = [urlStr stringByAppendingString:[p stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    NSURL* new = [NSURL URLWithString:urlStr];
    return new;
}

- (void)addUrlParams:(NSArray*)params toRequest:(ASIHTTPRequest*)request
{
    NSURL* url = [self URLWithURL:request.url andParams:params];
    request.url = url;
}

- (void)applyAuth:(Auth*)auth toRequest:(ASIHTTPRequest*)request
{
    if (!auth)
        return;
    
    if ([auth isKindOfClass:[AuthPassword class]])
    {
        // USERNAME / PASSWORD
        AuthPassword* a = (AuthPassword*)auth;
        request.username = a.username;
        request.password = a.password;
    }
    else if ([auth isKindOfClass:[AuthApiKey class]])
    {
        // USERNAME / API KEY
        AuthApiKey* a = (AuthApiKey*)auth;
        NSArray* params = a.urlParams;
        [self addUrlParams:params toRequest:request];
    }
    else if ([auth isKindOfClass:[AuthSocial class]])
    {
        //SOCIAL (facebook, twitter)
        AuthSocial* a = (AuthSocial*)auth;
        NSArray* params = a.urlParams;
        [self addUrlParams:params toRequest:request];
    }
}


- (void)fillRequest:(ASIHTTPRequest*)request
{
    // the https certificate seems to be ok but keep next line commented...
    //    request.validatesSecureCertificate = FALSE;
    
    if (self.appCookie)
    {
        [request.requestCookies addObject:self.appCookie];
    }
    // TODO: get locale of device in order to send appropriated headers
    [request addRequestHeader:@"Accept-Language" value:@"fr,fr-fr;q=0.8,en-us;q=0.5,en;q=0.3"];
}

- (ASIHTTPRequest*)getRequestForObjectsWithURL:(NSString*)path absolute:(BOOL)isAbsolute withUrlParams:(NSArray*)params withAuth:(Auth*)auth
{  
    NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:params];
    
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
    req.requestMethod = @"GET";
    [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    return req;
}

- (ASIHTTPRequest*)getRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth
{
    NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:nil];
    
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
    req.requestMethod = @"GET";
    [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    return req;
}


- (ASIHTTPRequest*)postRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth
{
    NSString* jsonDesc = nil;
    if (obj)
        jsonDesc = [obj JSONRepresentation];
    
    ASIHTTPRequest* req = [self postRequestForURL:path absolute:isAbsolute withStringData:jsonDesc withAuth:auth];
    return req;
}


- (ASIHTTPRequest*)putRequestForObject:(Model*)obj withURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth
{
    if (!obj)
        return nil;
    
    NSString* jsonDesc = [obj JSONRepresentation];
    if (!jsonDesc)
        return nil;
    
    ASIHTTPRequest* req = [self putRequestForURL:path absolute:isAbsolute withStringData:jsonDesc withAuth:auth];
    return req;
}

- (ASIHTTPRequest*)deleteRequestForObjectWithURL:(NSString*)path absolute:(BOOL)isAbsolute withAuth:(Auth*)auth
{
    NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:nil];
    
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
    req.requestMethod = @"DELETE";
    [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
    [req addRequestHeader:@"Content-Type" value:@"application/json"];
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    return req;
}



- (ASIHTTPRequest*)postRequestForURL:(NSString*)path absolute:(BOOL)isAbsolute withStringData:(NSString*)stringData withAuth:(Auth*)auth
{
    NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:nil];
    
    NSLog(@"post url %@", url.absoluteString);
    
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
    req.requestMethod = @"POST";
    [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
    [req addRequestHeader:@"Content-Type" value:@"application/json"];
    
    if (stringData)
    {
        [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    return req;
}

- (ASIHTTPRequest*)putRequestForURL:(NSString*)path absolute:(BOOL)isAbsolute withStringData:(NSString*)stringData withAuth:(Auth*)auth
{
    NSURL* url = [self urlWithURL:path absolute:isAbsolute addTrailingSlash:YES params:nil];
    
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
    req.requestMethod = @"PUT";
    [req.requestHeaders setValue:@"application/json" forKey:@"Accept"];
    [req addRequestHeader:@"Content-Type" value:@"application/json"];
    
    if (stringData)
        [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self applyAuth:auth toRequest:req];
    [self fillRequest:req];
    return req;
}

//////////////////////////////









- (ASIHTTPRequest*)getRequestForObjectsWithClass:(Class)objectClass withAuth:(Auth*)auth
{
    //  NSString* path = [Model uriForObjectClass:objectClass];
    //  if (!path)
    //    return nil;
    //  
    //  NSURL* url = [NSURL URLWithString:_baseURL];
    //  url = [url URLByAppendingPathComponent:path];
    //  
    //  ASIHTTPRequest* req = [self getRequestForObjectsWithURL:[url absoluteString] absolute:YES withUrlParams:nil withAuth:auth];  
    //  return req;
    ASIHTTPRequest* req = [self getRequestForObjectsWithClass:objectClass withUrlParams:nil withAuth:auth];
    return req;
}

- (ASIHTTPRequest*)getRequestForObjectsWithClass:(Class)objectClass withUrlParams:(NSArray*)urlParams withAuth:(Auth*)auth
{
    NSString* path = [Model uriForObjectClass:objectClass];
    if (!path)
        return nil;
    
    NSURL* url = [NSURL URLWithString:_baseURL];
    url = [url URLByAppendingPathComponent:path];
    
    ASIHTTPRequest* req = [self getRequestForObjectsWithURL:[url absoluteString] absolute:YES withUrlParams:urlParams withAuth:auth];  
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