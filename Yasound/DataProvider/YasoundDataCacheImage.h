//
//  YasoundDataCacheImage.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 09/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YasoundDataCacheImage;

@interface YasoundDataCacheImageManager : NSObject
@property (nonatomic, retain) NSMutableArray* fifo;
+ (YasoundDataCacheImageManager*)main;
- (void)addItem:(YasoundDataCacheImage*)item;
- (void)loop;
@end




@interface YasoundDataCacheImageTarget : NSObject
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;
@end




@interface YasoundDataCacheImage : NSObject

@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) NSDate* last_access;
@property (nonatomic, retain) UIImage* image;

@property (nonatomic, retain) NSMutableArray* targets;

@property (nonatomic, retain) NSMutableData* receivedData;

@property (nonatomic) BOOL failed;


- (id)initWithUrl:(NSURL*)url;
- (void)start;

- (void)addTarget:(id)target action:(SEL)action;
- (void)removeTarget:(id)target;


@end
