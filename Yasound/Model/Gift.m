//
//  Gift.m
//  Yasound
//
//  Created by mat on 05/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Gift.h"

@implementation Gift

- (BOOL)canBeWon
{
    if (![self.enabled boolValue])
        return NO;
    
    BOOL fullyWon = [self hasBeenFullyWon];
    return !fullyWon;
}

- (BOOL)hasBeenWon
{
    BOOL won = [self.count integerValue] > 0;
    return won;
}

- (BOOL)hasBeenFullyWon
{
    BOOL fullyWon = [self.count integerValue] >= [self.max integerValue];
    return fullyWon;
}

- (NSString*)countProgress
{
    NSString* s = [NSString stringWithFormat:@"%d/%d", [self.count integerValue], [self.max integerValue]];
    return s;
}

- (NSString*)formattedDate
{
    // date formatting
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    NSDate* now = [NSDate date];
    NSDateComponents* todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:now];
    NSDateComponents* refComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self.last_achievement_date];
    
    if (todayComponents.year == refComponents.year && todayComponents.month == refComponents.month && todayComponents.day == refComponents.day)
    {
        // today: show time
        [dateFormat setDateFormat:@"HH:mm"];
    }
    else
    {
        // not today: show date
        [dateFormat setDateFormat:@"dd/MM"];
    }
    
    NSString* dateString = [dateFormat stringFromDate:self.last_achievement_date];
    return dateString;
}

- (void)doAction
{
    if (!self.action_url_ios)
        return;
    
    NSURL* url = [NSURL URLWithString:self.action_url_ios];
    [[UIApplication sharedApplication] openURL:url];
}

@end
