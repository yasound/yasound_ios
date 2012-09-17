//
//  WebImageView.m
//
//  Created by Sébastien Métrot on 10/25/11.
//  modified by Loïc Berthelot on 03/09/12
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WebImageView.h"
#import "BundleFileManager.h"
#import "YasoundDataCache.h"
#import "TimeProfile.h"


#define IMAGE_THUMB_SIZE 100.f

#define USE_ACTIVITY_INDICATOR 0



@implementation WebImageView

@synthesize url;


-(id)initWithImageFrame:(CGRect)frame
{
  //DLog(@"WebImage initWithImageFrame 0x%p", self);
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
  //DLog(@"WebImage initWithImageAtURL 0x%p / %@", self, [Url absoluteURL]);
  self = [super init];
  if (self)
  {
    [self setUrl:Url];
  }
  
  return self;
}

-(void)dealloc
{
    [super dealloc];
}



- (void)setUrl:(NSURL*)aUrl
{
    if (aUrl == nil)
        return;
    
    
#ifdef DEBUG_PROFILE
    //LBDEBUG ICI
    [[TimeProfile main] begin:@"setUrl1"];
#endif
    
    UIImage* image = [[YasoundDataCache main] requestImage:aUrl target:self action:@selector(onImageUpdated:)];
    
#ifdef DEBUG_PROFILE
    //LBDEBUG ICI
    [[TimeProfile main] end:@"setUrl1"];
    [[TimeProfile main] logAverageInterval:@"setUrl1" inMilliseconds:YES];
#endif

    [self setImage:image];
    
    url = aUrl;
    [url retain];
}


- (void)onImageUpdated:(UIImage*)image
{
    if (image == nil)
        return;
    
    //LBDEBUG
    //NSLog(@"onImageUpdated size %.2f x %.2f", image.size.width, image.size.height);
    
    [self setImage:image];
}


- (void)releaseCache
{
    [[YasoundDataCache main] releaseImageRequest:self.url forTarget:self];
}


@end