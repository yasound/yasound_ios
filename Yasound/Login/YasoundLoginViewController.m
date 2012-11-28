//
//  YasoundLoginViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YasoundLoginViewController.h"
#import "YasoundSessionManager.h"
#import "YasoundReachability.h"
#import "RootViewController.h"
#import "ActivityAlertView.h"
#import "ConnectionView.h"
#import "SongUploadManager.h"
#import "RegExp.h"
#import "SignupViewController.h"
#import "YasoundDataCache.h"
#import "YasoundAppDelegate.h"
#import "LoginViewController.h"

@implementation YasoundLoginViewController



@synthesize container;








- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
    }
    return self;
}


- (void) dealloc
{
    [self.container release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _label.text =  NSLocalizedString(@"YasoundLoginView_label", nil);
    _email.placeholder = NSLocalizedString(@"YasoundLoginView_email", nil);
    _pword.placeholder = NSLocalizedString(@"YasoundLoginView_password", nil);
    
    _email.marginLeft = 12;
    _email.marginRight = 42;
    _pword.marginLeft = 12;
    _pword.marginRight = 42;
    
    _loginLabel.text = NSLocalizedString(@"YasoundLoginView_button_login", nil);

    [_signupButton setTitle:NSLocalizedString(@"LoginView_signup_label", nil) forState:UIControlStateNormal textAlignment:UITextAlignmentLeft];
    [_forgetButton setTitle:NSLocalizedString(@"YasoundLoginView_button_forgot", nil) forState:UIControlStateNormal textAlignment:UITextAlignmentLeft];

}




- (void)viewDidUnload
{
    [super viewDidUnload];
//    _loginButton.enabled = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}









#pragma mark - TextField Delegate


- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.33];
    self.container.frame = CGRectMake(0, -20, self.container.frame.size.width, self.container.frame.size.height);
    [UIView commitAnimations];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _email)
    {
        [_pword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        self.container.frame = CGRectMake(0, 44, self.container.frame.size.width, self.container.frame.size.height);
        [UIView commitAnimations];
        
        
        // activate "submit" button
        NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString* email = [_email.text stringByTrimmingCharactersInSet:space];
        NSString* pword = [_pword.text stringByTrimmingCharactersInSet:space];
    }
    return YES;
}




- (IBAction) onSubmit:(id)sender
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
    
    [self.view addSubview:[ConnectionView startWithTarget:self timeout:@selector(onConnectionTimeout)]];

    [_email resignFirstResponder];    
    [_pword resignFirstResponder];    

    
    // login request to server
    [[YasoundDataProvider main] login:email password:pword target:self action:@selector(requestDidReturn:info:)];
}




- (void)onConnectionTimeout {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CONNECTION_TIMEOUT object:nil];
}


- (void) requestDidReturn:(User*)user info:(NSDictionary*)info
{
//    [ActivityAlertView close];

    // close the connection alert
    [ConnectionView stop];

    [[YasoundSessionManager main] writeUserIdentity:user];
    
    
    DLog(@"login returned : %@ %@", user, info);
    
    
    if (user == nil)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginView_alert_title", nil) message:NSLocalizedString(@"LoginView_alert_message_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  

        return;
    }

    
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* email = [_email.text stringByTrimmingCharactersInSet:space];
    NSString* pword = [_pword.text stringByTrimmingCharactersInSet:space];

    // store info for automatic login, for the next sessions
    [[YasoundSessionManager main] registerForYasound:email withPword:pword];
    
    // login the other associated accounts as well
    [[YasoundSessionManager main] associateAccountsAutomatic];
    
    
    [self enterTheAppAfterProperLogin];

}



- (void)enterTheAppAfterProperLogin
{
    // call root to launch the Radio
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LAUNCH_RADIO object:nil];
}
















#pragma mark - IBActions


- (IBAction)onSignupClicked:(id)sender
{
    SignupViewController* viewC = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [APPDELEGATE.navigationController presentModalViewController:viewC animated:NO];
    [viewC release];
}


- (IBAction)onForgotClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://yasound.com/passreset/"]];
}




#pragma mark - YasoundDataProvider

- (void)onGetRadio:(YasoundRadio*)radio info:(NSDictionary*)info
{
    //    assert(radio);
    
    // account just being create, go to configuration screen
    [[UserSettings main] setBool:YES forKey:USKEYskipRadioCreation];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_SELECTION object:nil];
}


#pragma mark - TopBarBackAndTitleDelegate

- (BOOL)topBarBackClicked {

    LoginViewController* viewC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [APPDELEGATE.navigationController presentModalViewController:viewC animated:NO];
    [viewC release];

    return NO;
}




@end
