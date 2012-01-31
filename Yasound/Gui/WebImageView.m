//
//  WebImageView.m
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/25/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WebImageView.h"
#import "BundleFileManager.h"


@implementation WebImageView

@synthesize url;


-(id)initWithImageFrame:(CGRect)frame
{
    self = [super init];
    if (self)
    {
        self.frame = frame;
    }
    
    return self;
}


-(id)initWithImageAtURL:(NSURL*)Url
{
    self = [super init];
    if (self)
    {
        [self setUrl:Url];
    }
  
  return self;
}


- (void)setUrl:(NSURL *)Url
{
    url = Url;
    if (Url == nil)
    {
        [self setImage:[UIImage imageNamed:@"avatarDummy.png"]]; 
        return;
    }
    
    [self setContentMode:UIViewContentModeScaleAspectFit];

    BundleStylesheet* stylesheet = [[BundleFileManager main] stylesheetForKey:@"WebImageActivityIndicator" error:nil];
    
    _ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];	
    [_ai autorelease];
    [_ai startAnimating];
    [_ai setFrame:stylesheet.frame];
    [self addSubview:_ai];
    
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:Url];
    // the https certificate seems to be ok but keep next line commented...
//    req.validatesSecureCertificate = FALSE;
    req.requestMethod = @"GET";
    [req setDelegate:self];
    [req startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];

    // Use when fetching binary data
    NSData* data = [request responseData];
    [self setImage:[UIImage imageWithData: data]]; 
    [_ai stopAnimating];
    [_ai removeFromSuperview];
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
  NSError *error = [request error];
  NSLog(@"HTTP Request error: %@", [error localizedDescription]);
}













@end