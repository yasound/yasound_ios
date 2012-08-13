//
//  Show.m
//  Yasound
//
//  Created by mat on 09/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Show.h"



@implementation Show

@synthesize _id;
@synthesize name;
@synthesize days;
@synthesize time;
@synthesize random_play;
@synthesize enabled;

- (BOOL)isRandomBool
{
    return [self.random_play boolValue];
}

- (void)setRandomBool:(BOOL)random
{
    self.random_play = [NSNumber numberWithBool:random];
}

- (BOOL)isEnabledBool
{
    return [self.enabled boolValue];
}

- (void)setEnabledBool:(BOOL)e
{
    self.enabled = [NSNumber numberWithBool:e];
}

- (void)loadPropertiesFromDictionary:(NSDictionary*)dict
{
    [super loadPropertiesFromDictionary:dict];
    
    // custom load for property 'time'
    NSString* timeStr = [dict valueForKey:@"time"];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    NSDate* t = [timeFormat dateFromString:timeStr];
    self.time = t;
    NSLog(@"time: %@", self.time);
}

@end
