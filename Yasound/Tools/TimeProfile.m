//
//  TimeProfile.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TimeProfile.h"



@implementation TimeProfileItem : NSObject

@synthesize dateBegin;
@synthesize dateEnd;

- (NSTimeInterval)interval
{
    return [self.dateEnd timeIntervalSinceDate:self.dateBegin];
}

@end









@implementation TimeProfile


@synthesize items;


static TimeProfile* _main;

+ (TimeProfile*)main
{
    if (_main == nil)
    {
        _main = [[TimeProfile alloc] init];
    }
    
    return _main;
}


- (id)init
{
    if (self = [super init])
    {
        self.items = [[NSMutableDictionary alloc] init];
    }
    return self;
}



- (void)begin:(NSString*)nameReference
{
    assert(nameReference != nil);
    
    NSMutableArray* profiles = [self.items objectForKey:nameReference];
    if (profiles == nil)
    {
        profiles = [[NSMutableArray alloc] init];
        [self.items setObject:profiles forKey:nameReference];
    }
    
    TimeProfileItem* newItem = [[TimeProfileItem alloc] init];
    [profiles addObject:newItem];
    
    newItem.dateBegin = [NSDate date];
}


- (void)end:(NSString*)nameReference
{
    assert(nameReference != nil);

    NSMutableArray* profiles = [self.items objectForKey:nameReference];
    assert(profiles != nil);

    TimeProfileItem* item = [profiles objectAtIndex:(profiles.count -1)];
    assert(item.dateEnd == nil); // if fails here, means you called "end" twice for the same item
    
    item.dateEnd = [NSDate date];
}

- (CGFloat)interval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds {

    assert(nameReference != nil);
    
    NSMutableArray* profiles = [self.items objectForKey:nameReference];
    assert(profiles != nil);
    assert(profiles.count >0);
    
    TimeProfileItem* item = [profiles objectAtIndex:(profiles.count -1)];
    assert(item.dateEnd != nil); // if fails here, means you did not call "end" for this item, yet
    
    if (!inMilliseconds)
        return [item interval];
    else
        return [item interval] * 1000.f;
}



- (void)logInterval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds
{
    DLog(@"%@", [self dumpInterval:nameReference inMilliseconds:inMilliseconds]);
}


- (NSString*)dumpInterval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds
{
    CGFloat value = [self interval:nameReference inMilliseconds:inMilliseconds];
    
    if (!inMilliseconds)
        return [NSString stringWithFormat:@"TimeProfile '%@' %.2fs", nameReference, value];
    else
        return [NSString stringWithFormat:@"TimeProfile '%@' %.2fms", nameReference, value];
}


- (void)logAverageInterval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds
{
    DLog(@"%@", [self dumpAverageInterval:nameReference inMilliseconds:inMilliseconds]);
}
         

         
- (NSString*)dumpAverageInterval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds
{
    assert(nameReference != nil);
    
    NSMutableArray* profiles = [self.items objectForKey:nameReference];
    assert(profiles != nil);
    assert(profiles.count >0);
    
    CGFloat accu = 0;
    for (TimeProfileItem* item in profiles)
    {
        accu += [item interval];
    }
    
    CGFloat result = accu / profiles.count;
    
    if (!inMilliseconds)
        return [NSString stringWithFormat:@"TimeProfile AVERAGE '%@' %.2fs for %d mesures", nameReference, result, profiles.count];
    else
        return [NSString stringWithFormat:@"TimeProfile AVERAGE '%@' %.2fms for %d mesures", nameReference, result * 1000.f, profiles.count];
}




@end
