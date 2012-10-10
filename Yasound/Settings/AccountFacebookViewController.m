//
//  AccountFacebookViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 30/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "AccountFacebookViewController.h"
#import "YasoundSessionManager.h"
#import "AudioStreamManager.h"
#import "ConnectionView.h"
#import "ActivityAlertView.h"
#import "RootViewController.h"
#import "WebPageViewController.h"
#import "YasoundAppDelegate.h"

@interface AccountFacebookViewController ()

@end

@implementation AccountFacebookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

  _usernameLabel.text = NSLocalizedString(@"AccountsView_username_label", nil);
  _likeLabel.text = NSLocalizedString(@"AccountsView_like_label", nil);

    [self update];
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








- (void)update
{
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
    {
        _usernameLabel.textColor = [UIColor blackColor];
        _usernameValue.textColor = [UIColor colorWithRed:88.f/255.f green:107.f/255.f blue:119.f/255.f alpha:1];
        
        _logoutLabel.text = NSLocalizedString(@"AccountsView_logout_label", nil);
        
        _logoutLabel.hidden = NO;
        _logoutButton.hidden = NO;
        _loginLabel.hidden = YES;
        _loginButton.hidden = YES;
        
        _usernameValue.text = [YasoundDataProvider main].user.facebook_username;
        
        
        // disable the button if you want to prevent the user to disconnect from the only one associated account
        if ([[YasoundSessionManager main] numberOfAssociatedAccounts] == 1)
            _logoutButton.enabled = NO;
    }
    else
    {
        _usernameLabel.textColor = [UIColor blackColor];
        _usernameValue.textColor = [UIColor colorWithRed:88.f/255.f green:107.f/255.f blue:119.f/255.f alpha:1];
        
        _loginLabel.text = NSLocalizedString(@"AccountsView_login_label", nil);    
        
        _loginLabel.hidden = NO;
        _loginButton.hidden = NO;
        _logoutLabel.hidden = YES;
        _logoutButton.hidden = YES;
        
        _usernameValue.text = @"-";
    }
}





#pragma mark - IBActions


- (IBAction)onButtonClicked:(id)sender
{
    // logout
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
    {
        [[YasoundSessionManager main] dissociateAccount:LOGIN_TYPE_FACEBOOK target:self action:@selector(dissociateReturned:info:)];
    }
    
    // login
    else
    {
        [[YasoundSessionManager main] associateAccountFacebook:self action:@selector(associateReturned:info:) automatic:NO];
        
        // show a connection alert
        [self.view addSubview:[ConnectionView startWithFrame:self.view.frame]];
    }
   
}


- (void)onConnectionTimeout {

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CONNECTION_TIMEOUT object:nil];
}


- (void)associateReturned:(User*)user info:(NSDictionary*)info
{
    DLog(@"associateReturned :%@", info);
    
    // close the connection alert
    [ConnectionView stop];
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    
    if (nb == nil)
    {
        NSDictionary* userData = [info objectForKey:@"userData"];
        nb = [userData objectForKey:@"succeeded"];
    }
    
    succeeded = [nb boolValue];
    
    if (!succeeded)
    {
        NSString* title =  NSLocalizedString(@"AccountsView_alert_title", nil);
        title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Facebook"];

        
        NSDictionary* userData = [info objectForKey:@"userData"];
        NSInteger statusCode = [[userData objectForKey:@"responseStatusCode"] intValue];
        
        NSString* message = nil;
        if (statusCode == 400)
            message = [info objectForKey:@"response"];
        else
            message = NSLocalizedString(@"AccountsView_alert_user_incorrect", nil);
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;    
    }
    
    
    // success
    NSString* title =  NSLocalizedString(@"AccountsView_alert_login_success", nil);
    title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Facebook"];
    [ActivityAlertView showWithTitle:title closeAfterTimeInterval:2];
    
    [self update];
    
}



- (void)dissociateReturned:(User*)user info:(NSDictionary*)info
{
    DLog(@"dissociateReturned :%@", info);
    
    // close the connection alert
    [ConnectionView stop];
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    
    if (nb == nil)
    {
        NSDictionary* userData = [info objectForKey:@"userData"];
        nb = [userData objectForKey:@"succeeded"];
    }

    succeeded = [nb boolValue];
    
    if (!succeeded)
    {
        NSString* title =  NSLocalizedString(@"AccountsView_alert_title", nil);
        title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Facebook"];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"AccountsView_alert_logout_error", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;    
    }
    
    
    // success
    NSString* title =  NSLocalizedString(@"AccountsView_alert_logout_success", nil);
    title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Facebook"];
    [ActivityAlertView showWithTitle:title closeAfterTimeInterval:2];
    
    [self update];
    
}





#pragma mark - TopBarModalDelegate

- (BOOL)shouldShowActionButton {
    return NO;
}

- (NSString*)topBarTitle
{
    NSString* str = NSLocalizedString(@"Account.facebook", nil);
    return str;
}

- (NSString*)titleForCancelButton {
    
    return NSLocalizedString(@"Navigation.close", nil);
}




@end
