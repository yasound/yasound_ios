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


- (void)logInterval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds
{
    assert(nameReference != nil);

    NSMutableArray* profiles = [self.items objectForKey:nameReference];
    assert(profiles != nil);
    assert(profiles.count >0);

    TimeProfileItem* item = [profiles objectAtIndex:(profiles.count -1)];
    assert(item.dateEnd != nil); // if fails here, means you did not call "end" for this item, yet
    
    if (!inMilliseconds)
        NSLog(@"TimeProfile '%@' %.2fs", nameReference, [item interval]);
    else
        NSLog(@"TimeProfile '%@' %.2fms", nameReference, [item interval] * 1000.f);

}


- (void)logAverageInterval:(NSString*)nameReference inMilliseconds:(BOOL)inMilliseconds
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
        NSLog(@"TimeProfile AVERAGE '%@' %.2fs for %d mesures", nameReference, result, profiles.count);
    else
        NSLog(@"TimeProfile AVERAGE '%@' %.2fms for %d mesures", nameReference, result * 1000.f, profiles.count);
    
}




@end
