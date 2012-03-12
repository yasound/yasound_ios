//
//  WebImageView.h
//
//  Created by Sébastien Métrot on 10/25/11.
//  modified by Loïc Berthelot on 03/09/12
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WebImageView : UIImageView 

@property (retain, nonatomic) NSURL* url;

-(id) initWithImageFrame:(CGRect)frame;
-(id) initWithImageAtURL:(NSURL*)url;        

- (void)releaseCache;

@end