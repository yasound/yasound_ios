//
//  YasoundSong.h
//  Yasound
//
//  Created by matthieu campion on 2/22/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"

@interface YasoundSong : Model
{
    BOOL _uploading;
}

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* artist_name;
@property (retain, nonatomic) NSString* album_name;
@property (retain, nonatomic) NSString* cover;

- (BOOL)isUploading;
- (void)setUploading:(BOOL)set;

@end
