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
@synthesize ai;

-(id)initWithImageAtURL:(NSURL*)url
{
    self = [super init];
    if (self)
    {
        [self setContentMode:UIViewContentModeScaleAspectFit];

        BundleStylesheet* stylesheet = [[BundleFileManager main] stylesheetForKey:@"WebImageActivityIndicator" error:nil];

        [self setAi:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];	
        [ai startAnimating];
        [ai setFrame:stylesheet.frame];
        [self addSubview:ai];

        //url = [NSURL URLWithString:@"https://dev.yasound.com/media/pictures/DSC_9226_2.jpg"];
        ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
        req.validatesSecureCertificate = FALSE;
        req.requestMethod = @"GET";
        [req setDelegate:self];
        [req startAsynchronous];
    }
  
  return self;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];

    // Use when fetching binary data
    NSData* data = [request responseData];
    [self setImage:[UIImage imageWithData: data]]; 
    [self.ai stopAnimating];
    [self.ai removeFromSuperview];
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
  NSError *error = [request error];
  NSLog(@"HTTP Request error: %@", [error localizedDescription]);
}


@end