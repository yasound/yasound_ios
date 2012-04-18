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

@interface ShareModalViewController ()

@end

#define NB_SECTIONS 2

#define SECTION_PUBLISH 0
#define SECTION_PUBLISH_NB_ROWS 3
#define ROW_PUBLISH_FACEBOOK 0
#define ROW_PUBLISH_TWITTER 1
#define ROW_PUBLISH_BUTTON 2

#define SECTION_EMAIL 1
#define SECTION_EMAIL_NB_ROWS 2
#define ROW_EMAIL_LABEL 0
#define ROW_EMAIL_BUTTON 1



@implementation ShareModalViewController

@synthesize song;
@synthesize artist;
@synthesize fullLink;
@synthesize pictureUrl;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forSong:(NSString*)aSong andArtist:(NSString*)anArtist target:(id)target action:(SEL)action
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.song = aSong;
        self.artist = anArtist;
        
        _target = target;
        _action = action;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // enable sharing
    BOOL enableFacebook = [[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK];
    BOOL enableTwitter = [[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER];
    
    _switchFacebook.enabled = enableFacebook;
    _switchTwitter.enabled = enableTwitter;

    if (!enableFacebook)
    {
        _labelFacebook.textColor = [UIColor grayColor];
    }
    
    if (!enableTwitter)
    {
        _labelTwitter.textColor = [UIColor grayColor];
    }

    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* dico = [defaults objectForKey:@"Sharing"];

    NSNumber* nb = [dico objectForKey:@"facebook"];
    if (enableFacebook && nb)
        enableFacebook = [nb boolValue];
    
    nb = [dico objectForKey:@"twitter"];
    if (enableTwitter && nb)
        enableTwitter = [nb boolValue];
    
    
    

    
    // GUI
    _cancel.title = NSLocalizedString(@"Navigation_cancel", nil);
    
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];

    _labelFacebook.text = NSLocalizedString(@"ShareModalView_facebook_label", nil);
    _labelTwitter.text = NSLocalizedString(@"ShareModalView_twitter_label", nil);
    _labelPublishButton.text = NSLocalizedString(@"ShareModalView_publish_button_label", nil);
    _labelEmail.text = NSLocalizedString(@"ShareModalView_email_label", nil);
    _labelEmailButton.text = NSLocalizedString(@"ShareModalView_email_button_label", nil);

    UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareTextView.png"]];
    [_textFacebook addSubview:background];
    [_textFacebook sendSubviewToBack:background];
    
    background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareTextView.png"]];
    [_textTwitter addSubview:background];
    [_textTwitter sendSubviewToBack:background];
    

    // format messages
    Radio* currentRadio = [AudioStreamManager main].currentRadio;
    
    NSString* message = NSLocalizedString(@"ShareModalView_share_message", nil);
    NSString* facebookFullMessage = [NSString stringWithFormat:message, self.song, self.artist, currentRadio.name];

    //
    self.pictureUrl = [[NSURL alloc] initWithString:[APPDELEGATE getServerUrlWith:@"fr/images/logo.png"]];
    NSString* link = [APPDELEGATE getServerUrlWith:@"listen/%@"];
    self.fullLink = [[NSURL alloc] initWithString:[NSString stringWithFormat:link, currentRadio.uuid]];
    
    //
    NSString* twitterFullMessage = [NSString stringWithFormat:@"#yasound %@ %@ ", [fullLink absoluteString], facebookFullMessage];
    
    //
    NSString* emailFullMessage = facebookFullMessage;

    
    // message objects input
    _textFacebook.text = facebookFullMessage;
    _textTwitter.text = twitterFullMessage;
    _textFacebook.delegate = self;
    _textTwitter.delegate = self;
    
    _switchFacebook.on = enableFacebook;
    _switchTwitter.on = enableTwitter;
    [self onSwitchFacebook:nil];
    [self onSwitchTwitter:nil];
    
    
    // gesture recognizer to close the keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];    
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








#pragma mark - TableView Source and Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NB_SECTIONS;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECTION_PUBLISH)
        return SECTION_PUBLISH_NB_ROWS;
    if (section == SECTION_EMAIL)
        return SECTION_EMAIL_NB_ROWS;
    return 0;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_FACEBOOK))
        return _cellFacebook.frame.size.height;
    
    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_TWITTER))
        return _cellTwitter.frame.size.height;
    
    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_BUTTON))
        return _cellPublishButton.frame.size.height;
    
    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL_LABEL))
        return _cellEmail.frame.size.height;
    
    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL_BUTTON))
        return _cellEmailButton.frame.size.height;
    
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_FACEBOOK))
        return _cellFacebook;

    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_TWITTER))
        return _cellTwitter;

    if ((indexPath.section == SECTION_PUBLISH) && (indexPath.row == ROW_PUBLISH_BUTTON))
        return _cellPublishButton;

    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL_LABEL))
        return _cellEmail;

    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL_BUTTON))
        return _cellEmailButton;
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}







