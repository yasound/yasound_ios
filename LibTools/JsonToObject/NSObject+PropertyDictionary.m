//
//  NSObject+PropertyDictionary.mm
//  MappingTest
//
//  Created by matthieu campion on 11/16/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "NSObject+PropertyDictionary.h"
#import <objc/runtime.h>
#import "NSObject+SBJson.h"

#define YASOUND_DATETIME_FORMATER @"yyyy-MM-dd'T'HH:mm:ssZZZZ"
#define YASOUND_DATE_FORMATER @"yyyy-MM-dd"


static const char *getPropertyType(objc_property_t property);
objc_property_t* getPropertyList(Class objectClass, unsigned int* outCount);



#pragma mark - NSObject (NSObject_PropertyDictionaryLoad)

@implementation NSObject (NSObject_PropertyDictionaryLoad)

- (void)loadPropertiesFromDictionary:(NSDictionary*)dict
{
  // enumerate all existing properties and try to find the according values in the dictionary
  unsigned int outCount = 0;
  objc_property_t *properties = getPropertyList([self class], &outCount);
  for (int i = 0; i < outCount; i++) 
  {
    objc_property_t prop = properties[i];
    
    const char* name = property_getName(prop);
    NSString* propName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];    
    
    const char* type = getPropertyType(prop);
    NSString* className = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
    Class c = NSClassFromString(className);
    
    BOOL isStandard = (c == [NSString class] || c == [NSNumber class] || c == [NSArray class] || c == [NSDictionary class]);
    id val = nil;
    if (isStandard)
    {
      // standard objects are immediate
      val = [dict valueForKey:propName];
        
        // fix weird bug: sometimes, number values are seen as strings
        if (c == [NSNumber class] && [val isKindOfClass:[NSString class]] && ![val isKindOfClass:[NSNull class]])
        {
            val = [[NSNumber alloc] initWithFloat:[val floatValue]];
        }
            
    }
    else if (c == [NSDate class])
    {
      NSString* str = [dict valueForKey:propName];
      
      if ([str isKindOfClass:[NSString class]])
      {
        str = [[str componentsSeparatedByString:@"."] objectAtIndex:0];
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:YASOUND_DATETIME_FORMATER];
        
        
        // 19 = length of 2012-04-19T15:46:24
        
        if ([str length] >= 19) 
        {
          NSTimeZone *serverTimeZone = [[NSTimeZone alloc] initWithName:@"Europe/Paris" data:nil];
          if ([serverTimeZone isDaylightSavingTime]) 
          {
            str = [NSString stringWithFormat:@"%@GMT+02:00", [str substringToIndex:19]];
          } 
          else 
          {
            str = [NSString stringWithFormat:@"%@GMT+01:00", [str substringToIndex:19]];
          }
          [serverTimeZone release];
        }
        
        val = [dateFormat dateFromString:str];
        [dateFormat release];
          
          if (!val) // try with pure date formatter (no time)
          {
              NSString* str = [dict valueForKey:propName];
              NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
              [dateFormat setDateFormat:YASOUND_DATE_FORMATER];
              val = [dateFormat dateFromString:str];
              [dateFormat release];
          }
      }
    }
    else
    {
      // custom object
      NSDictionary* dictVal = [dict valueForKey:propName];
        if (dictVal && [dictVal isKindOfClass:[NSDictionary class]])
        {
          val = [[c alloc] init];
          [val loadPropertiesFromDictionary:dictVal];
        }
    }
    if ([val isKindOfClass:[NSNull class]])
      val = nil;
    [self setValue:val forKey:propName]; 
  }
  free(properties);
}


- (void)loadPropertiesFromJsonString:(NSString*)json
{
  NSDictionary* jsonDict = [json JSONValue];
    
  [self loadPropertiesFromDictionary:jsonDict];
}

@end








static const char *getPropertyType(objc_property_t property) 
{
  const char *attributes = property_getAttributes(property);
  char buffer[1 + strlen(attributes)];
  strcpy(buffer, attributes);
  char *state = buffer, *attribute;
  while ((attribute = strsep(&state, ",")) != NULL) 
  {
    if (attribute[0] == 'T') 
    {
      return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
    }
  }
  return "@";
}


objc_property_t* getPropertyList(Class objectClass, unsigned int* outCount)
{  
  objc_property_t* props = class_copyPropertyList(objectClass, outCount);
  
  Class superClass = class_getSuperclass(objectClass);
  if (superClass && superClass != [NSObject class])
  {
    unsigned int c = 0;
    objc_property_t* superProps = getPropertyList(superClass, &c);
    
    unsigned int count = *outCount + c;
    objc_property_t* p = malloc(count * sizeof(objc_property_t));
    memcpy(p, props, *outCount * sizeof(objc_property_t));
    memcpy(p + *outCount, superProps, c * sizeof(objc_property_t));
    
    free(props);
    
    *outCount = count;
    props = p;
  }
  return props;
}

