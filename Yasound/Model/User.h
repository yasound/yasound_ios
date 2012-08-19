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

@property (retain, nonatomic) NSString* gender;
@property (retain, nonatomic) NSNumber* age;
@property (retain, nonatomic) NSDate* birthday;
@property (retain, nonatomic) NSString* city;
@property (retain, nonatomic) NSString* bio_text;
@property (retain, nonatomic) NSString* url;
//String gender
//Integer age
//birthday
//bio_text 190 chars
//120 Message

//string : "M" ou "F"
//age : entier
//birthday : date
//city
//latitude
//longitude
//owner : bool
//is_friend : bool
//bio_text : text



@property (retain, nonatomic) NSString* facebook_username;
@property (retain, nonatomic) NSString* facebook_uid;
@property (retain, nonatomic) NSString* facebook_token;
@property (retain, nonatomic) NSString* facebook_expiration_date;
@property (retain, nonatomic) NSString* facebook_email;

@property (retain, nonatomic) NSString* twitter_username;
@property (retain, nonatomic) NSString* twitter_uid;
@property (retain, nonatomic) NSString* twitter_token;
@property (retain, nonatomic) NSString* twitter_token_secret;
@property (retain, nonatomic) NSString* twitter_email;

@property (retain, nonatomic) NSString* yasound_email;


- (NSString*)toString;

- (NSString*)formatedProfil;

@end
