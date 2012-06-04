//
//  MessageBroadcastModalViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 16/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MessageBroadcastModalViewController.h"
#import "AudioStreamManager.h"
#import "YasoundAppDelegate.h"
#import "YasoundSessionManager.h"
#import "BundleFileManager.h"
#import "Theme.h"
#import "ActivityAlertView.h"


@interface MessageBroadcastModalViewController ()

@end


@implementation MessageBroadcastModalViewController

@synthesize radio;
@synthesize subscribers;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(Radio*)aRadio subscribers:(NSArray*)subscribers target:(id)target action:(SEL)action
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.radio = aRadio;
        self.subscribers = subscribers;
        
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
    _buttonSend.title = NSLocalizedString(@"MessageBroadcastModalView_send_button_label", nil);
    _itemTitle.title = NSLocalizedString(@"MessageBroadcastModalView_title", nil);

    _label1.text = NSLocalizedString(@"MessageBroadcastModalView_from", nil);
    _label1.text = [NSString stringWithFormat:_label1.text, self.radio.name];
    _label2.text = NSLocalizedString(@"MessageBroadcastModalView_to", nil);
    _label2.text = [NSString stringWithFormat:_label2.text, self.subscribers.count];
    
    // track image
    if (self.radio.picture)
    {        
        NSURL* url = [[YasoundDataProvider main] urlForPicture:self.radio.picture];
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
    
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* message = [_textView.text stringByTrimmingCharactersInSet:space];
    
    if (message.length == 0)
        return;
    
    [ActivityAlertView showWithTitle:nil];

    [[YasoundDataProvider main] broadcastMessage:message fromRadio:self.radio withTarget:self action:@selector(onPostMessageFinished:withInfo:)];
    
}


- (void)onPostMessageFinished:(NSNumber*)finished withInfo:(NSDictionary*)infos
{
    NSLog(@"info %@", infos);
    [ActivityAlertView close];    
}








@end
