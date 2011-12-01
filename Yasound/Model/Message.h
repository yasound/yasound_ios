//
//  Message.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Message : NSObject

@property (nonatomic) int identifier;
@property (retain, nonatomic) NSString* kind;
@property (retain, nonatomic) NSString* date;
@property (retain, nonatomic) NSString* user;
@property (retain, nonatomic) NSString* message;

@end
