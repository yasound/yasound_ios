//
//  Song.h
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"
#import "SongMetadata.h"

@interface Song : Model


@property (retain, nonatomic) NSNumber* song;
@property (retain, nonatomic) SongMetadata* metadata;

- (NSString*)toString;

@end
