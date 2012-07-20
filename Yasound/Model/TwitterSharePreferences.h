//
//  TwitterSharePreferences.h
//  Yasound
//
//  Created by matthieu campion on 6/28/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterSharePreferences : NSObject

@property (retain, nonatomic) NSNumber* tw_share_listen;
@property (retain, nonatomic) NSNumber* tw_share_like_song;
@property (retain, nonatomic) NSNumber* tw_share_post_message;
@property (retain, nonatomic) NSNumber* tw_share_animator_activity;


- (BOOL)isListenEnabled;
- (BOOL)isKLikeSongEnabled;
- (BOOL)isPostMessageEnabled;
- (BOOL)isAnimatorActivityEnabled;

- (void)enableListen:(BOOL)enabled;
- (void)enableLikeSong:(BOOL)enabled;
- (void)enablePostMessage:(BOOL)enabled;
- (void)enableAnimatorActivity:(BOOL)enabled;

@end
