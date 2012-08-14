//
//  Song.m
//  Yasound
//
//  Created by matthieu campion on 1/27/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Song.h"

@implementation Song

//@synthesize name;
@synthesize artist;
@synthesize album;
@synthesize cover;
@synthesize name_client;
@synthesize artist_client;
@synthesize album_client;
@synthesize song;
@synthesize need_sync;
@synthesize likes;
@synthesize last_play_time;
@synthesize frequency;
@synthesize enabled;
@synthesize order;


- (id)init
{
    if (self = [super init])
    {
        _isProgrammed = NO;
        _removed = NO;
    }
    return self;
}

- (void)dealloc
{
    if (_nameWithoutArticle != nil)
        [_nameWithoutArticle release];
    if (_firstRelevantWord != nil)
        [_firstRelevantWord release];
    
    [super dealloc];
}

- (void)setName:(NSString*)name
{
    if (_name != nil)
        [_name release];
    _name = [NSString stringWithString:name];
    [_name retain];
    
    if (_nameWithoutArticle != nil)
        [_nameWithoutArticle release];
    _nameWithoutArticle = nil;
    
    if (_firstRelevantWord != nil)
        [_firstRelevantWord release];
    _firstRelevantWord = nil;
}

- (NSString*)name
{
    return _name;
}



- (SongFrequencyType)frequencyType
{
  if (!self.frequency)
    return eSongFrequencyTypeNone;
  
  float f = [self.frequency floatValue];
  if (f > 0.75)
    return eSongFrequencyTypeHigh;
  
  return eSongFrequencyTypeNormal;
}


- (void)setFrequencyType:(SongFrequencyType)f
{
  switch (f) 
  {
    case eSongFrequencyTypeNormal:
      self.frequency = [NSNumber numberWithFloat:0.5];
      break;
      
    case eSongFrequencyTypeHigh:
      self.frequency = [NSNumber numberWithFloat:1];
      break;
      
    case eSongFrequencyTypeNone:
    default:
      self.frequency = [NSNumber numberWithFloat:0];
      break;
  }
}

- (BOOL)isSongEnabled
{
  return [self.enabled boolValue];
}

- (void)enableSong:(BOOL)on
{
  self.enabled = [NSNumber numberWithBool:on];
}


- (BOOL)isSongRemoved
{
    return _removed;
}

- (void)removeSong:(BOOL)set
{
    _removed = set;
}



- (NSString*)getNameWithoutArticle
{
    // return cache 
    if (_nameWithoutArticle != nil)
        return _nameWithoutArticle;
    
    NSString* firstWord = [self getFirstRelevantWord];
    if (firstWord == nil)
        return self.name;
    
    NSRange range = [self.name rangeOfString:firstWord];
    if (range.location == NSNotFound)
        return self.name;

    NSRange range2;
    range2.location = range.location + range.length;
    range2.length = self.name.length - range2.location;
        
    _nameWithoutArticle = [self.name substringWithRange:range2];
    _nameWithoutArticle =  [_nameWithoutArticle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // store cache
    [_nameWithoutArticle retain];
    
    return _nameWithoutArticle;
}



- (NSString*)getFirstRelevantWord
{
    // return cache
    if (_firstRelevantWord != nil)
        return _firstRelevantWord;
    
    NSInteger firstRelevantIndex = 0;
    
//    DLog(@"getFirstRelevantWord of '%@'", self.name);
//    if ([self.name isEqualToString:@"The Well"])
//    {
//        DLog(@"ok");
//    }
    
    NSString* fourChars = nil;
    
    if (self.name.length >= 4)
        fourChars = [self.name substringToIndex:4];
    
    if ((fourChars != nil) && [fourChars compare:@"the " options:NSCaseInsensitiveSearch] == NSOrderedSame)
        firstRelevantIndex = 4;
    else
    {
        NSString* threeChars = nil;
        
        if (self.name.length >= 3)
            threeChars = [self.name substringToIndex:3];
        
        if ( (threeChars != nil) 
            && ( ([threeChars compare:@"le " options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([threeChars compare:@"la " options:NSCaseInsensitiveSearch] == NSOrderedSame)
                )
            )
        {
            firstRelevantIndex = 3;
        }
        else
        {
            NSString* twoChars = nil;
            
            if (self.name.length >= 2)
                twoChars = [self.name substringToIndex:2];
            if ( (twoChars != nil) 
                &&  ( ([twoChars compare:@"l'" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                     || ([twoChars compare:@"l " options:NSCaseInsensitiveSearch] == NSOrderedSame)
                     || ([twoChars compare:@"a " options:NSCaseInsensitiveSearch] == NSOrderedSame)
                     )
                )
            {
                firstRelevantIndex = 2;
            }
            else
            {
                unichar c = [self.name characterAtIndex:0];
                
                if (c == '\'')
                {
                    firstRelevantIndex = 1;
                }
            }
            
        }
    }
    
    
    
    // trim space
    unichar c = [self.name characterAtIndex:firstRelevantIndex];
    while (c == ' ')
    {
        firstRelevantIndex++;
        c = [self.name characterAtIndex:firstRelevantIndex];
    }

    // find end of token
    NSRange end = [self.name rangeOfString:@" " options:NSLiteralSearch range:NSMakeRange(firstRelevantIndex, self.name.length - firstRelevantIndex)];
    if (end.location == NSNotFound)
    {
        end.location = self.name.length;
        end.length = 0;
    }
        
    
    _firstRelevantWord = [self.name substringWithRange:NSMakeRange(firstRelevantIndex, end.location - firstRelevantIndex)];
    [_firstRelevantWord retain];
    
    return _firstRelevantWord;
}




- (NSComparisonResult)nameCompare:(Song*)second
{
    NSString* firstItem = [self getFirstRelevantWord];
    NSString* secondItem = [second getFirstRelevantWord];

    return [firstItem compare:secondItem];
}

- (NSComparisonResult)artistCompare:(Song*)second
{
    return [self.artist compare:second.artist];
}

- (NSComparisonResult)albumCompare:(Song*)second
{
    return [self.album compare:second.album];
}

- (BOOL)isProgrammed
{
    return _isProgrammed;
}

- (void)setIsProgrammed:(BOOL)set
{
    _isProgrammed = set;
}







@end


@implementation SongStatus

@synthesize likes;
@synthesize dislikes;

@end
