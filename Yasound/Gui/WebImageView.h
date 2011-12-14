//
//  WebImageView.h
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/25/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface WebImageView : UIImageView <ASIHTTPRequestDelegate> {
  
  UIActivityIndicatorView *ai;
}

-(id)initWithImageAtURL:(NSURL*)url;	         

@property (nonatomic, retain) UIActivityIndicatorView *ai;

@end