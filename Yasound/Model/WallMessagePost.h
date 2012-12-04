//
//  WallMessagePost.h
//  Yasound
//
//  Created by matthieu campion on 1/27/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"
#import "User.h"
#import "YaRadio.h"

@interface WallMessagePost : Model

@property (retain, nonatomic) NSString* type;
@property (retain, nonatomic) NSString* text;
@property (retain, nonatomic) NSNumber* animated_emoticon;
@property (retain, nonatomic) User* user;
@property (retain, nonatomic) YaRadio* radio;

@end

