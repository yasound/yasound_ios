//
//  CityInfo.h
//  Yasound
//
//  Created by matthieu campion on 7/3/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityInfo : NSObject

@property (retain, nonatomic) NSString* display_name;
@property (retain, nonatomic) NSNumber* lat;
@property (retain, nonatomic) NSNumber* lon;

- (NSString*)name;

@end
