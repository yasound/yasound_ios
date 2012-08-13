//
//  Show.h
//  Yasound
//
//  Created by mat on 09/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MONDAY_STR @"MON"
#define TUESDAY_STR @"TUE"
#define WEDNESDAY_STR @"WED"
#define THURSDAY_STR @"THU"
#define FRIDAY_STR @"FRI"
#define SATURDAY_STR @"SAT"
#define SUNDAY_STR @"SUN"

typedef enum
{
    eMonday = 0,
    eTuesday,
    eWednesday,
    eThursday,
    eFriday,
    eSaturday,
    eSunday
} DayType;

@interface Show : NSObject

@property (retain, nonatomic) NSString* _id;
@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* days; // list of days as strings separated by commas. ex: @"MON,FRI,SAT"
@property (retain, nonatomic) NSDate* time;
@property (retain, nonatomic) NSNumber* random_play;
@property (retain, nonatomic) NSNumber* enabled; // on/off

- (BOOL)isRandomBool;
- (void)setRandomBool:(BOOL)random;

- (BOOL)isEnabledBool;
- (void)setEnabledBool:(BOOL)e;

@end
