//
//  Container.m
//  testCommunication
//
//  Created by matthieu campion on 11/21/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import "Container.h"
#import "NSObject+PropertyDictionary.h"

@implementation Meta

@synthesize total_count;
@synthesize previous;
@synthesize next;
@synthesize limit;
@synthesize offset;

- (NSString*)toString
{
  NSString* desc = [NSString stringWithFormat:@"total_count: '%@', previous: '%@', next: '%@', limit: '%@', offset: '%@'", self.total_count, self.previous, self.next, self.limit, self.offset];
  return desc;
}

@end

@implementation Container

@synthesize objectClass;
@synthesize meta;
@synthesize objects;


- (id)initWithObjectClass:(Class)objClass
{
  self = [super init];
  if (self)
  {
    objectClass = objClass;
  }
  return self;
}

- (void)loadPropertiesFromDictionary:(NSDictionary*)dict
{
  NSDictionary* metaDict = [dict valueForKey:@"meta"];
  NSArray* objectsArray = [dict valueForKey:@"objects"];
  if (!metaDict || !objectsArray)
    return;
  
  meta = [[Meta alloc] init];
  [meta loadPropertiesFromDictionary:metaDict];
  
  NSMutableArray* temp = [[NSMutableArray alloc] init];
  for (NSDictionary* objDict in objectsArray)
  {
    id obj = [[objectClass alloc] init];
    [obj loadPropertiesFromDictionary:objDict];
    [temp addObject:obj];
  }
  
  objects = temp;
}

@end
