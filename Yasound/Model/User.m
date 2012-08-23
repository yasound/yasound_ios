//
//  User.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "User.h"
#import "Radio.h"

@implementation User

@synthesize username;
@synthesize password;
@synthesize name;
@synthesize api_key;
@synthesize email;
@synthesize picture;
@synthesize current_radio;
@synthesize own_radio;

@synthesize facebook_username;
@synthesize facebook_uid;
@synthesize facebook_token;
@synthesize facebook_expiration_date;
@synthesize facebook_email;

@synthesize twitter_username;
@synthesize twitter_uid;
@synthesize twitter_token;
@synthesize twitter_token_secret;
@synthesize twitter_email;

@synthesize yasound_email;

@synthesize gender;
@synthesize age;
@synthesize birthday;
@synthesize city;
@synthesize bio_text;
@synthesize url;

@synthesize permissions;


- (NSString*)toString
{
  NSString* desc = [NSString stringWithFormat:@"id: '%@' username: '%@', name: '%@'", self.id, self.username, self.name];
  return desc;
}


- (NSString*)formatedProfil
{
    NSString* profil = [NSString stringWithString:@""];
    NSString* age = nil;
    if (self.age != nil)
    {
        age = NSLocalizedString(@"Profil.age", nil);
        age = [NSString stringWithFormat:age, [self.age integerValue]];
    }
    
    NSString* sexe = nil;
    if (self.gender.length > 0)
        sexe = NSLocalizedString(self.gender, nil);
    NSString* city = nil;
    if (self.city.length > 0)
        city = self.city;
    
    profil = [NSString string];
    if (age != nil)
        profil = [profil stringByAppendingString:age];
    
    if ((sexe != nil) && (profil != nil))
        profil = [profil stringByAppendingString:@", "];
    
    if (sexe != nil)
        profil = [profil stringByAppendingString:sexe];
    
    if ((city != nil) && (profil != nil))
        profil = [profil stringByAppendingString:@", "];
    
    if (city != nil)
        profil = [profil stringByAppendingString:city];

    return profil;
}


- (BOOL)permission:(NSString*)permId
{
    //DLog(@"permission :%@", self.permissions);
    
    if ((self.permissions == nil) || (self.permissions.count == 0))
    {
        DLog(@"error : no permissions!");
        return NO;
    }
    
    NSNumber* nb = [self.permissions objectForKey:permId];
    if (nb == nil)
    {
        DLog(@"User::permission could not find any permission '%@'", permId);
        return NO;
    }
    
    return [nb boolValue];
}



@end



NSString* usermoodToString(UserMood mood)
{
    switch (mood)
    {
        case eMoodLike:
            return @"L";
            
        case eMoodNeutral:
            return @"N";
            
        case eMoodDislike:
            return @"D";
            
        case eMoodInvalid:
        default:
            break;
    }
    
    return @"I";
}

UserMood stringToUsermood(NSString* str)
{
    if ([str isEqualToString:@"L"])
        return eMoodLike;
    if ([str isEqualToString:@"N"])
        return eMoodNeutral;
    else if ([str isEqualToString:@"D"])
        return eMoodDislike;
    
    return eMoodInvalid;
}





//- (void)loadPropertiesFromDictionary:(NSDictionary*)dict
//{
//    [super loadPropertiesFromDictionary:dict];
//    
//    // custom load for property 'time'
//    NSString* timeStr = [dict valueForKey:@"time"];
//    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
//    [timeFormat setDateFormat:@"HH:mm"];
//    NSDate* t = [timeFormat dateFromString:timeStr];
//    self.time = t;
//    NSLog(@"time: %@", self.time);
//}


