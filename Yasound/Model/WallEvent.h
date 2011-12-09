//
//  WallEvent.h
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"
#import "Song.h"
#import "Radio.h"
#import "User.h"

@interface WallEvent : Model

@property (retain, nonatomic) NSString* type;
@property (retain, nonatomic) NSString* text;
@property (retain, nonatomic) NSNumber* animated_emoticon;
@property (retain, nonatomic) NSDate* start_date;
@property (retain, nonatomic) NSDate* end_date;
@property (retain, nonatomic) Song* song;
@property (retain, nonatomic) Radio* radio;
@property (retain, nonatomic) User* user;

- (NSString*)toString;

@end
