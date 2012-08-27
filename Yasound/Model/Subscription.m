//
//  Subscription.m
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Subscription.h"

@implementation Subscription

@synthesize sku;
@synthesize duration;
@synthesize current;
@synthesize enabled;
@synthesize highlighted;

- (BOOL)isEnabled
{
    return [self.enabled boolValue];
}

- (BOOL)isCurrent
{
    return [self.current boolValue];
}

- (BOOL)isHighlighted
{
    return [self.highlighted boolValue];
}


- (NSString*)toString
{
    NSString* str = @"subscription : ";
    
    str = [str stringByAppendingFormat:@"sku : '%@'    ", self.sku];
    str = [str stringByAppendingFormat:@"duration : '%@'    ", self.duration];
    str = [str stringByAppendingFormat:@"current : '%@'    ", self.current];
    str = [str stringByAppendingFormat:@"enabled : '%@'    ", self.enabled];
    str = [str stringByAppendingFormat:@"highlighted : '%@'    ", self.highlighted];
    
    return str;
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


