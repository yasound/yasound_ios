//
//  NSString+JsonLoading.m
//  Yasound
//
//  Created by mat on 26/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NSString+JsonLoading.h"
#import "NSObject+PropertyDictionary.h"
#import "NSObject+SBJSON.h"

@implementation NSString (JsonLoading)

- (NSDictionary*)jsonToDictionary
{
    NSDictionary* dict = [self JSONValue];
    return dict;
}

- (NSArray*)jsonToArray
{
    NSArray* array = [self JSONValue];
    return array;
}

- (Model*)jsonToModel:(Class)ModelClass
{
    Model* obj = [[ModelClass alloc] init];
    [obj loadPropertiesFromJsonString:self];
    return obj;
}

- (Container*)jsonToContainer:(Class)ModelClass
{
    Container* container = [[Container alloc] initWithObjectClass:ModelClass];
    [container loadPropertiesFromJsonString:self];
    return container;
}


@end
