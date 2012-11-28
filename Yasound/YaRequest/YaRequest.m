//
//  YaRequest.m
//  Yasound
//
//  Created by mat on 26/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YaRequest.h"
#import "ASIFormDataRequest.h"

#define APP_KEY_COOKIE_NAME @"app_key"
#define APP_KEY_IPHONE @"yasound_iphone_app"

@implementation YaRequest

static NSMutableDictionary* sRequests = nil;
static NSString* sBaseURL = nil;

+ (void)globalInit
{
    [ASIHTTPRequest setDefaultTimeOutSeconds:60];
}

+ (void)setBaseURL:(NSString*)url
{
    sBaseURL = url;
}

+ (NSString*)baseURL
{
    return sBaseURL;
}

+ (void)addRequest:(YaRequest*)req forKey:(NSString*)key
{
    if (sRequests == nil)
        sRequests = [[NSMutableDictionary alloc] init];
    
    NSMutableArray* reqs = [sRequests valueForKey:key];
    if (reqs == nil)
        reqs = [[NSMutableArray alloc] init];
    [reqs addObject:req];
    [sRequests setValue:reqs forKey:key];
}

+ (void)removeRequest:(YaRequest*)req forKey:(NSString*)key
{
    if (sRequests == nil)
        return;
    
    NSMutableArray* reqs = [sRequests valueForKey:key];
    if (reqs == nil)
        return;
    [reqs removeObject:req];
    [sRequests setValue:reqs forKey:key];
}

+ (void)cancelWithKey:(NSString*)key
{
    if (sRequests == nil)
        return;
    
    NSMutableArray* reqs = [sRequests valueForKey:key];
    if (reqs == nil)
        return;
    for (YaRequest* req in reqs)
    {
        [req cancelInternal];
    }
    [sRequests removeObjectForKey:key];
}

- (NSURL*)URLWithURL:(NSURL*)url andParams:(NSDictionary*)params
{
    if (!params || [params count] == 0)
        return url;
    
    NSString* urlStr = [url absoluteString];
    urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
    
    for (NSString* key in params)
    {
        NSString* value = [params valueForKey:key];
        if ([value isKindOfClass:[NSString class]] == NO)
            continue;
        
        if (firstParam)
        {
            urlStr = [urlStr stringByAppendingString:@"?"];
            firstParam = false;
        }
        else
        {
            urlStr = [urlStr stringByAppendingString:@"&"];
        }
        NSString* str = [NSString stringWithFormat:@"%@=%@", key, value];
        urlStr = [urlStr stringByAppendingString:str];
    }
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* new = [NSURL URLWithString:urlStr];
    return new;
}

- (void)addUrlParams:(NSDictionary*)params
{
    NSURL* url = [self URLWithURL:_request.url andParams:params];
    _request.url = url;
}

-(NSURL*)urlWithURL:(NSString*)path absolute:(BOOL)absolute addTrailingSlash:(BOOL)slash params:(NSDictionary*)params
{
    if (!path || ![path isKindOfClass:[NSString class]])
        return nil;
    
    NSRange range = [path rangeOfString:@"?"];
    BOOL containParams = !NSEqualRanges(range, NSMakeRange(NSNotFound, 0));
    if (!containParams && slash && ![path hasSuffix:@"/"])
        path = [path stringByAppendingString:@"/"];
    
    NSURL* url;
    if (absolute)
        url = [NSURL URLWithString:path];
    else
    {
        url = [NSURL URLWithString:sBaseURL];
        if ([path hasPrefix:@"/"] && path.length > 1)
            path = [path substringFromIndex:1];
        url = [url URLByAppendingPathComponent:path];
    }
    
    url = [self URLWithURL:url andParams:params];
    return url;
}

