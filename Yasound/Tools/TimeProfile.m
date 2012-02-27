//
//  TimeProfile.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TimeProfile.h"

@implementation TimeProfile

@synthesize dateBegin;
@synthesize dateEnd;


static TimeProfile* _main;

+ (TimeProfile*)main
{
    if (_main == nil)
    {
        _main = [[TimeProfile alloc] init];
    }
    
    return _main;
}


- (void)begin
{
    self.dateBegin = [NSDate date];
}

- (void)end
{
    self.dateEnd = [NSDate date];
}

- (NSTimeInterval)interval
{
    return [self.dateEnd timeIntervalSinceDate:self.dateBegin];
}

- (void)logInterval
{
    NSLog(@"TimeProfile %.2f", [self interval]);

}




@end
