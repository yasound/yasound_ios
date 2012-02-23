//
//  Song.m
//  Yasound
//
//  Created by matthieu campion on 1/27/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Song.h"

#define FREQUENCY_TYPE_LOW_STRING     @"L"
#define FREQUENCY_TYPE_NORMAL_STRING  @"N"
#define FREQUENCY_TYPE_HIGH_STRING    @"H"

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

- (SongFrequencyType)frequencyType
{
  if ([self.frequency isEqualToString:FREQUENCY_TYPE_LOW_STRING])
    return eSongFrequencyTypeLow;
  else if ([self.frequency isEqualToString:FREQUENCY_TYPE_NORMAL_STRING])
    return eSongFrequencyTypeNormal;
  else if ([self.frequency isEqualToString:FREQUENCY_TYPE_HIGH_STRING])
    return eSongFrequencyTypeHigh;
  
  return eSongFrequencyTypeNone;
}

- (void)setFrequencyType:(SongFrequencyType)f
{
  switch (f) 
  {
    case eSongFrequencyTypeLow:
      self.frequency = FREQUENCY_TYPE_LOW_STRING;
      break;
      
    case eSongFrequencyTypeNormal:
      self.frequency = FREQUENCY_TYPE_NORMAL_STRING;
      break;
      
    case eSongFrequencyTypeHigh:
      self.frequency = FREQUENCY_TYPE_HIGH_STRING;
      break;
      
    case eSongFrequencyTypeNone:
    default:
      self.frequency = @"";
      break;
  }
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
