//
//  SongUser.h
//  Yasound
//
//  Created by matthieu campion on 1/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"
#import "Song2.h"
#import "User.h"

@interface SongUser : Model

@property (retain) Song2* song;
@property (retain) User* user;
@property (retain) NSString* mood;

- (UserMood)userMood;
- (void)setUserMood:(UserMood)m;

@end
