//
//  CityInfo.m
//  Yasound
//
//  Created by matthieu campion on 7/3/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "CityInfo.h"

@implementation CityInfo

@synthesize display_name;
@synthesize lat;
@synthesize lon;

- (NSString*)name
{
    NSArray* components = [self.display_name componentsSeparatedByString:@", "];
    if (components.count == 0)
        return nil;
    return [components objectAtIndex:0];
}

@end
