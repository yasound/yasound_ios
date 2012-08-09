//
//  WallViewController+NowPlayingBar.h
//  Yasound
//
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "WallViewController+NowPlayingBar.h"
#import "YasoundDataProvider.h"
#import "YasoundSessionManager.h"
#import "ShareModalViewController.h"
#import "ShareTwitterModalViewController.h"
#import "AudioStreamManager.h"


@implementation WallViewController (NowPlayingBar)


static Song* _gNowPlayingSong = nil;


- (void)setNowPlaying:(Song*)song
{
    assert(song != nil);
    
    if (_gNowPlayingSong && ([_gNowPlayingSong.id isEqualToNumber:song.id]))
        return;
    
    if (_gNowPlayingSong != nil)
        [_gNowPlayingSong release];
    
    _gNowPlayingSong = song;
    [_gNowPlayingSong retain];
    

    NSURL* url = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
    [self.nowPlayingTrackImage setUrl:url];
    
    self.nowPlayingLabel1.text = song.artist;
    self.nowPlayingLabel2.text = song.name;
    
}

- (void)setPause:(BOOL)set
{
    if (set)
        [self.nowPlayingButton setImage:[UIImage imageNamed:@"nowPlayingPlay.png"] forState:UIControlStateNormal];
    else
        [self.nowPlayingButton setImage:[UIImage imageNamed:@"nowPlayingPause.png"] forState:UIControlStateNormal];
}



//- (IBAction)onTrackImageTouchDown:(id)sender
//{
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.NowPlaying.Wall.NowPlaying.NowPlayingBarMaskHighlighted" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    [_playingNowView.trackImageMask setImage:[sheet image]];
//}
//
//
//- (IBAction)onTrackImageClicked:(id)sender
//{
//    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.NowPlaying.NowPlayingBarMask" retainStylesheet:YES overwriteStylesheet:NO error:nil];
//    [_playingNowView.trackImageMask setImage:[sheet image]];
//    
//    if (_gNowPlayingSong.isSongRemoved)
//        return;
//    
//    if (self.ownRadio)
//    {
//        SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:_gNowPlayingSong showNowPlaying:NO];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//    else
//    {
//        SongPublicInfoViewController* view = [[SongPublicInfoViewController alloc] initWithNibName:@"SongPublicInfoViewController" bundle:nil song:_gNowPlayingSong onRadio:self.radio showNowPlaying:NO];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//    
//}




- (IBAction)onPlayPauseClicked:(id)sender
{
    [[AudioStreamManager main] togglePlayPauseRadio];
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





- (void)onTrackShare:(id)sender
{
    _queryShare = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:NSLocalizedString(@"SettingsView_saveOrCancel_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
        [_queryShare addButtonWithTitle:@"Facebook"];
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
        [_queryShare addButtonWithTitle:@"Twitter"];
    
    [_queryShare addButtonWithTitle:NSLocalizedString(@"ShareModalView_email_label", nil)];
    
    _queryShare.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [_queryShare showInView:self.view];
    
}


#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    // share query result
    if (actionSheet == _queryShare)
    {
        NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([buttonTitle isEqualToString:@"Facebook"])
        {
            ShareModalViewController* view = [[ShareModalViewController alloc] initWithNibName:@"ShareModalViewController" bundle:nil forSong:_gNowPlayingSong onRadio:self.radio target:self action:@selector(onShareModalReturned)];
            [self.navigationController presentModalViewController:view animated:YES];
            [view release];
        }
        else if ([buttonTitle isEqualToString:@"Twitter"])
            
        {
            ShareTwitterModalViewController* view = [[ShareTwitterModalViewController alloc] initWithNibName:@"ShareTwitterModalViewController" bundle:nil forSong:_gNowPlayingSong onRadio:self.radio target:self action:@selector(onShareModalReturned)];
            [self.navigationController presentModalViewController:view animated:YES];
            [view release];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"ShareModalView_email_label", nil)])
        {
            [self shareWithMail];
        }
        
        return;
    }
}



- (void)onShareModalReturned
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}




- (void)shareWithMail
{
    NSString* message = NSLocalizedString(@"ShareModalView_share_message", nil);
    NSString* fullMessage = [NSString stringWithFormat:message, _gNowPlayingSong.name, _gNowPlayingSong.artist, self.radio.name];
    NSString* fullLink = [[NSURL alloc] initWithString:self.radio.web_url];
    
    NSString* body = [NSString stringWithFormat:@"%@\n\n%@", fullMessage, [fullLink absoluteString]];
    
	MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setSubject: NSLocalizedString(@"Yasound_share", nil)];
    
    [mailViewController setMessageBody:body isHTML:NO];
    
	mailViewController.mailComposeDelegate = self;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
		mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
	}
#endif
	
	[self presentModalViewController:mailViewController animated:YES];
	[mailViewController release];
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
	
	NSString *mailError = nil;
	
	switch (result)
    {
		case MFMailComposeResultSent:
        {
            [[YasoundDataProvider main] radioHasBeenShared:self.radio with:@"email"];
            break;
        }
		case MFMailComposeResultFailed: mailError = @"Failed sending media, please try again...";
			break;
		default:
			break;
	}
}







@end