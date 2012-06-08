//
//  ASIHTTPRequest+Model.m
//  Yasound
//
//  Created by matthieu campion on 4/17/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ASIHTTPRequest+Model.h"
#import "NSObject+PropertyDictionary.h"
#import "NSObject+SBJSON.h"
#import "RequestConfig.h"

@implementation ASIHTTPRequest (ASIHTTPRequest_YasoundModel)

- (NSDictionary*)responseDict
{
    NSString* respString = self.responseString;
    NSDictionary* dict = [respString JSONValue];
    return dict;
}

- (NSArray*)responseArray
{
    NSString* respString = self.responseString;
    NSArray* array = [respString JSONValue];
    return array;
}

- (Model*)responseObjectWithClass:(Class)ModelClass
{
    NSString* respString = self.responseString;
    Model* obj = [[ModelClass alloc] init];
    [obj loadPropertiesFromJsonString:respString];
    return obj;
}

- (Container*)responseObjectsWithClass:(Class)ModelClass
{
    NSString* respString = self.responseString;
    
    //LBDEBUG
    NSLog(@"%@", respString);
    NSLog(@"length %d", respString.length);
    
    Container* container = [[Container alloc] initWithObjectClass:ModelClass];
    [container loadPropertiesFromJsonString:respString];
    return container;
}

- (NSObject*)responseNSObjectWithClass:(Class)ModelClass
{
    NSString* respString = self.responseString;
    NSObject* obj = [[ModelClass alloc] init];
    [obj loadPropertiesFromJsonString:respString];
    return obj;
}

- (NSArray*)responseNSObjectsWithClass:(Class)ModelClass
{
    NSMutableArray* result = [NSMutableArray array];
    NSArray* raw = [self responseArray];
    for (NSDictionary* d in raw) 
    {
        NSObject* obj = [[ModelClass alloc] init];
        [obj loadPropertiesFromDictionary:d];
        [result addObject:obj];
    }
    return result;
}

- (id)userData
{
    if (!self.userInfo)
        return nil;
    if ([self.userInfo valueForKey:REQUEST_CONFIG_USER_INFO_KEY] == nil)
        return nil;
    if ([[self.userInfo valueForKey:REQUEST_CONFIG_USER_INFO_KEY] isKindOfClass:[RequestConfig class]] == NO)
        return nil;
    
    RequestConfig* conf = (RequestConfig*)[self.userInfo valueForKey:REQUEST_CONFIG_USER_INFO_KEY];
    return conf.userData;
}

@end
