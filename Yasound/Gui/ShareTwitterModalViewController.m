//
//  ShareTwitterModalViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "ShareTwitterModalViewController.h"
#import "AudioStreamManager.h"
#import "YasoundAppDelegate.h"
#import "YasoundSessionManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "BitlyURLShortener.h"
#import "TwitterOAuthSessionManager.h"
#import "BitlyConfig.h"
#import "MKBitlyHelper.h"

#define TWITTER_MAX_LENGTH 140

#define BITLY_LOGIN @"yasound"
#define BITLY_API_KEY @"R_5fd1c02c9266ba849d69ac0a91709c70"


@interface ShareTwitterModalViewController ()

@end


@implementation ShareTwitterModalViewController

@synthesize song;
@synthesize fullLink;
@synthesize pictureUrl;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forSong:(Song*)aSong target:(id)target action:(SEL)action
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.song = aSong;
        
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
    _itemTitle.title = NSLocalizedString(@"ShareModalView_twitter_label", nil);

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
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"NowPlayingBarImageDummy" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [_image setImage:[sheet image]];
    }

    //mask
    BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"HeaderAvatarMask" error:nil];
    [_mask setImage:[sheet image]];

    [_textView becomeFirstResponder];
    

    // shorten url
    Radio* currentRadio = [AudioStreamManager main].currentRadio;
    
    NSString* link = [APPDELEGATE getServerUrlWith:@"listen/%@"];
    self.fullLink = [[NSURL alloc] initWithString:[NSString stringWithFormat:link, currentRadio.uuid]];

    MKBitlyHelper* bitlyHelper = [[MKBitlyHelper alloc] initWithLoginName:BITLY_LOGIN andAPIKey:BITLY_API_KEY];
    self.fullLink = [bitlyHelper shortenURL:[self.fullLink absoluteString]];
    
    [self fillView];
    
////    // set bit.ly API key
//    [[BitlyConfig sharedBitlyConfig] setBitlyLogin:BITLY_LOGIN bitlyAPIKey:BITLY_API_KEY];
////    [[BitlyConfig sharedBitlyConfig] setTwitterOAuthConsumerKey:[TwitterOAuthSessionManager oauthConsumerKeyForYasound] twitterOAuthConsumerSecret:[TwitterOAuthSessionManager oauthConsumerSecretForYasound] twitterOAuthSuccessCallbackURL:@"https://yasound.com"];    
//    
//    BitlyURLShortener* bitly = [[BitlyURLShortener alloc] init];
//    bitly.delegate = self;
//    [bitly shortenURL:[self.fullLink absoluteString]];
    
}


//- (void)bitlyURLShortenerDidShortenURL:(BitlyURLShortener *)shortener longURL:(NSURL *)longURL shortURLString:(NSString *)shortURLString
//{
//    self.fullLink = [[NSURL alloc] initWithString:shortURLString];
//    [self fillView];
//}
//
//
//- (void)bitlyURLShortener:(BitlyURLShortener *)shortener didFailForLongURL:(NSURL *)longURL statusCode:(NSInteger)statusCode statusText:(NSString *)statusText 
//{
//    NSLog(@"Shortening failed for link %@: status code: %d, status text: %@", [longURL absoluteString], statusCode, statusText);
//    [self fillView];
//}


- (void)fillView
{
    // format messages
    Radio* currentRadio = [AudioStreamManager main].currentRadio;

    NSString* message = NSLocalizedString(@"ShareModalView_share_message", nil);
    NSString* fullMessage = [NSString stringWithFormat:message, self.song.name, self.song.artist, currentRadio.name];

    //
    self.pictureUrl = [[NSURL alloc] initWithString:[APPDELEGATE getServerUrlWith:@"fr/images/logo.png"]];

    NSString* twitterFullMessage = [NSString stringWithFormat:@"#yasound %@ %@ ", self.fullLink, fullMessage];


    // message objects input
    _textView.text = twitterFullMessage;    
    [self textViewDidChange:_textView];

    
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
    
    NSLog(@"Share on twitter.");
    [[YasoundSessionManager main] postMessageForTwitter:_textView.text title:title picture:self.pictureUrl target:self action:@selector(onPostMessageFinished:)];
}


- (void)onPostMessageFinished:(NSNumber*)finished
{
    BOOL done = [finished boolValue];

    NSLog(@"onPostMessageFinished received : finished %d", done);

    if (!done)
    {
        UIAlertView *av;
        
            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RadioView_track_share_error_title", nil) message:NSLocalizedString(@"RadioView_track_share_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
        [av release];  
        return;    
    }
    
    [_target performSelector:_action];
}



#pragma mark - TextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger length = _textView.text.length;
    
    NSString* text = NSLocalizedString(@"ShareModalView_char_count", nil);
    _statusLabel1.text = [NSString stringWithFormat:text, length];
    
    if (length > TWITTER_MAX_LENGTH)
        _statusLabel2.text = NSLocalizedString(@"ShareModalView_twitter_constraint", nil);
    else
        _statusLabel2.text = @"";
}






@end
