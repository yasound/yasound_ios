//
//  Model.m
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "Model.h"
#import <objc/runtime.h>
#import "WallEvent.h"
#import "Radio.h"

@implementation Model

@synthesize id = _id;


+ (NSString*)apiURI
{
  return @"api/v1";
}

NSMutableDictionary* _resourceNames = nil;

+ (NSMutableDictionary*)resourceNames
{
  if (_resourceNames == nil)
    _resourceNames = [[NSMutableDictionary alloc] init];
  
  return _resourceNames;
}


+ (NSString*)uriForObjectClass:(Class)objectClass
{
  NSString* resourceName = [_resourceNames objectForKey:objectClass];
  if (!resourceName)
    return nil;
  
  NSString* uri = [self apiURI];
  uri = [uri stringByAppendingPathComponent:resourceName];
  return uri;
}

+ (NSString*)uriForObjectClass:(Class)objectClass andID:(NSNumber*)objID
{
  NSString* base = [self uriForObjectClass:objectClass];
  if (!objID || !base)
    return nil;
  
  NSString* uri = [base stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", objID]];
  uri = [uri stringByAppendingString:@"/"];
  return uri;
}

+ (NSString*)uriForObject:(Model*)obj
{
  if (!obj)
    return nil;
  NSString* uri = [self uriForObjectClass:[obj class] andID:obj.id];
  return uri;
}



- (id)init
{
  self = [super init];
  if (self)
  {
    _id = [NSNumber numberWithInt:0];
  }
  return self;
}

@end


@implementation Model (SBProxyForJson)

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
    
    if ([val isKindOfClass:[Model class]])
    {
      Model* obj = (Model*)val;
      NSString* valURI = @"/";
      valURI = [valURI stringByAppendingString:[Model uriForObject:obj]];
      [res setValue:valURI forKey:propName];
    }
    else
    {
      [res setValue:val forKey:propName];
    }

  }
  free(properties);
  
  return res;
}

@end
