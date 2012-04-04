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
    
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_YASOUND])
    {
        _email.enabled = NO;
        _pword.enabled = NO;
        _logoutLabel.text = NSLocalizedString(@"AccountsView_logout_label", nil);
    }
    else
    {
        _email.enabled = YES;
        _pword.enabled = YES;

        _logoutLabel.text = NSLocalizedString(@"AccountsView_login_label", nil);    
    }
    
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
        [self.view addSubview:[ConnectionView start]];
    }
    
}



- (void)associateReturned:(NSDictionary*)info
{
    // close the connection alert
    [ConnectionView stop];
    
}


- (void)dissociateReturned:(NSDictionary*)info
{
    // close the connection alert
    [ConnectionView stop];
    
}







@end
