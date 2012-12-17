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
#import "BuyLinkManager.h"
#import "YasoundAppDelegate.h"
#import "SongInfoViewController.h"
#import "SongPublicInfoViewController.h"

@implementation WallViewController (NowPlayingBar)


static Song* _gNowPlayingSong = nil;


- (void)setNowPlaying:(Song*)song
{
    assert(song != nil);
    
    
    if (_gNowPlayingSong != nil)
        [_gNowPlayingSong release];
    
    _gNowPlayingSong = song;
    [_gNowPlayingSong retain];
    

    NSURL* url = [[YasoundDataProvider main] urlForPicture:song.cover];
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


- (IBAction)onTrackImageClicked:(id)sender
{
    if (_gNowPlayingSong.isSongRemoved)
        return;

    if (self.ownRadio)
    {
        SongInfoViewController* view = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil song:_gNowPlayingSong showNowPlaying:NO forRadio:self.radio];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        SongPublicInfoViewController* view = [[SongPublicInfoViewController alloc] initWithNibName:@"SongPublicInfoViewController" bundle:nil song:_gNowPlayingSong onRadio:self.radio showNowPlaying:NO];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }    
}




- (IBAction)onPlayPauseClicked:(id)sender
{
    [[AudioStreamManager main] togglePlayPauseRadio];
    
    if ([AudioStreamManager main].isPaused)
        [self resignFirstResponder];
}

- (IBAction)onShareClicked:(id)sender
{
    _queryShare = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Share.title", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
        [_queryShare addButtonWithTitle:@"Facebook"];
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
        [_queryShare addButtonWithTitle:@"Twitter"];
    
    if ([MFMailComposeViewController canSendMail])
        [_queryShare addButtonWithTitle:NSLocalizedString(@"Share.email", nil)];
    
    [_queryShare addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    _queryShare.cancelButtonIndex = _queryShare.numberOfButtons-1;
    
    
    _queryShare.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [_queryShare showInView:self.view];    
}



- (IBAction)onLikeClicked:(id)sender
{
    [[YasoundDataProvider main] setMood:eMoodLike forSong:_gNowPlayingSong andRadio:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error != nil)
            DLog(@"like song error: %d - %@", error.code, error.domain);
        else if (status != 200)
            DLog(@"like song error: response status %d", status);
    }];
}



- (NSString *)getUserCountry
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey: NSLocaleCountryCode];
}




- (IBAction)onBuyClicked:(id)sender
{
    BuyLinkManager *mgr = [[BuyLinkManager alloc] init];
    NSString *link = [mgr generateLink:_gNowPlayingSong.artist
                                 album:_gNowPlayingSong.album
                                  song:_gNowPlayingSong.name];
    
    if (!link)
    {
        // let's retry without album
        link = [mgr generateLink:_gNowPlayingSong.artist
                           album:@""
                            song:_gNowPlayingSong.name];
    }
    [mgr release];
    
    if (link)
    {
        NSURL *url = [[NSURL alloc] initWithString:link];
        [[UIApplication sharedApplication] openURL:url];
        [url release];
    }
    else
    {
        UIAlertView *av = nil;
        av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnableToFindSongOniTunes_Title", nil)
                                        message:NSLocalizedString(@"UnableToFindSongOniTunes_Message", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"UnableToFindSongOniTunes_OK", nil)
                              otherButtonTitles:nil];
        
        [av show];
        [av release];
    }
    
    
}





#pragma mark - UIActionSheet Delegate

-(void)shareActionSheetClickedButtonAtIndex:(NSInteger)buttonIndex
{
        NSString* buttonTitle = [_queryShare buttonTitleAtIndex:buttonIndex];
        
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
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"Share.email", nil)])
        {
            [self shareWithMail];
        }
        
}



- (void)onShareModalReturned
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}




- (void)shareWithMail
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertView *av = nil;
        av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot_share_with_mail", nil)
                                        message:NSLocalizedString(@"Cannot_share_with_mail_message", nil)
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [av show];
        [av release];
        return;
    }
        
    NSString* message = NSLocalizedString(@"ShareModalView_share_message", nil);
    NSString* fullMessage = [NSString stringWithFormat:message, _gNowPlayingSong.name, _gNowPlayingSong.artist, self.radio.name];
    NSURL* fullLink = [[NSURL alloc] initWithString:self.radio.web_url];
    
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
	
	[APPDELEGATE.navigationController presentModalViewController:mailViewController animated:YES];
	[mailViewController release];
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
	
	NSString *mailError = nil;
	
	switch (result)
    {
		case MFMailComposeResultSent:
        {
            [[YasoundDataProvider main] radioHasBeenShared:self.radio with:@"email" withCompletionBlock:^(int status, NSString* response, NSError* eror){
                    if (error)
                    {
                        DLog(@"radio share with email error: %d - %@", error.code, error. domain);
                        return;
                    }
                    if (status != 200)
                    {
                        DLog(@"radio share with email error: response status %d", status);
                        return;
                    }
            }];
            
            break;
        }
		case MFMailComposeResultFailed: mailError = @"Failed sending media, please try again...";
			break;
		default:
			break;
	}
}







@end