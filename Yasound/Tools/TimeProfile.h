//
//  TimeProfile.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeProfile : NSObject

@property (nonatomic, retain) NSDate* dateBegin;
@property (nonatomic, retain) NSDate* dateEnd;

+ (TimeProfile*)main;

- (void)begin;
- (void)end;
- (NSTimeInterval)interval;
- (void)logInterval:(NSString*)nameReference;

@end
