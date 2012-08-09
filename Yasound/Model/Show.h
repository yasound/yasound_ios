//
//  Show.h
//  Yasound
//
//  Created by mat on 09/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    eMonday = 0,
    eTuesday,
    eWednesday,
    eThursday,
    eFriday,
    eSaturday,
    eSunday,
    eEveryDay
} DayType;

@interface Show : NSObject

@property (retain, nonatomic) NSString* _id;
@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* day;
@property (retain, nonatomic) NSDate* time;
@property (retain, nonatomic) NSNumber* random_play;

- (BOOL)isRandomBool;
- (void)setRandomBool:(BOOL)random;

- (DayType)dayType;
- (void)setDayType:(DayType)t;

@end
