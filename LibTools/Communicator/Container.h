//
//  Container.h
//  testCommunication
//
//  Created by matthieu campion on 11/21/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Meta : NSObject 

@property (assign) NSNumber* total_count;
@property (retain, nonatomic) NSString* previous;
@property (retain, nonatomic) NSString* next;
@property (retain, nonatomic) NSNumber* limit;
@property (retain, nonatomic) NSNumber* offset;

- (NSString*)toString;

@end


@interface Container : NSObject

@property (readonly) Class objectClass;
@property (retain) Meta* meta;
@property (retain) NSArray* objects;

- (id)initWithObjectClass:(Class)objClass;
@end
