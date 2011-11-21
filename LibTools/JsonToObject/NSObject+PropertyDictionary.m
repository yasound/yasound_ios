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
    }
    else
    {
      // custom object
      NSDictionary* dictVal = [dict valueForKey:propName];
      val = [[c alloc] init];
      [val loadPropertiesFromDictionary:dictVal];
    }
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

