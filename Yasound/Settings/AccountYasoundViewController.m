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
    
    _titleItem.title = @"Yasound";
    _backItem.title = NSLocalizedString(@"Navigation_back", nil);    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    _email.placeholder = NSLocalizedString(@"YasoundLoginView_email", nil);
    _pword.placeholder = NSLocalizedString(@"YasoundLoginView_password", nil);
    
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
        
        _email.textColor = [UIColor darkGrayColor];
        _email.backgroundColor = [UIColor lightGrayColor];
        _pword.textColor = [UIColor darkGrayColor];
        _pword.backgroundColor = [UIColor lightGrayColor];
        
        NSDictionary* account = [[YasoundSessionManager main] accountManagerGet:LOGIN_TYPE_YASOUND];
        _email.text = [account objectForKey:@"email"];
        _pword.text = [account objectForKey:@"pword"];
        
        _logoutLabel.text = NSLocalizedString(@"AccountsView_logout_label", nil);

        [_logoutButton setImage:@"BigActionRedButton.png" forState:UIControlStateNormal];
        [_logoutButton setImage:@"BigActionRedButtonHighlighted.png" forState:UIControlStateHighlighted];
        [_logoutButton setImage:@"BigActionButtonDisabled.png" forState:UIControlStateDisabled];

        // disable the button if you want to prevent the user to disconnect from the only one associated account
        if ([[YasoundSessionManager main] accountManagerNumberOfAccounts] == 1)
            _logoutButton.enabled = NO;
        
        
    }
    else
    {
        _email.enabled = YES;
        _pword.enabled = YES;
        
        _email.textColor = [UIColor blackColor];
        _email.backgroundColor = [UIColor whiteColor];
        _pword.textColor = [UIColor blackColor];
        _pword.backgroundColor = [UIColor whiteColor];

        _logoutLabel.text = NSLocalizedString(@"AccountsView_login_label", nil);    
        
        [_logoutButton setImage:@"BigActionGreenButton.png" forState:UIControlStateNormal];
        [_logoutButton setImage:@"BigActionGreenButtonHighlighted.png" forState:UIControlStateHighlighted];
        [_logoutButton setImage:@"BigActionButtonDisabled.png" forState:UIControlStateDisabled];
        
    }
}





#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _email)
    {
        [_pword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];    
        
        // activate "submit" button
        NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString* email = [_email.text stringByTrimmingCharactersInSet:space];
        NSString* pword = [_pword.text stringByTrimmingCharactersInSet:space];
        //        if ((email.length != 0) && (pword.length != 0))
        //            _loginButton.enabled = YES;
        //        else
        //            _loginButton.enabled = NO;
        
    }
    return YES;
}







#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onButtonClicked:(id)sender
{
    // logout
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_YASOUND])
    {
        [[YasoundSessionManager main] dissociateAccount:LOGIN_TYPE_YASOUND target:self action:@selector(dissociateReturned:)];
    }
    
    // login
    else
    {
        NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString* email = [_email.text stringByTrimmingCharactersInSet:space];
        NSString* pword = [_pword.text stringByTrimmingCharactersInSet:space];
        
        if (![RegExp emailIsValid:email])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginView_alert_title", nil) message:NSLocalizedString(@"LoginView_alert_email_not_valid", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [av release];  
            return;    
        }

        
        [[YasoundSessionManager main] associateAccountYasound:email pword:pword target:self action:@selector(associateReturned:)];
        
        // show a connection alert
        [self.view addSubview:[ConnectionView startWithFrame:CGRectMake(86,340, 138, 90)]];
    }
    
}



- (void)associateReturned:(NSDictionary*)info
{
    NSLog(@"associateReturned :%@", info);

    // close the connection alert
    [ConnectionView stop];
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    succeeded = [nb boolValue];

    if (!succeeded)
    {
        NSString* title =  NSLocalizedString(@"AccountsView_alert_title", nil);
        title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Yasound"];
        
        NSString* message = [info objectForKey:@"response"];
        if (message == nil)
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



- (void)dissociateReturned:(NSDictionary*)info
{
    NSLog(@"dissociateReturned :%@", info);
    
    // close the connection alert
    [ConnectionView stop];
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
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







@end