#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    if (_target == nil)
        return;
    
    [_target performSelector:_action];
}

- (IBAction)onSwitchFacebook:(id)sender
{
    if (_switchFacebook.on)
    {
        _textFacebook.editable = YES;
        _textFacebook.textColor = [UIColor colorWithRed:50.f/255.f green:79.f/255.f blue:133.f/255.f alpha:1];
    }
    else 
    {
        _textFacebook.editable = NO;
        _textFacebook.textColor = [UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1];
    }
    
    _buttonPublish.enabled = (_switchFacebook.on || _switchTwitter.on);
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dico = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"Sharing"]];
    [dico setObject:[NSNumber numberWithBool:_switchFacebook.on] forKey:@"facebook"];
    [defaults setObject:dico forKey:@"Sharing"];
    [defaults synchronize];

}

- (IBAction)onSwitchTwitter:(id)sender
{
    if (_switchTwitter.on)
    {
        _textTwitter.editable = YES;
        _textTwitter.textColor = [UIColor colorWithRed:50.f/255.f green:79.f/255.f blue:133.f/255.f alpha:1];
    }
    else 
    {
        _textTwitter.editable = NO;
        _textTwitter.textColor = [UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1];
    }
    
    _buttonPublish.enabled = (_switchFacebook.on || _switchTwitter.on);

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dico = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"Sharing"]];
    [dico setObject:[NSNumber numberWithBool:_switchTwitter.on] forKey:@"twitter"];
    [defaults setObject:dico forKey:@"Sharing"];
    [defaults synchronize];
}


- (IBAction)onPublishButton:(id)sender
{
    if (_target == nil)
        return;
    
    NSString* title = NSLocalizedString(@"Yasound_share", nil);
    
    _nbRequests = 0;
    if (_switchFacebook.on)
        _nbRequests++;
    if (_switchTwitter.on)
        _nbRequests++;

    if (_switchFacebook.on)
    {
        NSLog(@"Share on facebook.");
        [[YasoundSessionManager main] postMessageForFacebook:_textFacebook.text title:title picture:self.pictureUrl link:fullLink target:self action:@selector(onPostMessageFinished:)];
    }

    if (_switchTwitter.on)
    {
        NSLog(@"Share on twitter.");
        [[YasoundSessionManager main] postMessageForTwitter:_textTwitter.text title:title picture:self.pictureUrl target:self action:@selector(onPostMessageFinished:)];
    }
}


- (void)onPostMessageFinished:(NSNumber*)finished
{
    BOOL done = [finished boolValue];

    NSLog(@"onPostMessageFinished received");

    if (!done)
    {
        UIAlertView *av;
        
            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RadioView_track_share_error_title", nil) message:NSLocalizedString(@"RadioView_track_share_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
        [av release];  
        return;    
    }

    _nbRequests--;
    
    if (_nbRequests == 0)
        [_target performSelector:_action];
}

- (IBAction)onEmailButton:(id)sender
{
    NSString* subject = NSLocalizedString(@"Yasound_share", nil);
    
    NSString* url = [[NSString alloc] initWithFormat:@"mailto:?subject=%@&body=%@\n%@", subject, _textFacebook.text, self.fullLink];
    NSString* escaped = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];

    if (_target == nil)
        return;
    
    [_target performSelector:_action];
    
}




-(void)dismissKeyboard 
{
    CGPoint contentOffset = _tableView.contentOffset;
    contentOffset.y = 0; // Adjust this value as you need
    [_tableView setContentOffset:contentOffset animated:YES];
    
    [_textFacebook resignFirstResponder];
    [_textTwitter resignFirstResponder];
}



#pragma mark - TextView Delegate

#define TWITTER_MAX_LENGTH 140

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == _textTwitter)
    {
        CGPoint point = [_textTwitter.superview convertPoint:_labelTwitter.frame.origin toView:_tableView];
        CGPoint contentOffset = _tableView.contentOffset;
        contentOffset.y += point.y; // Adjust this value as you need
        [_tableView setContentOffset:contentOffset animated:YES];
    }
}


- (void)textViewDidChange:(UITextView *)textView
{
    if (_textTwitter)
    {
        if (_textTwitter.text.length > TWITTER_MAX_LENGTH)
        {
            _textTwitter.text = [_textTwitter.text substringToIndex:TWITTER_MAX_LENGTH];
        }
    }
}



@end
