//
//  WallViewController+NowPlayingBar.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallViewController.h"

@class Song;

@interface WallViewController (NowPlayingBar)

- (void)setNowPlaying:(Song*)song;
- (void)setPause:(BOOL)set;


- (IBAction)onTrackImageClicked:(id)sender;

- (IBAction)onPlayPauseClicked:(id)sender;
- (IBAction)onShareClicked:(id)sender;
- (IBAction)onLikeClicked:(id)sender;
- (IBAction)onBuyClicked:(id)sender;

-(void)shareActionSheetClickedButtonAtIndex:(NSInteger)buttonIndex;

@end
