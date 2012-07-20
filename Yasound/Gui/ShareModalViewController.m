//
//  ShareModalViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ShareModalViewController.h"
#import "AudioStreamManager.h"
#import "YasoundAppDelegate.h"
#import "YasoundSessionManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "ActivityAlertView.h"


@interface ShareModalViewController ()

@end


@implementation ShareModalViewController

@synthesize song;
@synthesize radio;
@synthesize fullLink;
@synthesize pictureUrl;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forSong:(Song*)aSong onRadio:(Radio*)aRadio target:(id)target action:(SEL)action
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.song = aSong;
        self.radio = aRadio;
        
        _target = target;
        _action = action;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // GUI
    _buttonCancel.title = NSLocalizedString(@"Navigation_cancel", nil);
    _buttonSend.title = NSLocalizedString(@"ShareModalView_publish_button_label", nil);
    _itemTitle.title = NSLocalizedString(@"ShareModalView_facebook_label", nil);

    _songTitle.text = self.song.name;
    _songArtist.text = self.song.artist;
    
    // track image
    if (self.song.cover)
    {        
        NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.cover];
        [_image setUrl:url];
    }
    else
    {
        // fake image
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.NowPlaying.Wall.NowPlaying.NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [_image setImage:[sheet image]];
    }

    //mask
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Wall.Header.HeaderAvatarMask" error:nil];
    [_mask setImage:[sheet image]];


    // format messages
    Radio* currentRadio = [AudioStreamManager main].currentRadio;
    
    NSString* message = NSLocalizedString(@"ShareModalView_share_message", nil);
    NSString* fullMessage = [NSString stringWithFormat:message, self.song.name, self.song.artist, currentRadio.name];

    //
    self.pictureUrl = [[NSURL alloc] initWithString:[APPDELEGATE getServerUrlWith:@"fr/images/logo.png"]];
    self.fullLink = [[NSURL alloc] initWithString:currentRadio.web_url];
    
    //
    //NSString* twitterFullMessage = [NSString stringWithFormat:@"#yasound %@ %@ ", [fullLink absoluteString], facebookFullMessage];
    //
    //NSString* emailFullMessage = facebookFullMessage;

    
    // message objects input
    _textView.text = fullMessage;
    
    [_textView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}






#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    if (_target == nil)
        return;
    
    [_target performSelector:_action];
}


- (IBAction)onPublishButton:(id)sender
{
    if (_target == nil)
        return;
    
    NSString* title = NSLocalizedString(@"Yasound_share", nil);
    
    DLog(@"Share on facebook.");
    [[YasoundSessionManager main] postMessageForFacebook:_textView.text title:title picture:self.pictureUrl link:fullLink target:self action:@selector(onPostMessageFinished:)];
    
    [ActivityAlertView showWithTitle:nil];
}


- (void)onPostMessageFinished:(NSNumber*)finished
{
    BOOL done = [finished boolValue];

    [ActivityAlertView close];

    DLog(@"onPostMessageFinished received : finished %d", done);

    if (!done)
    {
        UIAlertView *av;
        
            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RadioView_track_share_error_title", nil) message:NSLocalizedString(@"RadioView_track_share_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
        [av release];  
        return;    
    }
    
    [[YasoundDataProvider main] radioHasBeenShared:self.radio with:@"facebook"];
    
    [_target performSelector:_action];
}








@end
