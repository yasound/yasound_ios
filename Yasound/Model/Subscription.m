//
//  Subscription.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Subscription.h"

@implementation Subscription

@synthesize sku;
@synthesize description;
@synthesize enabled;
@synthesize duration;
@synthesize subscription_id;
@synthesize name;

- (BOOL)isEnabled
{
    return [self.enabled boolValue];
}


@end


//- (void)loadPropertiesFromDictionary:(NSDictionary*)dict
//{
//    [super loadPropertiesFromDictionary:dict];
//    
//    // custom load for property 'time'
//    NSString* timeStr = [dict valueForKey:@"time"];
//    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
//    [timeFormat setDateFormat:@"HH:mm"];
//    NSDate* t = [timeFormat dateFromString:timeStr];
//    self.time = t;
//    NSLog(@"time: %@", self.time);
//}


