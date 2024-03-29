//
//  WebImageView.m
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/25/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WebImageView.h"
#import "BundleFileManager.h"
#import "ASIDownloadCache.h"
#import <Math.h>


#define IMAGE_THUMB_SIZE 100.f

#define USE_ACTIVITY_INDICATOR 0


static NSMutableDictionary* gDictionnary = NULL;
static ASIDownloadCache *gHttpCache = NULL;


@interface WebImageCache : NSObject <ASIHTTPRequestDelegate> 
{
  NSURL* url;
  NSMutableSet* webImages;
#if USE_ACTIVITY_INDICATOR
    NSMutableArray* anims;
#endif
    BOOL _loading;
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
    //NSLog(@"new image cache for url %@", [url absoluteString]);
      _loading = NO;
      
    [self load];
  }
  return self;
}

-(void)dealloc
{
  [url release];
  [webImages release];
#if USE_ACTIVITY_INDICATOR
  assert(anims == nil);
#endif
  [image release];
    [super dealloc];
}

- (void) addView:(WebImageView*)view
{
  //NSLog(@"Add view 0x%p to cache for %@", view, [url absoluteString]);

    if (webImages == nil)
        webImages = [[NSMutableSet alloc] init];
    
    [webImages addObject:view];
    [view setImage:image];

    if (_loading)
    {
#if USE_ACTIVITY_INDICATOR
        if (anims != nil) // We are currently reloading this image
        {
            BundleStylesheet* stylesheet = [[BundleFileManager main] stylesheetForKey:@"WebImageActivityIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];
            UIActivityIndicatorView* ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];	
            [ai startAnimating];
            [ai setFrame:stylesheet.frame];
            [view addSubview:ai];
            [anims addObject:ai];
        }
#endif
    }
    else
        [self load];

}    

- (void) removeView:(WebImageView*)view
{
  //NSLog(@"Remove view 0x%p from cache for %@", view, [url absoluteString]);
  [webImages removeObject:view];
}    


- (void)load
{
    _loading = YES;
    

#if USE_ACTIVITY_INDICATOR
    //NSLog(@"Initiate load for %@", [url absoluteString]);
    BundleStylesheet* stylesheet = [[BundleFileManager main] stylesheetForKey:@"WebImageActivityIndicator" retainStylesheet:YES overwriteStylesheet:NO error:nil];

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
#endif

    //LBDEBUG
    
//  ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
//  // the https certificate seems to be ok but keep next line commented...
//  //    req.validatesSecureCertificate = FALSE;
//  req.requestMethod = @"GET";
//  [req setDelegate:self];
//  [req setDownloadCache:gHttpCache];
//  [req setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];  
//  [req startAsynchronous];
}



- (void)requestFinished:(ASIHTTPRequest *)request
{
  // Use when fetching text data
  //NSString *responseString = [request responseString];
  //NSLog(@"HTTP Request for image ok: %@", [url absoluteString]);
  
  // Use when fetching binary data
  NSData* data = [request responseData];
  [image release];
    
    UIImage* tmp = [UIImage imageWithData: data];

    // we need a square image
    CGFloat size = (tmp.size.width > tmp.size.height)? tmp.size.height : tmp.size.width;
    CGFloat x = (tmp.size.width - size) / 2.f;
    CGFloat y = (tmp.size.height - size) / 2.f;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([tmp CGImage], CGRectMake(x, y, size, size));
    image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    [image retain];
    
    
    
  for (WebImageView* view in webImages)
  {
    //NSLog(@"set image for 0x%p", view);

    [view setImage:image];
  }
    
    _loading = NO;

#if USE_ACTIVITY_INDICATOR    
  for (UIActivityIndicatorView* view in anims)
  {
    [view removeFromSuperview];
    [view stopAnimating];
    [view release];
  }
  [anims release];
  anims = nil;
#endif
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
  NSError *error = [request error];
    _loading = NO;
  //NSLog(@"HTTP Request error: %@", [error localizedDescription]);
  
#if USE_ACTIVITY_INDICATOR
  for (UIActivityIndicatorView* view in anims)
  {
    [view removeFromSuperview];
    [view stopAnimating];
    [view release];
  }
  [anims release];
  anims = nil;
#endif
    
}









@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation WebImageView

@synthesize url;

+(void)initCache
{
  if (gDictionnary)
    return;
  
  gDictionnary = [[NSMutableDictionary alloc] init];
  [gDictionnary retain];

  gHttpCache = [[[ASIDownloadCache alloc] init] autorelease];
  NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *path = [cachePath stringByAppendingPathComponent:@"WebImage"];
  NSLog(@"Cache path for WebImage: %@", path);
  [gHttpCache setStoragePath:path];
  gHttpCache.defaultCachePolicy = ASIAskServerIfModifiedWhenStaleCachePolicy;
  gHttpCache.shouldRespectCacheControlHeaders = FALSE;
  
  // Don't forget - you are responsible for retaining your cache!
  [gHttpCache retain];
}

+(void)clearCache
{
  if (!gDictionnary)
    return;
  
  [gDictionnary release];
  [gHttpCache release];
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
  //NSLog(@"WebImage initWithImageFrame 0x%p", self);
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
  //NSLog(@"WebImage initWithImageAtURL 0x%p / %@", self, [Url absoluteURL]);
  self = [super init];
  if (self)
  {
    [self setUrl:Url];
  }
  
  return self;
}

-(void)dealloc
{
  //NSLog(@"WebImage dealloc 0x%p / %@", self, [self.url absoluteURL]);
  [WebImageView removeView:self fromUrl:self.url];
}

- (void)setUrl:(NSURL *)Url
{
  //NSLog(@"WebImage 0x%p setUrl:%@ (old: 0x%p / new: 0x%p)", self, [Url absoluteURL], self.url, Url);
  if (url != nil)
  {
    NSURL* u = url;
    NSString* s = [u absoluteString];
    //NSLog(@"WebImage 0x%p previous url:%@", self, s);
    [WebImageView removeView:self fromUrl:url];
  }

  url = Url;    
  [url retain];
    
  if (Url == nil)
  {
    [self setImage:[UIImage imageNamed:@"avatarDummy.png"]]; 
    return;
  }
  
  [WebImageView addView:self toUrl:self.url];
}


@end