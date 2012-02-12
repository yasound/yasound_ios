//
//  WebImageView.m
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/25/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WebImageView.h"
#import "BundleFileManager.h"

@interface WebImageCache : NSObject <ASIHTTPRequestDelegate> 
{
  NSURL* url;
  NSMutableSet* webImages;
  NSMutableArray* anims;
  UIImage* image;
}

- (id) initWithURL:(NSURL*)url;
- (void) load;
- (void) requestFinished:(ASIHTTPRequest *)request;
- (void) addView:(WebImageView*)view;

@end

@implementation WebImageCache

-(id)initWithURL:(NSURL*)Url
{
  self = [super init];
  if (self)
  {
    url = Url;
    NSLog(@"new image cache for url %@", [url absoluteString]);
    [self load];
  }
  return self;
}

-(void)dealloc
{
  [url release];
  [webImages release];
  assert(anims == nil);
  [image release];
}

- (void) addView:(WebImageView*)view
{
  NSLog(@"Add view 0x%p to cache for %@", view, [url absoluteString]);
  if (webImages == nil)
    webImages = [[NSMutableSet alloc] init];
  [webImages addObject:view];
  [view setImage:image];
  if (anims != nil) // We are currently reloading this image
  {
    BundleStylesheet* stylesheet = [[BundleFileManager main] stylesheetForKey:@"WebImageActivityIndicator" error:nil];
    UIActivityIndicatorView* ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];	
    [ai startAnimating];
    [ai setFrame:stylesheet.frame];
    [view addSubview:ai];
    [anims addObject:ai];
  }
}    

- (void) removeView:(WebImageView*)view
{
  NSLog(@"Remove view 0x%p from cache for %@", view, [url absoluteString]);
  [webImages removeObject:view];
}    


- (void)load
{
  NSLog(@"Initiate load for %@", [url absoluteString]);
  BundleStylesheet* stylesheet = [[BundleFileManager main] stylesheetForKey:@"WebImageActivityIndicator" error:nil];
  
  assert(anims == nil);
  anims = [[NSMutableArray alloc] init];
  assert(anims != nil);
  
  for (WebImageView* view in webImages)
  {
    UIActivityIndicatorView* ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];	
    [ai startAnimating];
    [ai setFrame:stylesheet.frame];
    [view addSubview:ai];
    [anims addObject:ai];
  }
  
  ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
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
  NSLog(@"HTTP Request for image ok: %@", [url absoluteString]);
  
  // Use when fetching binary data
  NSData* data = [request responseData];
  [image release];
  image = [UIImage imageWithData: data]; 
  [image retain];
  
  for (WebImageView* view in webImages)
  {
    NSLog(@"set image for 0x%p", view);

    [view setImage:image];
  }
  
  for (UIActivityIndicatorView* view in anims)
  {
    [view removeFromSuperview];
    [view stopAnimating];
    [view release];
  }
  [anims release];
  anims = nil;
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
  NSError *error = [request error];
  NSLog(@"HTTP Request error: %@", [error localizedDescription]);
  
  for (UIActivityIndicatorView* view in anims)
  {
    [view removeFromSuperview];
    [view stopAnimating];
    [view release];
  }
  [anims release];
  anims = nil;
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation WebImageView

@synthesize url;

static NSMutableDictionary* gDictionnary = NULL;

+(void)initCache
{
  if (gDictionnary)
    return;
  
  gDictionnary = [[NSMutableDictionary alloc] init];
  [gDictionnary retain];
}

+(void)clearCache
{
  if (!gDictionnary)
    return;
  
  [gDictionnary release];
}



+(void) removeView:(WebImageView*)view fromUrl:(NSURL*)url
{
  WebImageCache* cache = [gDictionnary objectForKey:url];
  if (cache == nil)
    return;

  [cache removeView:view];
}

+(void) addView:(WebImageView*)view toUrl:(NSURL*)url
{
  [WebImageView initCache];
  WebImageCache* cache = [gDictionnary objectForKey:url];
  if (cache == nil)
  {
    cache = [[WebImageCache alloc] initWithURL:url];
    [gDictionnary setObject:cache forKey:url];
  }
  
  [cache addView:view];
}



-(id)initWithImageFrame:(CGRect)frame
{
  self = [super init];
  if (self)
  {
    self.frame = frame;
    self.url = nil;
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

-(void)dealloc
{
  [WebImageView removeView:self fromUrl:self.url];
}

- (void)setUrl:(NSURL *)Url
{
  if (url != nil)
  {
    NSURL* u = url;
    NSString* s = [u absoluteString];
    NSLog(@"WebImage setUrl:%@", s);
    [WebImageView removeView:self fromUrl:url];
  }

  url = Url;
  if (Url == nil)
  {
    [self setImage:[UIImage imageNamed:@"avatarDummy.png"]]; 
    return;
  }
  
  [WebImageView addView:self toUrl:self.url];
}


@end