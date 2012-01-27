//
//  Song.h
//  Yasound
//
//  Created by matthieu campion on 1/27/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"

@interface Song : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* artist;
@property (retain, nonatomic) NSString* album;
@property (retain, nonatomic) NSString* cover;

@end

@interface SongStatus : Model

@property (retain, nonatomic) NSNumber* likes;
@property (retain, nonatomic) NSNumber* dislikes;

@end
