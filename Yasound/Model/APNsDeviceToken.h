//
//  APNsDeviceToken.h
//  Yasound
//
//  Created by matthieu campion on 3/29/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"

@interface APNsDeviceToken : Model

@property (retain, nonatomic) NSString* device_token;
@property (retain, nonatomic) NSString* device_token_type;
@property (retain, nonatomic) NSString* uuid;

- (BOOL)isSandbox;
- (void)setSandbox;
- (BOOL)isDevelopment;
- (void)setDevelopment;


@end
