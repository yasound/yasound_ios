//
//  User.h
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

typedef enum  
{
    eMoodLike = 0,
    eMoodNeutral = 1,
    eMoodDislike = 2,
    eMoodInvalid = 3,
} UserMood;

@interface User : Model

@property (retain, nonatomic) NSString* username;
@property (retain, nonatomic) NSString* password;
@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* api_key;
@property (retain, nonatomic) NSString* email;
@property (retain, nonatomic) NSString* picture;

- (NSString*)toString;
@end
