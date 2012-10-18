//
//  AccountYasoundViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 30/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "AccountYasoundViewController.h"
#import "YasoundSessionManager.h"
#import "AudioStreamManager.h"
#import "ConnectionView.h"
#import "RegExp.h"
#import "ActivityAlertView.h"
#import "RootViewController.h"

@interface AccountYasoundViewController ()

@end

@implementation AccountYasoundViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _email.placeholder = NSLocalizedString(@"YasoundLoginView_email", nil);
    _pword.placeholder = NSLocalizedString(@"YasoundLoginView_password", nil);
    _pwordConfirm.placeholder = NSLocalizedString(@"YasoundLoginView_passwordConfirm", nil);
    
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
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_YASOUND])
    {
        _email.enabled = NO;
        _pword.enabled = NO;
        _pwordConfirm.enabled = NO;
        
        _email.textColor = [UIColor darkGrayColor];
        _email.backgroundColor = [UIColor lightGrayColor];
        _pword.textColor = [UIColor darkGrayColor];
        _pword.backgroundColor = [UIColor lightGrayColor];
        _pwordConfirm.textColor = [UIColor darkGrayColor];
        _pwordConfirm.backgroundColor = [UIColor lightGrayColor];
        
        _email.text = [YasoundDataProvider main].user.yasound_email;
        _pword.text = @"-";
        _pwordConfirm.text = @"-";
        
        _logoutLabel.text = NSLocalizedString(@"AccountsView_logout_label", nil);
        
        _logoutLabel.hidden = NO;
        _logoutButton.hidden = NO;
        _loginLabel.hidden = YES;
        _loginButton.hidden = YES;

        // disable the button if you want to prevent the user to disconnect from the only one associated account
        if ([[YasoundSessionManager main] numberOfAssociatedAccounts] == 1)
            _logoutButton.enabled = NO;
        
        
    }
    else
    {
        _email.enabled = YES;
        _pword.enabled = YES;
        _pwordConfirm.enabled = YES;
        
        _email.textColor = [UIColor blackColor];
        _email.backgroundColor = [UIColor whiteColor];
        _email.text = @"";
        _pword.textColor = [UIColor blackColor];
        _pword.backgroundColor = [UIColor whiteColor];
        _pword.text = @"";
        _pwordConfirm.textColor = [UIColor blackColor];
        _pwordConfirm.backgroundColor = [UIColor whiteColor];
        _pwordConfirm.text = @"";

        _loginLabel.text = NSLocalizedString(@"AccountsView_login_label", nil);    
        
        _loginLabel.hidden = NO;
        _loginButton.hidden = NO;
        _logoutLabel.hidden = YES;
        _logoutButton.hidden = YES;
        
    }
}





#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _email)
    {
        [_pword becomeFirstResponder];
    }
    else if (textField == _pword)
    {
        [_pwordConfirm becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];    
        
        // activate "submit" button
        NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString* email = [_email.text stringByTrimmingCharactersInSet:space];
        NSString* pword = [_pword.text stringByTrimmingCharactersInSet:space];
        NSString* pwordConfirm = [_pwordConfirm.text stringByTrimmingCharactersInSet:space];
        
    }
    return YES;
}







#pragma mark - IBActions



- (IBAction)onButtonClicked:(id)sender
{
    // logout
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_YASOUND])
    {
        [[YasoundSessionManager main] dissociateAccount:LOGIN_TYPE_YASOUND target:self action:@selector(dissociateReturned:info:)];
    }
    
    // login
    else
    {
        NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString* email = [_email.text stringByTrimmingCharactersInSet:space];
        NSString* pword = [_pword.text stringByTrimmingCharactersInSet:space];
        NSString* pwordConfirm = [_pwordConfirm.text stringByTrimmingCharactersInSet:space];
        
        if (![RegExp emailIsValid:email])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginView_alert_title", nil) message:NSLocalizedString(@"LoginView_alert_email_not_valid", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [av release];  
            return;    
        }
        
        if (![pword isEqualToString:pwordConfirm])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginView_alert_title", nil) message:NSLocalizedString(@"LoginView_alert_pword_dont_match", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [av release];  
            return;            
        }
        
        [[YasoundSessionManager main] associateAccountYasound:email password:pword target:self action:@selector(associateReturned:info:) automatic:NO];
        
        // show a connection alert
        [self.view addSubview:[ConnectionView startWithFrame:self.view.frame target:self timeout:@selector(onConnectionTimeout)]];
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
        title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Yasound"];
        
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
    title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Yasound"];
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
        title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Yasound"];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"AccountsView_alert_logout_error", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;    
    }
    
    
    // success
    NSString* title =  NSLocalizedString(@"AccountsView_alert_logout_success", nil);
    title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Yasound"];
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
    return NSLocalizedString(@"Account.yasound", nil);
}






@end
