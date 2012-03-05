//
//  LeaderBoardEntry.m
//  Yasound
//
//  Created by matthieu campion on 2/2/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "LeaderBoardEntry.h"

@implementation LeaderBoardEntry

@synthesize name;
@synthesize leaderboard_favorites;
@synthesize leaderboard_rank;
@synthesize mine;

- (BOOL)isUserRadio
{
  return [mine boolValue];
}

@end
