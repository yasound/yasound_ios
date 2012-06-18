//
//  UserSettings.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 06/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//


#import "UserSettings.h"

@implementation UserSettings

static UserSettings* _main;

+ (UserSettings*)main
{
    if (_main)
    {
        _main = [[UserSettings alloc] init];
    }
    
    return _main;
}



@end
