//
//  Tile.m
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/24/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Tile.h"
#import "WebImageView.h"

@implementation Tile

@synthesize ai,connection, data;

- (id)initWithFrame:(CGRect)frame identifier:(NSString*)ident andImageURL:(NSURL*)imageUrl
{
    self = [super initWithFrame:frame];
    if (self)
    {
      identifier = [NSString stringWithString:ident];
      [self setContentMode:UIViewContentModeScaleAspectFit];
      if (!ai)
      {
        [self setAi:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]];	
        [ai startAnimating];
        [ai setFrame:CGRectMake(27, 13, 20, 20)];
        [self addSubview:ai];
      }
      
      NSURLRequest* request = [NSURLRequest requestWithURL:imageUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
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
  [self setImage:[UIImage imageWithData: data] forState:UIControlStateNormal]; 
  [ai removeFromSuperview];
}

-(void)dealloc{
  [data release];
  [connection release];
  [ai release];
  [super dealloc];
}

- (NSString *)description
{
  return identifier;
}

@end
