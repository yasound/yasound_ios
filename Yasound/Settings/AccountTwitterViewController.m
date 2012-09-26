//
//  AccountTwitterViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 30/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "AccountTwitterViewController.h"
#import "YasoundSessionManager.h"
#import "AudioStreamManager.h"
#import "ConnectionView.h"
#import "ActivityAlertView.h"
#import "RootViewController.h"

@interface AccountTwitterViewController ()

@end

@implementation AccountTwitterViewController

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
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
    {
//        _usernameLabel.textColor = [UIColor whiteColor];
//        _usernameValue.textColor = [UIColor whiteColor];

        _logoutLabel.text = NSLocalizedString(@"AccountsView_logout_label", nil);
        
        _logoutLabel.hidden = NO;
        _logoutButton.hidden = NO;
        _loginLabel.hidden = YES;
        _loginButton.hidden = YES;

        _usernameValue.text = [YasoundDataProvider main].user.twitter_username;

        // disable the button if you want to prevent the user to disconnect from the only one associated account
        if ([[YasoundSessionManager main] numberOfAssociatedAccounts] == 1)
            _logoutButton.enabled = NO;
    }
    else
    {
//        _usernameLabel.textColor = [UIColor grayColor];
//        _usernameValue.textColor = [UIColor grayColor];

        _loginLabel.text = NSLocalizedString(@"AccountsView_login_label", nil);    
        
        _loginLabel.hidden = NO;
        _loginButton.hidden = NO;
        _logoutLabel.hidden = YES;
        _logoutButton.hidden = YES;
        
        _usernameValue.text = @"-";
    }
}





#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onButtonClicked:(id)sender
{
    // logout
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
    {
        [[YasoundSessionManager main] dissociateAccount:LOGIN_TYPE_TWITTER target:self action:@selector(dissociateReturned:info:)];
    }
    
    // login
    else
    {
        [[YasoundSessionManager main] associateAccountTwitter:self action:@selector(associateReturned:info:) automatic:NO];
        
        // show a connection alert
        [self.view addSubview:[ConnectionView startWithFrame:CGRectMake(86,340, 138, 90)]];
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
        title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Twitter"];
        
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
    title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Twitter"];
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
        title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Twitter"];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"AccountsView_alert_logout_error", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;    
    }
    
    
    // success
    NSString* title =  NSLocalizedString(@"AccountsView_alert_logout_success", nil);
    title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Twitter"];
    [ActivityAlertView showWithTitle:title closeAfterTimeInterval:2];
    
    [self update];
    
}



#pragma mark - TopBarModalDelegate

- (BOOL)shouldShowActionButton {
    return NO;
}


- (NSString*)titleForCancelButton {
    
    return NSLocalizedString(@"Navigation.close", nil);
}


- (NSString*)topBarTitle
{
    return NSLocalizedString(@"Account.twitter", nil);
}






@end
