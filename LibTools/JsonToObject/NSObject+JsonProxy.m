//
//  NSObject+JsonProxy.m
//  MappingTest
//
//  Created by matthieu campion on 11/16/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "SBJsonStreamWriter.h"
#import <objc/runtime.h>

@implementation NSDate (SBProxyForJson)

- (id)proxyForJson
{
  NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
  NSString* s = [dateFormat stringFromDate:self];
  [dateFormat release];
  return s;
}

@end

@implementation NSObject (SBProxyForJson)

- (id)proxyForJson
{
  NSMutableDictionary* res = [[NSMutableDictionary alloc] init];
  
  unsigned int outCount = 0;
  objc_property_t *properties = class_copyPropertyList([self class], &outCount);
  for (int i = 0; i < outCount; i++) 
  {
    objc_property_t prop = properties[i];
    
    const char* n = property_getName(prop);
    NSString* propName = [NSString stringWithCString:n encoding:NSUTF8StringEncoding];
    id val = [self valueForKey:propName];
    
    [res setValue:val forKey:propName];
  }
  free(properties);
  
  return res;
}

@end
