//
//  SongUser.m
//  Yasound
//
//  Created by matthieu campion on 1/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "SongUser.h"

@implementation SongUser

@synthesize song;
@synthesize user;
@synthesize mood;

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
