//
//  YasoundDataCacheImage.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 09/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YasoundDataCacheImage : NSObject

@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) NSDate* timeout;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;

@property (nonatomic, retain) NSMutableData* receivedData;


- (id)initWithUrl:(NSURL*)url;
- (void)update;

@end
