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



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forSong:(Song*)aSong onRadio:(YasoundRadio*)aRadio target:(id)target action:(SEL)action
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
    
    _label1.text = self.song.name;
    _label2.text = self.song.artist;
    _labelWarning.hidden = YES;
    
    // track image
    if (self.song.cover)
    {        
        NSURL* url = [[YasoundDataProvider main] urlForPicture:self.song.cover];
        [_image setUrl:url];
    }
    else
    {
        // fake image
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy30" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [_image setImage:[sheet image]];
    }

    // format messages
    YasoundRadio* currentRadio = [AudioStreamManager main].currentRadio;
    
    NSString* message = NSLocalizedString(@"ShareModalView_share_message", nil);
    NSString* fullMessage = [NSString stringWithFormat:message, self.song.name, self.song.artist, currentRadio.name];

    //
    self.pictureUrl = [[NSURL alloc] initWithString:[APPDELEGATE getServerUrlWith:@"fr/images/logo.png"]];
    self.fullLink = [[NSURL alloc] initWithString:currentRadio.web_url];
    
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






#pragma mark - TopBarSaveOrCancelDelegate

- (BOOL)topBarCancel
{
    if (_target == nil)
        return NO;
    [_target performSelector:_action];
    return NO;
}

- (BOOL)topBarSave
{
    if (_target == nil)
        return NO;
    
    NSString* title = NSLocalizedString(@"Yasound_share", nil);
    
    DLog(@"Share on facebook.");

    [ActivityAlertView showWithTitle:nil];

    [[YasoundSessionManager main] postMessageForFacebook:_textView.text title:title picture:self.pictureUrl link:fullLink target:self action:@selector(onPostMessageFinished:)];
    
    return NO;
}

- (NSString*)titleForActionButton
{
    return NSLocalizedString(@"Share.Facebook.button", nil);
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
