//
//  Radio.h
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"

@interface Radio : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* creator;
@property (retain, nonatomic) NSString* description;
@property (retain, nonatomic) NSString* genre;
@property (retain, nonatomic) NSString* theme;
@property (retain, nonatomic) NSString* url;
@property (retain, nonatomic) NSArray* playlists;

- (NSString*)toString;

@end