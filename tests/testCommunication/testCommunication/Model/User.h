//
//  User.h
//  testCommunication
//
//  Created by matthieu campion on 11/17/11.
//  Copyright (c) 2011 MXP4. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface User : Model

@property (retain) NSString* first_name;
@property (retain) NSString* last_name;
@property (retain) NSString* username;

@end
