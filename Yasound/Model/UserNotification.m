//
//  UserNotification.m
//  Yasound
//
//  Created by matthieu campion on 5/16/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "UserNotification.h"

@implementation UserNotification

@synthesize _id;
@synthesize text;
@synthesize type;
@synthesize date;
@synthesize dest_user_id;
@synthesize from_user_id;
@synthesize from_user_name;
@synthesize from_radio_id;
@synthesize from_radio_name;
@synthesize read;
@synthesize params;

- (BOOL)isReadBool
{
    return [self.read boolValue];
}

- (void)setReadBool:(BOOL)r
{
    self.read = [NSNumber numberWithBool:r];
}

@end
