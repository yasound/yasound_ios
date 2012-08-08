//
//  WallViewController+NowPlayingBar.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WallViewController+NowPlayingBar.h"


@implementation WallViewController (NowPlayingBar)




- (void)setNowPlaying:(Song*)song
{
//    assert(song != nil);
//    if (_gNowPlayingSong != nil)
//        [_gNowPlayingSong release];
//    
//    _gNowPlayingSong = song;
//    [_gNowPlayingSong retain];
//    
//    if (_playingNowView != nil)
//    {
//        [_playingNowView removeFromSuperview];
//        [_playingNowView release];
//    }
//    
//    _playingNowView = [[NowPlayingView alloc] initWithSong:_gNowPlayingSong];
//    
//    InteractiveView* trackImageButton = [[InteractiveView alloc] initWithFrame:CGRectMake(15, 6, 50, 50) target:self action:@selector(onTrackImageClicked:)];
//    [trackImageButton setTargetOnTouchDown:self action:@selector(onTrackImageTouchDown:)];
//    [_playingNowView addSubview:trackImageButton];
//    [trackImageButton release];
//    
//    
//    [_playingNowView.trackInteractionView.shareButton addTarget:self action:@selector(onTrackShare:) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.NowPlaying.NowPlayingBar" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    _playingNowView.frame = sheet.frame;
//    
//    [self.view addSubview:_playingNowView];
//    [self.view bringSubviewToFront:self.playPauseButton];
}


- (IBAction)onPlayPauseClicked:(id)sender
{

}

- (IBAction)onShareClicked:(id)sender
{
    
}


- (IBAction)onLikeClicked:(id)sender
{
    
}


- (IBAction)onBuyClicked:(id)sender
{
    
}




@end