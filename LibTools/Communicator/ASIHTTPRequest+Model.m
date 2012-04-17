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
    Container* container = [[Container alloc] initWithObjectClass:ModelClass];
    [container loadPropertiesFromJsonString:respString];
    return container;
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
