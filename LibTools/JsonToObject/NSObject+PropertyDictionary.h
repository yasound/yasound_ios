//
//  NSObject+PropertyDictionary.h
//  MappingTest
//
//  Created by matthieu campion on 11/16/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSObject_PropertyDictionaryLoad)

- (void)loadPropertiesFromJsonString:(NSString*)json;
- (void)loadPropertiesFromDictionary:(NSDictionary*)dict;

@end
