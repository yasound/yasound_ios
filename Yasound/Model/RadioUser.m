//
//  RadioUser.m
//  Yasound
//
//  Created by matthieu campion on 1/9/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RadioUser.h"

@implementation RadioUser

@synthesize radio;
@synthesize user;
@synthesize mood;
@synthesize favorite;
@synthesize connected;
@synthesize radio_selected;

- (UserMood)userMood
{
    if ([self.mood isEqualToString:@"L"])
        return eMoodLike;
    if ([self.mood isEqualToString:@"N"])
        return eMoodNeutral;
    else if ([self.mood isEqualToString:@"D"])
        return eMoodDislike;
    
    return eMoodInvalid;
}

- (void)setUserMood:(UserMood)m
{
    switch (m) 
    {
        case eMoodLike:
            self.mood = @"L";
            break;
            
        case eMoodNeutral:
            self.mood = @"N";
            break;
            
        case eMoodDislike:
            self.mood = @"D";
            break;
            
        case eMoodInvalid:
        default:
            break;
    }
}

@end
