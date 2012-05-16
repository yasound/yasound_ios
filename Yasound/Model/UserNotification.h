//
//  UserNotification.h
//  Yasound
//
//  Created by matthieu campion on 5/16/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserNotification : NSObject

@property (retain, nonatomic) NSString* _id;
@property (retain, nonatomic) NSString* type;
@property (retain, nonatomic) NSString* text;
@property (retain, nonatomic) NSDate* date;
@property (retain, nonatomic) NSNumber* dest_user_id;
@property (retain, nonatomic) NSNumber* read;
@property (retain, nonatomic) NSDictionary* params;

- (BOOL)isReadBool;
- (void)setReadBool:(BOOL)r;

@end
