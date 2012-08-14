//
//  YasoundSong.m
//  Yasound
//
//  Created by matthieu campion on 2/22/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YasoundSong.h"

@implementation YasoundSong

@synthesize name;
@synthesize artist_name;
@synthesize album_name;
@synthesize cover;


- (id)init
{
    if (self = [super init])
    {
//        _uploading = NO;
    }
    return self;
}

//- (BOOL)isUploading
//{
//    return _uploading;
//}
//
//- (void)setUploading:(BOOL)set
//{
//    _uploading = set;
//}


@end
