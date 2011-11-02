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
      
      // Title:
      title = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, frame.size.width - 6, 20)];
      title.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
      title.text = ident;
      [self addSubview:title];
      
      // Image View:
      int s = self.frame.size.width - 4;
      CGRect r = CGRectMake(4, 22, s, s);
      imageView = [[UIImageView alloc] initWithFrame:r];
      [self addSubview:imageView];

      // Caption:
      caption = [[UILabel alloc] initWithFrame:CGRectMake(0, r.size.height - 20, r.size.width, 20)];
      caption.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
      caption.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.9];
      caption.text = @"Caption!";
      [imageView addSubview:caption];
      
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
  //[self setImage:[UIImage imageWithData: data] forState:UIControlStateNormal]; 
  imageView.image = [UIImage imageWithData: data];
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
