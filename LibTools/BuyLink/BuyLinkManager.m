//
//  BuyLinkManager.m
//  Yasound
//
//  Created by Jérôme Blondon on 17/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "BuyLinkManager.h"
#import "SBJson.h"

#define ITUNES_BASE_URL @"http://itunes.apple.com/search"
#define TRADEDOUBLER_URL @"http://clk.tradedoubler.com/click?p=23753&a=2007583&url="
#define TRADEDOUBLER_ID @"partnerId=2003"

@implementation BuyLinkManager

- (NSString *) getSeparator:(NSString *)url
{
  NSRange range = [url rangeOfString:@"?"];
  if (range.location == NSNotFound) {
    return @"?";
  }
  return @"&";
}

- (NSString *)getTrackViewUrl:(NSString *)responseString
{
  SBJsonParser *parser = [[SBJsonParser alloc] init]; 
  NSDictionary *object = [parser objectWithString:responseString error:nil];
  
  NSArray *results = (NSArray *) [object objectForKey:@"results"];
  NSString *trackViewUrl = nil;
  
  if ([results count] > 0) {
    NSDictionary *result = [results objectAtIndex:0];
    trackViewUrl = (NSString *)[result objectForKey:@"trackViewUrl"];
    if (trackViewUrl) {
      [trackViewUrl retain];
    }
  }
  [parser release];
  return trackViewUrl;
}

-(NSString *) generateLink: (NSString *) artist album:(NSString *)album song:(NSString *)song
{
  NSString *tradeUrl = nil;
  NSString *artistSanitized = [artist stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
  NSString *albumSanitized = [album stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
  NSString *songSanitized = [song stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
  NSString *term = [NSString stringWithFormat:@"%@ %@ %@",
                    artistSanitized,
                    albumSanitized,
                    songSanitized];
  
  NSString *urlString =[NSString stringWithFormat:@"%@?term=%@&entity=musicTrack&limit=1&country=FR",ITUNES_BASE_URL, [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  NSURL *url = [NSURL URLWithString:urlString];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request startSynchronous];
  NSError *error = [request error];
  if (!error) {
    NSString *response = [request responseString];
    NSString *trackViewUrl = [self getTrackViewUrl:response];
    
    if (!response || !trackViewUrl)
    {
      if (trackViewUrl)
        [trackViewUrl release];
      return nil;
    }

    tradeUrl =[NSString stringWithFormat:@"%@%@%@%@", TRADEDOUBLER_URL, trackViewUrl, [self getSeparator:trackViewUrl], TRADEDOUBLER_ID];
    
    [trackViewUrl release];
    NSLog(@"tradeURL = %@", tradeUrl);
  }
  return tradeUrl;
}
@end
