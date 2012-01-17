//
//  User.h
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

@class Radio;

typedef enum  
{
    eMoodLike = 0,
    eMoodNeutral = 1,
    eMoodDislike = 2,
    eMoodInvalid = 3,
} UserMood;

NSString* usermoodToString(UserMood mood);
UserMood stringToUsermood(NSString* str);

@interface User : Model

@property (retain, nonatomic) NSString* username;
@property (retain, nonatomic) NSString* password;
@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* api_key;
@property (retain, nonatomic) NSString* email;
@property (retain, nonatomic) NSString* picture;
@property (retain, nonatomic) Radio* current_radio;
@property (retain, nonatomic) Radio* own_radio;

- (NSString*)toString;
@end
