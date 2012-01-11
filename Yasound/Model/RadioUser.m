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
    UserMood m = stringToUsermood(self.mood);
    return m;
}

- (void)setUserMood:(UserMood)m
{
    NSString* s = usermoodToString(m);
    self.mood = s;
}

@end
