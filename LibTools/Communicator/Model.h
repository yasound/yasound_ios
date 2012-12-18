//
//  Model.h
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject
{
  NSNumber* _id;
  
}

@property (assign) NSNumber* id;

+ (NSString*)apiURI;
+ (NSString*)uriForObject:(Model*)obj;
+ (NSString*)uriForObjectClass:(Class)objectClass;
+ (NSString*)uriForObjectClass:(Class)objectClass andID:(NSNumber*)objID;

+ (NSMutableDictionary*)resourceNames;

- (BOOL)isEqual:(Model*)object;

@end
