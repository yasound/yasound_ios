//
//  Service.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Service.h"

@implementation Service

@synthesize active;
@synthesize expiration_date;
@synthesize service;

- (BOOL)isActive
{
    return [self.active boolValue];
}


- (NSString*)toString
{
    NSString* str = @"Service : ";
    
    str = [str stringByAppendingFormat:@"service : '%@'    ", self.service];
    str = [str stringByAppendingFormat:@"active : '%@'    ", self.active];
    str = [str stringByAppendingFormat:@"expiration_date : '%@'    ", self.expiration_date];
    
    return str;
}


- (void)loadPropertiesFromDictionary:(NSDictionary*)dict
{
    [super loadPropertiesFromDictionary:dict];
    
    // custom load for property 'time'
    NSString* timeStr = [dict valueForKey:@"expiration_date"];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ss"];
    NSDate* t = [timeFormat dateFromString:timeStr];
    self.expiration_date = t;
    //NSLog(@"time: %@", self.time);
}


@end


