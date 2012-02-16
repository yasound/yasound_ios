//
//  WallEvent.m
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WallEvent.h"

@implementation WallEvent

@synthesize type;
@synthesize text;
@synthesize animated_emoticon;
@synthesize start_date;

@synthesize radio_id;

@synthesize user_id;
@synthesize user_name;
@synthesize user_picture;

@synthesize song_id;
@synthesize song_name;
@synthesize song_album;
@synthesize song_artist;
@synthesize song_cover_filename;

#define WALL_EVENT_TYPE_MESSAGE @"M"
#define WALL_EVENT_TYPE_SONG @"S"
#define WALL_EVENT_TYPE_LIKE @"L"

- (id)init
{
    if (self = [super init])
    {
        _textHeight = 0;
        _textHeightComputed = NO;
    }
    return self;
}


- (NSString*)toString
{
  NSString* desc;
  if ([self.type compare:@"M"] == NSOrderedSame)
  {
    desc = [NSString stringWithFormat:@"message from '%@'   text: '%@' emoticon: '%@'", self.user_name, self.text, self. animated_emoticon];
  }
  else if ([self.type compare:@"S"] == NSOrderedSame)
  {
    desc = [NSString stringWithFormat:@"song: '%@'", self.song_name];
  }
  return desc;
}

- (WallEventType)wallEventType
{
  if ([self.type isEqualToString:WALL_EVENT_TYPE_MESSAGE])
    return eWallEventTypeMessage;
  if ([self.type isEqualToString:WALL_EVENT_TYPE_SONG])
    return eWallEventTypeSong;
  if ([self.type isEqualToString:WALL_EVENT_TYPE_LIKE])
    return eWallEventTypeLike;
  
  return eWallEventTypeNone;
}

- (void)setWallEventType:(WallEventType)t
{
  switch (t) 
  {
    case eWallEventTypeMessage:
      self.type = WALL_EVENT_TYPE_MESSAGE;
      break;
      
    case eWallEventTypeSong:
      self.type = WALL_EVENT_TYPE_SONG;
      break;
      
    case eWallEventTypeLike:
      self.type = WALL_EVENT_TYPE_LIKE;
      break;
      
    case eWallEventTypeNone:
    default:
      self.type = nil;
      break;
  }
}

- (BOOL)isOfType:(WallEventType)t
{
  WallEventType selfType = [self wallEventType];
  return (selfType == t);
}

- (NSString*)wallEventTypeString
{
  WallEventType t = [self wallEventType];
  switch (t) 
  {
    case eWallEventTypeMessage:
      return @"Message";
      
    case eWallEventTypeSong:
      return @"Song";
      
    case eWallEventTypeLike:
      return @"Like";
      
      
    case eWallEventTypeNone:
    default:
      break;
  }
  
  return @"NoType";
}

- (void)dealloc
{
    if (_children != nil)
        [_children release];
    [super dealloc];
}

- (void)addChild:(WallEvent*)child
{
    if (_children == nil)
    {
        _children = [[NSMutableArray alloc] init];
        [_children retain];
    }
    
    [_children addObject:child];
}

- (NSArray*)getChildren
{
    return _children;
}

- (void)setChildren:(NSArray*)children
{
    if (_children != nil)
    {
        [_children release];
        _children = nil;
    }
    
    if (children == nil)
        return;
    
    _children = [[NSMutableArray alloc] initWithArray:children];
    [_children retain];
}

- (BOOL)removeChildren
{
    if (_children == nil)
        return NO;
    
    [_children release];
    _children = nil;
    return YES;
}



- (BOOL)isTextHeightComputed
{
    return _textHeightComputed;
}

- (CGFloat)getTextHeight
{
    return _textHeight;
}

- (CGFloat)computeTextHeightUsingFont:(UIFont*)font withConstraint:(CGFloat)width
{
    // compute the size of the text => will allow to update the cell's height dynamically
    CGSize suggestedSize = [self.text sizeWithFont:font constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    _textHeightComputed = YES;
    _textHeight = suggestedSize.height;
    
    // add lineheight each time a "\n" is found.
    NSRange range = NSMakeRange(0, self.text.length);
    NSRange find = [self.text rangeOfString:@"\n" options:NSLiteralSearch range:range];
    while (find.location != NSNotFound)
    {
        _textHeight += font.lineHeight;
        
        range.location = find.location + find.length;
        range.length = self.text.length - range.location;
        find = [self.text rangeOfString:@"\n" options:NSLiteralSearch range:range];
    }
    
    return _textHeight;
}




@end
