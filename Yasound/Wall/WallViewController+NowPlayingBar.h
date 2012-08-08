//
//  WallViewController+NowPlayingBar.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallViewController.h"



@interface WallViewController (NowPlayingBar)


- (void)setNowPlaying:(NSString*)title artist:(NSString*)artist image:(UIImage*)image nbLikes:(NSInteger)nbLikes nbDislikes:(NSInteger)nbDislikes;

- (IBAction)onPlayPauseClicked:(id)sender;
- (IBAction)onShareClicked:(id)sender;
- (IBAction)onLikeClicked:(id)sender;
- (IBAction)onBuyClicked:(id)sender;
@end
