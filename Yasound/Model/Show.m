//
//  Show.m
//  Yasound
//
//  Created by mat on 09/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Show.h"

#define MONDAY_STR @"MON"
#define TUESDAY_STR @"TUE"
#define WEDNESDAY_STR @"WED"
#define THURSDAY_STR @"THU"
#define FRIDAY_STR @"FRI"
#define SATURDAY_STR @"SAT"
#define SUNDAY_STR @"SUN"
#define EVERYDAY_STR @"ALL"

@implementation Show

@synthesize _id;
@synthesize name;
@synthesize day;
@synthesize time;
@synthesize random_play;

- (BOOL)isRandomBool
{
    return [self.random_play boolValue];
}

- (void)setRandomBool:(BOOL)random
{
    self.random_play = [NSNumber numberWithBool:random];
}

- (DayType)dayType
{
    DayType t = eEveryDay;
    if ([self.day isEqualToString:MONDAY_STR])
    {
        t = eMonday;
    }
    else if ([self.day isEqualToString:TUESDAY_STR])
    {
        t = eTuesday;
    }
    else if ([self.day isEqualToString:WEDNESDAY_STR])
    {
        t = eWednesday;
    }
    else if ([self.day isEqualToString:THURSDAY_STR])
    {
        t = eThursday;
    }
    else if ([self.day isEqualToString:FRIDAY_STR])
    {
        t = eFriday;
    }
    else if ([self.day isEqualToString:SATURDAY_STR])
    {
        t = eSaturday;
    }
    else if ([self.day isEqualToString:SUNDAY_STR])
    {
        t = eSunday;
    }
    else if ([self.day isEqualToString:EVERYDAY_STR])
    {
        t = eEveryDay;
    }
    
    return t;
}

- (void)setDayType:(DayType)t
{
    switch (t)
    {
        case eMonday:
            self.day = MONDAY_STR;
            break;
            
        case eTuesday:
            self.day = TUESDAY_STR;
            break;
        
        case eWednesday:
            self.day = WEDNESDAY_STR;
            break;
            
        case eThursday:
            self.day = THURSDAY_STR;
            break;
            
        case eFriday:
            self.day = FRIDAY_STR;
            break;
            
        case eSaturday:
            self.day = SATURDAY_STR;
            break;
            
        case eSunday:
            self.day = SUNDAY_STR;
            break;
            
        case eEveryDay:
            self.day = EVERYDAY_STR;
            break;
            
        default:
            break;
    }
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
