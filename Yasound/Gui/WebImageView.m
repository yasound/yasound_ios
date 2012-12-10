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
    [super dealloc];
}



- (void)setUrl:(NSURL*)aUrl
{
    if (aUrl == nil)
        return;
    
    if (self.url)
        [self releaseCache];
    
    UIImage* image = [[YasoundDataCache main] requestImage:aUrl target:self action:@selector(onImageUpdated:)];
    
    [self setImage:image];
    
    url = aUrl;
    [url retain];
}


- (void)onImageUpdated:(UIImage*)image
{
    if (image == nil)
        return;
    
    [self setImage:image];
}


- (void)releaseCache
{
    [[YasoundDataCache main] releaseImageRequest:self.url forTarget:self];
}


@end