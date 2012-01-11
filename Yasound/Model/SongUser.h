//
//  SongUser.h
//  Yasound
//
//  Created by matthieu campion on 1/11/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"
#import "Song.h"
#import "User.h"

@interface SongUser : Model

@property (retain) Song* song;
@property (retain) User* user;
@property (retain) NSString* mood;

- (UserMood)userMood;
- (void)setUserMood:(UserMood)m;

@end
