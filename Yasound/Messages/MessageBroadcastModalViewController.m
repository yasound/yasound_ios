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



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRadio:(YaRadio*)aRadio subscribers:(NSArray*)subscribers target:(id)target action:(SEL)action
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
    
    _label1.text = NSLocalizedString(@"MessageBroadcast.from", nil);
    _label1.text = [NSString stringWithFormat:_label1.text, self.radio.name];
    _label2.text = NSLocalizedString(@"MessageBroadcast.to", nil);
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
        BundleStylesheet* sheet = [[Theme theme] stylesheetForKey:@"Programming.cellImageDummy30" retainStylesheet:YES overwriteStylesheet:NO error:nil];
        [_image setImage:[sheet image]];
    }

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


- (BOOL)topBarSave
{
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* message = [_textView.text stringByTrimmingCharactersInSet:space];
    
    if (message.length == 0)
        return NO;
    
    [ActivityAlertView showWithTitle:nil];
    
    [[YasoundDataProvider main] broadcastMessage:message fromRadio:self.radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"broadcast message error: %d - %@", error.code, error. domain);
        }
        if (status != 200)
        {
            DLog(@"broadcast message error: response status %d", status);
        }
        
        [ActivityAlertView close];
        if (_target == nil)
            return;
        
        [_target performSelector:_action];
    }];
    
    return NO;
}


- (BOOL)topBarCancel
{
    [_target performSelector:_action];
    return NO;
}

- (NSString*)titleForActionButton
{
    return NSLocalizedString(@"MessageBroadcast.action.button.label", nil);
}

//- (UIColor*)tintForActionButton;




@end
