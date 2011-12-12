//
//  WebImageView.h
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/25/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebImageView : UIImageView {
  
  NSURLConnection *connection;
  NSMutableData* data;
  UIActivityIndicatorView *ai;
}

-(id)initWithImageAtURL:(NSURL*)url;	         

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData* data;
@property (nonatomic, retain) UIActivityIndicatorView *ai;

@end