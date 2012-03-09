//
//  YasoundDataCacheImage.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 09/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YasoundDataCacheImageTarget : NSObject
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;
@end


@interface YasoundDataCacheImage : NSObject

@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic) BOOL timeout;
@property (nonatomic, retain) UIImage* image;

@property (nonatomic, retain) NSMutableArray* targets;

@property (nonatomic, retain) NSMutableData* receivedData;


- (id)initWithUrl:(NSURL*)url;
- (void)start;

- (void)addTarget:(id)target action:(SEL)action;
- (void)removeTarget:(id)target;


@end
