//
//  SongUploading.m
//  Yasound
//
//  Created by loïc berthelot.
//  Copyright (c) 2012 Yasound. All rights reserved.
//


#import "SongUploading.h"



@implementation SongUploading

@synthesize radio_id;

+(SongUploading*)new;
{
    SongUploading* obj = [[SongUploading alloc] init];
    [obj autorelease];
    return obj;
}

- (NSString*)artist
{
    DLog(@"MEUH!");
    assert(0);
}


@end



