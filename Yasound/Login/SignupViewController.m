//
//  SignupViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SignupViewController.h"
#import "YasoundSessionManager.h"
#import "YasoundReachability.h"
#import "RootViewController.h"
#import "ActivityAlertView.h"
#import "ConnectionView.h"
#import "SongUploadManager.h"
#import "CreateMyRadio.h"
#import "RegExp.h"
#import "YasoundDataCache.h"


@implementation SignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        //self.title =  NSLocalizedString(@"LoginView_title", nil);        
    }
    return self;
}


- (void) dealloc
{
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
    
    //    _titleItem.text = NSLocalizedString(@"LoginView_title", nil);
    
    _titleItem.title = NSLocalizedString(@"SignupView_title", nil);
    _backItem.title = NSLocalizedString(@"Navigation_back", nil);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    
    _container.backgroundColor = [UIColor clearColor];
    
    _label.text =  NSLocalizedString(@"SignupView_label", nil);
    
    _username.placeholder = NSLocalizedString(@"SignupView_username", nil);
    _posMin = _container.frame.origin.y;
    _posRef = _username.frame.origin.y;
    
    
    _email.placeholder = NSLocalizedString(@"YasoundLoginView_email", nil);
    _pword.placeholder = NSLocalizedString(@"YasoundLoginView_password", nil);
    _confirmPword.placeholder = NSLocalizedString(@"YasoundLoginView_passwordConfirm", nil);
    
    _submitLabel.text = NSLocalizedString(@"SignupView_submit_button", nil);
    
    _username.delegate = self;
    _email.delegate = self;
    _pword.delegate = self;
    _confirmPword.delegate = self;
    
    UITapGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGestureRecognized)];
    gest.numberOfTapsRequired = 1;
    gest.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:gest];
    
    
//    [_username becomeFirstResponder];
    
    //_signupButton.titleLabel.text = NSLocalizedString(@"LoginView_signup_label", nil);    
}




- (void)viewDidUnload
{
    [super viewDidUnload];
//    _submitButton.enabled = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}






- (void)onTapGestureRecognized
{
    [self.view endEditing:YES];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _container.frame = CGRectMake(_container.frame.origin.x, _posMin, _container.frame.size.width, _container.frame.size.height);
    [UIView commitAnimations];    
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _username)
        [_email becomeFirstResponder];
    
    else if (textField == _email)
        [_pword becomeFirstResponder];
    
    else if (textField == _pword)
        [_confirmPword becomeFirstResponder];
    
    else
    {
        [textField resignFirstResponder];    
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        _container.frame = CGRectMake(_container.frame.origin.x, _posMin, _container.frame.size.width, _container.frame.size.height);
        [UIView commitAnimations];
        
        // activate "submit" button
//        NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
//        NSString* email = [_email.text stringByTrimmingCharactersInSet:space];
//        NSString* pword = [_pword.text stringByTrimmingCharactersInSet:space];
//        if ((email.length != 0) && (pword.length != 0))
//            _submitButton.enabled = YES;
//        else
//            _submitButton.enabled = NO;
        
    }
    return YES;
}



- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = _container.frame;
    
    if (textField == _username)
        frame = CGRectMake(frame.origin.x, _posMin, frame.size.width, frame.size.height);
    
    else if (textField == _email)
        frame = CGRectMake(frame.origin.x, _posMin - (_email.frame.origin.y - _posRef), frame.size.width, frame.size.height);

    else if (textField == _pword)
        frame = CGRectMake(frame.origin.x, _posMin - (_pword.frame.origin.y - _posRef), frame.size.width, frame.size.height);

    else if (textField == _confirmPword)
        frame = CGRectMake(frame.origin.x, _posMin - (_confirmPword.frame.origin.y - _posRef), frame.size.width, frame.size.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _container.frame = frame;
    [UIView commitAnimations];
}


//- (void)textViewDidChangeSelection:(UITextView *)textView
//{
//    if (textView.selectedRange.location != NSNotFound) 
//    {
//        selectRange = textView.selectedRange;
//    }
//}



- (IBAction) onSubmit:(id)sender
{
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    
    NSString* username = [_username.text stringByTrimmingCharactersInSet:space];
    NSString* email = [_email.text stringByTrimmingCharactersInSet:space];
    NSString* pword = [_pword.text stringByTrimmingCharactersInSet:space];
    
    if (![RegExp emailIsValid:email])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginView_alert_title", nil) message:NSLocalizedString(@"LoginView_alert_email_not_valid", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;    
    }
    
    // TAG ACTIVITY ALERT
    [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
    
    NSLog(@"Signup email %@   pword %@   username %@", email, pword, username);
    
    //signup
    [[YasoundDataProvider main] signup:email password:pword username:username target:self action:@selector(requestDidReturn:info:)];

//    // login request to server
//    [[YasoundDataProvider main] login:email password:pword target:self action:@selector(requestDidReturn:info:)];
}

- (void) requestDidReturn:(User*)user info:(NSDictionary*)info
{
    [ActivityAlertView close];
    
    NSLog(@"login returned : %@ %@", user, info);
    
    if (user == nil)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginView_alert_title", nil) message:NSLocalizedString(@"LoginView_alert_message_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;
    }
    
    // store info for automatic login, for the next sessions
    [[YasoundSessionManager main] registerForYasound:_email withPword:_pword];
    
    // get the app menu from the server, before you can proceed
    [[YasoundDataProvider main] menuDescriptionWithTarget:self action:@selector(didReceiveMenuDescription:)];
 
}





// you receive the current menu description from the server
- (void)didReceiveMenuDescription:(ASIHTTPRequest*)req
{
    NSString* menuDesc = req.responseString;
    
    // be sure to store it in the cache
    [[YasoundDataCache main] setMenu:menuDesc];
    
    
    [self enterTheAppAfterProperLogin];
}

- (void)enterTheAppAfterProperLogin
{
   // call root to launch the Radio
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil];
}
















#pragma mark - IBActions



- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}




#pragma mark - YasoundDataProvider

- (void)onGetRadio:(Radio*)radio info:(NSDictionary*)info
{
    //    assert(radio);
    
    // account just being create, go to configuration screen
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"skipRadioCreationSendToSelection"];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
    
    CreateMyRadio* view = [[CreateMyRadio alloc] initWithNibName:@"CreateMyRadio" bundle:nil wizard:YES radio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];    
}



@end
