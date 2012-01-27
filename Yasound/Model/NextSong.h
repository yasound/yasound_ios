//
//  NextSong.h
//  Yasound
//
//  Created by matthieu campion on 1/12/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"
#import "Radio.h"
#import "Song2.h"

@interface NextSong : Model

@property (retain) Radio* radio;
@property (retain) Song2* song;
@property (retain) NSNumber* order;

@end
