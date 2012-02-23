//
//  Song.m
//  Yasound
//
//  Created by matthieu campion on 1/27/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Song.h"

@implementation Song

@synthesize name;
@synthesize artist;
@synthesize album;
@synthesize cover;
@synthesize song;
@synthesize need_sync;
@synthesize likes;
@synthesize last_play_time;
@synthesize frequency;
@synthesize enabled;

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




- (NSString*)getFirstSignificantWord:(NSString*)field
{
    BOOL first = YES;
    CFStringRef string = field;
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
                ([token compare:@"la" options:NSCaseInsensitiveSearch] != NSOrderedSame))
            {
                [tokenValue autorelease];
                CFRelease(tokenizer);
                CFRelease(locale);   
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
    NSString* firstItem = [self getFirstSignificantWord:self.name];
    NSString* secondItem = [self getFirstSignificantWord:second.name];

    return [firstItem compare:secondItem];
}

- (NSComparisonResult)ArtistNameCompare:(Song*)second
{
    return [self.artist compare:second.artist];
}

- (NSComparisonResult)AlbumNameCompare:(Song*)second
{
    return [self.album compare:second.album];
}






@end


@implementation SongStatus

@synthesize likes;
@synthesize dislikes;

@end
