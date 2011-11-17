//
//  Post.h
//  MappingTest
//
//  Created by matthieu campion on 11/16/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Post : NSObject

@property (retain) NSString* title;
@property (retain) NSString* text;
@property (assign) NSNumber*  note;
@property (retain) User*  author;

@end
