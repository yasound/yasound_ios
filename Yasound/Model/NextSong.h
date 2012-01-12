//
//  NextSong.h
//  Yasound
//
//  Created by matthieu campion on 1/12/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"
#import "Radio.h"
#import "Song.h"

@interface NextSong : Model

@property (retain) Radio* radio;
@property (retain) Song* song;
@property (retain) NSNumber* order;

@end
