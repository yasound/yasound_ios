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
@synthesize song;
@synthesize need_sync;
@synthesize likes;
@synthesize last_play_time;
@synthesize frequency;
@synthesize enabled;


//- (id)init
//{
//    if (self = [super init])
//    {
//        _nameWithoutArticle = nil;
//    }
//    return self;
//}

- (void)dealloc
{
    if (_nameWithoutArticle != nil)
        [_nameWithoutArticle release];
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
        
        
    BOOL first = YES;
    CFStringRef string = self.name;
    CFLocaleRef locale = CFLocaleCopyCurrent();
    
    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string, CFRangeMake(0, CFStringGetLength(string)), kCFStringTokenizerUnitWord, locale);
    
    CFStringTokenizerTokenType tokenType = kCFStringTokenizerTokenNone;
    unsigned tokensFound = 0;
    
    while(kCFStringTokenizerTokenNone != (tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer))) 
    {
        CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        CFStringRef tokenValue = CFStringCreateWithSubstring(kCFAllocatorDefault, string, tokenRange);

        if (first)
        {
            first = NO;
            
            NSString* token = (NSString*)tokenValue;
            
            if ( ([token compare:@"the" options:NSCaseInsensitiveSearch] != NSOrderedSame) &&
                ([token compare:@"a" options:NSCaseInsensitiveSearch] != NSOrderedSame) &&
                ([token compare:@"le" options:NSCaseInsensitiveSearch] != NSOrderedSame) &&
                ([token compare:@"la" options:NSCaseInsensitiveSearch] != NSOrderedSame) &&
                ([token compare:@"l'" options:NSCaseInsensitiveSearch] != NSOrderedSame) &&
                ([token compare:@"l" options:NSCaseInsensitiveSearch] != NSOrderedSame)) 
            {
                [tokenValue autorelease];
                CFRelease(tokenizer);
                CFRelease(locale);   
                
                // store cache
                _firstRelevantWord = [NSString stringWithString:token];
                [_firstRelevantWord retain];
                
                return token;
            }
            
            CFRelease(tokenValue);
            ++tokensFound;
        }
        else
        {
            //CFRelease(tokenValue);
            [tokenValue autorelease];

            CFRelease(tokenizer);
            CFRelease(locale);   

            // store cache
            _firstRelevantWord = [NSString stringWithString:tokenValue];
            [_firstRelevantWord retain];

            return tokenValue;
        }
    }
    
    // Clean up
    CFRelease(tokenizer);
    CFRelease(locale);   
    return nil;
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






@end


@implementation SongStatus

@synthesize likes;
@synthesize dislikes;

@end
