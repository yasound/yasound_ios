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
@synthesize enabled;
@synthesize highlighted;

- (BOOL)isEnabled
{
    return [self.enabled boolValue];
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
    str = [str stringByAppendingFormat:@"enabled : '%@'    ", self.enabled];
    str = [str stringByAppendingFormat:@"highlighted : '%@'    ", self.highlighted];
    
    return str;
}

@end



