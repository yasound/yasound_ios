//
//  Track.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Track : NSObject

@property (nonatomic) int identifier;
@property (retain, nonatomic) NSString* title;
@property (retain, nonatomic) NSString* artist;
@property (nonatomic) NSInteger likes;
@property (nonatomic) NSInteger dislikes;

@end

