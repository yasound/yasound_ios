//
//  WallEvent.h
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "Radio.h"
#import "User.h"

typedef enum 
{
  eWallEventTypeMessage = 0,
  eWallEventTypeSong,
  eWallEventTypeLike,
  eWallEventTypeNone,
} WallEventType;

@interface WallEvent : Model
{
    NSMutableArray* _children;
    CGFloat _textHeight;
    BOOL _textHeightComputed;
    
    BOOL _editing;
}

@property (retain, nonatomic) NSString* type;
@property (retain, nonatomic) NSString* text;
@property (retain, nonatomic) NSNumber* animated_emoticon;
@property (retain, nonatomic) NSDate* start_date;

@property (retain, nonatomic) NSNumber* radio_id;

@property (retain, nonatomic) NSNumber* user_id;
@property (retain, nonatomic) NSString* user_name;
@property (retain, nonatomic) NSString* user_picture;

@property (retain, nonatomic) NSNumber* song_id;
@property (retain, nonatomic) NSString* song_name;
@property (retain, nonatomic) NSString* song_artist;
@property (retain, nonatomic) NSString* song_album;
@property (retain, nonatomic) NSString* song_cover_filename;


- (NSString*)toString;

- (WallEventType)wallEventType;
- (void)setWallEventType:(WallEventType)t;
- (BOOL)isOfType:(WallEventType)t;

- (NSString*)wallEventTypeString;



- (void)addChild:(WallEvent*)child;
- (NSArray*)getChildren;
- (void)setChildren:(NSArray*)children;
- (BOOL)removeChildren;

- (BOOL)isTextHeightComputed;
- (CGFloat)getTextHeight;
- (CGFloat)computeTextHeightUsingFont:(UIFont*)font withConstraint:(CGFloat)width;


- (BOOL)editing;
- (void)setEditing:(BOOL)set;

@end