- (void)applyAuth:(Auth*)auth
{
    if (!auth | !_request)
        return;
    
    if ([auth isKindOfClass:[AuthPassword class]])
    {
        // USERNAME / PASSWORD
        AuthPassword* a = (AuthPassword*)auth;
        _request.username = a.username;
        _request.password = a.password;
        [_request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    }
    else if ([auth isKindOfClass:[AuthApiKey class]])
    {
        // USERNAME / API KEY
        AuthApiKey* a = (AuthApiKey*)auth;
        NSDictionary* params = a.urlParamsDict;
        [self addUrlParams:params];
    }
    else if ([auth isKindOfClass:[AuthSocial class]])
    {
        //SOCIAL (facebook, twitter)
        AuthSocial* a = (AuthSocial*)auth;
        NSDictionary* params = a.urlParamsDict;
        [self addUrlParams:params];
    }
}



+ (YaRequest*)requestWithConfig:(YaRequestConfig*)config
{
    return [[[YaRequest alloc] initWithConfig:config] autorelease];
}

- (id)initWithConfig:(YaRequestConfig*)config
{
    self = [super init];
    if (self)
    {
        _config = config;
        if (_config)
            [_config retain];
        _request = nil;
    }
    return self;
}

- (void)dealloc
{
    if (_config)
        [_config release];
    [super dealloc];
}

- (BOOL)start:(YaRequestCompletionBlock)completionBlock progressBlock:(YaRequestProgressBlock) progressBlock
{
    if (_config == nil || [_config isValid] == NO)
        return NO;
    
    // app id and version
    NSString* appId         = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appVersion    = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSDictionary* appParams = [NSDictionary dictionaryWithObjectsAndKeys:appId, @"app_id", appVersion, @"app_version", nil];
    
    NSURL* url = [self urlWithURL:_config.url absolute:_config.urlIsAbsolute addTrailingSlash:YES params:appParams];
    
    // create internal request object
    BOOL isFormDataRequest = [_config.method isEqualToString:@"POST"] && _config.params != nil;
    if (isFormDataRequest == NO)
    {
        _request = [ASIHTTPRequest requestWithURL:url];
        // add params in URL
        [self addUrlParams:_config.params];
    }
    else
    {
        ASIFormDataRequest* formDataRequest = [ASIFormDataRequest requestWithURL:url];
        // add params in form
        for (NSString* key in _config.params)
        {
            id value = [_config.params valueForKey:key];
            [formDataRequest addPostValue:value forKey:key];
        }
        _request = formDataRequest;
    }
    
    // payload
    if (_config.payload)
        [_request appendPostData:_config.payload];
    
    // authentication
    [self applyAuth:_config.auth];
    
    // method
    _request.requestMethod = _config.method;
    
    // json
    [_request addRequestHeader:@"Accept" value:@"application/json"];
    [_request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    // language
    // TODO: get locale of device in order to send appropriated headers
    [_request addRequestHeader:@"Accept-Language" value:NSLocalizedString(@"ACCEPT_LANGUAGE", @"")];
    
    // cookie
    NSDictionary* properties = [[[NSMutableDictionary alloc] init] autorelease];
    [properties setValue:APP_KEY_IPHONE forKey:NSHTTPCookieValue];
    [properties setValue:APP_KEY_COOKIE_NAME forKey:NSHTTPCookieName];
    [properties setValue:@"yasound.com" forKey:NSHTTPCookieDomain];
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    [properties setValue:@"/yasound/app_auth" forKey:NSHTTPCookiePath];
    NSHTTPCookie* cookie = [NSHTTPCookie cookieWithProperties:properties];
    [_request.requestCookies addObject:cookie];
    
    // progress
    if (progressBlock != nil)
        [_request setBytesSentBlock:progressBlock];
    
    // completion
    [_request setCompletionBlock:^{
        if (completionBlock)
        {
            int status = _request.responseStatusCode;
            NSString* response = _request.responseString;
            completionBlock(status, response, nil);
        }
        [YaRequest removeRequest:self forKey:_config.groupKey];
    }];
    
    [_request setFailedBlock:^{
        if (completionBlock)
            completionBlock(0, nil, _request.error);
        [YaRequest removeRequest:self forKey:_config.groupKey];
    }];
    
    // store the request in order to be able to cancel a group of requests
    if (_config.groupKey)
        [YaRequest addRequest:self forKey:_config.groupKey];
    
    [_request startAsynchronous];
    return YES;

}

- (BOOL)start:(YaRequestCompletionBlock)completionBlock
{
    return [self start:completionBlock progressBlock:nil];
}

- (void)cancelInternal
{
    if (!_request)
        return;
    
    [_request cancel];
}

- (void)cancel
{
    [self cancelInternal];
    if (_config.groupKey)
    {
        [YaRequest removeRequest:self forKey:_config.groupKey];
    }
}

@end
