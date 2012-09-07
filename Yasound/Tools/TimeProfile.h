//
//  TimeProfile.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TimeProfileItem : NSObject

@property (nonatomic, retain) NSDate* dateBegin;
@property (nonatomic, retain) NSDate* dateEnd;

- (NSTimeInterval)interval;

@end





@interface TimeProfile : NSObject

@property (nonatomic, retain) NSMutableDictionary* items;

+ (TimeProfile*)main;

- (void)begin:(NSString*)nameReference;
- (void)end:(NSString*)nameReference;

- (CGFloat)interval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds;
- (void)logInterval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds;
- (void)logAverageInterval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds;

@end
