//
//  YasoundDataCacheGC.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 10/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YasoundDataCacheGC.h"

@implementation YasoundDataCacheGC


static YasoundDataCacheGC* _main = nil;

+ (YasoundDataCacheGC*)main
{
    if (_main == nil)
    {
        _main = [[YasoundDataCacheGC alloc] init];
    }
    
    return _main;
}


- (void)start
{
    
}


@end
