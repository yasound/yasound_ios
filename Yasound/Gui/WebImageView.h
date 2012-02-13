//
//  WebImageView.h
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/25/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface WebImageView : UIImageView <ASIHTTPRequestDelegate> 

@property (retain, nonatomic) NSURL* url;

-(id) initWithImageFrame:(CGRect)frame;
-(id) initWithImageAtURL:(NSURL*)url;        

+(void) initCache;
+(void) clearCache;

@end