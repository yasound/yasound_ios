//
//  Radio.h
//  Yasound
//
//  Created by matthieu campion on 12/8/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Model.h"
#import "User.h"

@interface Radio : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) User* creator;
@property (retain, nonatomic) NSString* description;
@property (retain, nonatomic) NSString* genre;
@property (retain, nonatomic) NSString* theme;
@property (retain, nonatomic) NSString* url;
@property (retain, nonatomic) NSArray* playlists;
@property (retain, nonatomic) NSNumber* likes;
@property (retain, nonatomic) NSNumber* listeners;
@property (retain, nonatomic) NSString* picture;

- (NSString*)toString;

@end
