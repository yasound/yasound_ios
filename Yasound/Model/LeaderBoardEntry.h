//
//  LeaderBoardEntry.h
//  Yasound
//
//  Created by matthieu campion on 2/2/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"

@interface LeaderBoardEntry : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSNumber* favorites;
@property (retain, nonatomic) NSNumber* leaderboard_rank;
@property (retain, nonatomic) NSNumber* mine;

- (BOOL)isUserRadio;

@end
