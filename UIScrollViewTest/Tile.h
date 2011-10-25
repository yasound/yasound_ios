//
//  Tile.h
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/24/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebImageView;

@interface Tile : UIButton
{
  //WebImageView* image;
  UILabel* title;
  UILabel* caption;

  NSURLConnection *connection;
  NSMutableData* data;
  UIActivityIndicatorView *ai;
}

- (id)initWithFrame:(CGRect)frame andImageURL:(NSURL*)imageUrl;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData* data;
@property (nonatomic, retain) UIActivityIndicatorView *ai;

@end
