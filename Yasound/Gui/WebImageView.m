//
//  WebImageView.m
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/25/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WebImageView.h"

@implementation WebImageView
@synthesize ai,connection, data;

-(id)initWithImageAtURL:(NSURL*)url
{
  self = [super init];
  if (self)
  {
    [self setContentMode:UIViewContentModeScaleAspectFit];
    if (!ai){
      [self setAi:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]];	
      [ai startAnimating];
      [ai setFrame:CGRectMake(27, 13, 20, 20)];
      [self addSubview:ai];
    }
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];    
  }
  
  return self;
}

- (void)connection:(NSURLConnection *)theConnection	didReceiveData:(NSData *)incrementalData {
  if (data==nil) data = [[NSMutableData alloc] initWithCapacity:2048];
  [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection 
{
  //const char* pChars = (char*)[data mutableBytes];
  //printf("cnx done:\n%s\n", pChars);
  [self setImage:[UIImage imageWithData: data]]; 
  [ai removeFromSuperview];
}

-(void)dealloc{
  [data release];
  [connection release];
  [ai release];
  [super dealloc];
}
@end