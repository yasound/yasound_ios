//
//  Playlist.h
//  Yasound
//
//  Created by matthieu campion on 12/14/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

@interface Playlist : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* source;
@property (retain, nonatomic) NSNumber* enabled;

@end
