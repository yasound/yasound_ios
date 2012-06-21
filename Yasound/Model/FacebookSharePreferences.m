//
//  FacebookSharePreferences.m
//  Yasound
//
//  Created by matthieu campion on 6/20/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "FacebookSharePreferences.h"

@implementation FacebookSharePreferences

@synthesize fb_share_listen;
@synthesize fb_share_like_song;
@synthesize fb_share_post_message;
@synthesize fb_share_animator_activity;

- (BOOL)isListenEnabled
{
    return [self.fb_share_listen boolValue];
}

- (BOOL)isKLikeSongEnabled
{
    return [self.fb_share_like_song boolValue];
}

- (BOOL)isPostMessageEnabled
{
    return [self.fb_share_post_message boolValue];
}

- (BOOL)isAnimatorActivityEnabled
{
    return [self.fb_share_animator_activity boolValue];
}

- (void)enableListen:(BOOL)enabled
{
    self.fb_share_listen = [NSNumber numberWithBool:enabled];
}

- (void)enableLikeSong:(BOOL)enabled
{
    self.fb_share_like_song = [NSNumber numberWithBool:enabled];
}

- (void)enablePostMessage:(BOOL)enabled
{
    self.fb_share_post_message = [NSNumber numberWithBool:enabled];
}

- (void)enableAnimatorActivity:(BOOL)enabled
{
    self.fb_share_animator_activity = [NSNumber numberWithBool:enabled];
}

@end
