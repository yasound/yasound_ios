//
//  Entry.h
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "model.h"

@interface Entry : Model

@property (retain) NSString*  title;
@property (retain) NSString*  slug;
@property (retain) NSString*  body;
@property (retain) User*      user;

@end
