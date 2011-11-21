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

@end


@interface Container : NSObject

@property (readonly) Class objectClass;
@property (retain) Meta* meta;
@property (retain) NSArray* objects;

- (id)initWithObjectClass:(Class)objClass;
@end
