//
//  TwitterSharePreferences.m
//  Yasound
//
//  Created by matthieu campion on 6/28/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TwitterSharePreferences.h"

@implementation TwitterSharePreferences

@synthesize tw_share_listen;
@synthesize tw_share_like_song;
@synthesize tw_share_post_message;
@synthesize tw_share_animator_activity;

- (BOOL)isListenEnabled
{
    return [self.tw_share_listen boolValue];
}

- (BOOL)isKLikeSongEnabled
{
    return [self.tw_share_like_song boolValue];
}

- (BOOL)isPostMessageEnabled
{
    return [self.tw_share_post_message boolValue];
}

- (BOOL)isAnimatorActivityEnabled
{
    return [self.tw_share_animator_activity boolValue];
}

- (void)enableListen:(BOOL)enabled
{
    self.tw_share_listen = [NSNumber numberWithBool:enabled];
}

- (void)enableLikeSong:(BOOL)enabled
{
    self.tw_share_like_song = [NSNumber numberWithBool:enabled];
}

- (void)enablePostMessage:(BOOL)enabled
{
    self.tw_share_post_message = [NSNumber numberWithBool:enabled];
}

- (void)enableAnimatorActivity:(BOOL)enabled
{
    self.tw_share_animator_activity = [NSNumber numberWithBool:enabled];
}


@end
