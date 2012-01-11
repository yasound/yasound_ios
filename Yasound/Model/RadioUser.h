//
//  RadioUser.h
//  Yasound
//
//  Created by matthieu campion on 1/9/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"
#import "Radio.h"
#import "User.h"

@interface RadioUser : Model

@property (retain) Radio* radio;
@property (retain) User* user;
@property (retain) NSString* mood;
@property (retain) NSNumber* favorite;
@property (retain) NSNumber* connected;
@property (retain) NSNumber* radio_selected;

- (UserMood)userMood;
- (void)setUserMood:(UserMood)m;


@end
