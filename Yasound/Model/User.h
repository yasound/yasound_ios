//
//  User.h
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

@interface User : Model

@property (retain, nonatomic) NSString* username;
@property (retain, nonatomic) NSString* first_name;
@property (retain, nonatomic) NSString* last_name;

- (NSString*)toString;
@end
