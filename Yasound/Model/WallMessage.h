//
//  WallMessage.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallMessage : NSObject

@property (nonatomic) int identifier;
@property (retain, nonatomic) NSString* kind;
@property (retain, nonatomic) NSDate* date;
@property (retain, nonatomic) NSString* user;
@property (retain, nonatomic) NSURL* avatarURL;
@property (retain, nonatomic) NSString* text;
@property (nonatomic) CGFloat textHeight;

@end

