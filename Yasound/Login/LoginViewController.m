//
//  LoginViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "LoginViewController.h"
#import "RadioViewController.h"
#import "BundleFileManager.h"
#import "SettingsViewController.h"

#import "YasoundDataProvider.h"
#import "ActivityAlertView.h"
#import "RegExp.h"
#import "YasoundSessionManager.h"
#import "RootViewController.h"


#define ROW_EMAIL 0
#define ROW_PWORD 1



@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title =  NSLocalizedString(@"LoginView_title", nil);        
    }
    return self;
}


- (void) dealloc
{
    if (_email)
        [_email release];
    if (_pword)
        [_pword release];
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
    
    _titleLabel.text = NSLocalizedString(@"LoginView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);
    
    _cellEmailLabel.text = NSLocalizedString(@"LoginView_email_label", nil);
    _cellEmailTextfield.placeholder = NSLocalizedString(@"LoginView_email_placeholder", nil);
    
    _cellPwordLabel.text = NSLocalizedString(@"LoginView_pword_label", nil);
    _cellPwordTextfield.placeholder = NSLocalizedString(@"LoginView_pword_placeholder", nil);
    
    [_submitBtn setTitle:NSLocalizedString(@"LoginView_submit_label", nil) forState:UIControlStateNormal];
    
    _submitBtn.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector (keyboardDidShow:)
    //                                                 name: UIKeyboardDidShowNotification object:nil];
    //    
    //    [[NSNotificationCenter defaultCenter] addObserver:self 
    //                                             selector:@selector (keyboardDidHide:)
    //                                                 name: UIKeyboardDidHideNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}








#pragma mark - TableView Source and Delegate





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 2;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == ROW_EMAIL)
        return _cellEmail;
    
    if (indexPath.row == ROW_PWORD)
        return _cellPword;
    
    return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}




#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _cellEmailTextfield)
    {
        [_cellPwordTextfield becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];    
        
        // activate "submit" button
        NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString* email = [_cellEmailTextfield.text stringByTrimmingCharactersInSet:space];
        NSString* pword = [_cellPwordTextfield.text stringByTrimmingCharactersInSet:space];
        if ((email.length != 0) && (pword.length != 0))
            _submitBtn.enabled = YES;
        else
            _submitBtn.enabled = NO;
        
    }
    return YES;
}





#pragma mark - IBActions


- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction) onSubmit:(id)sender
{
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* email = [_cellEmailTextfield.text stringByTrimmingCharactersInSet:space];
    NSString* pword = [_cellPwordTextfield.text stringByTrimmingCharactersInSet:space];
    
    if (![RegExp emailIsValid:email])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginView_alert_title", nil) message:NSLocalizedString(@"LoginView_alert_email_not_valid", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;    
    }
    
    _email = [NSString stringWithString:email];
    _pword = [NSString stringWithString:pword];
    [_email retain];
    [_pword retain];
    
    // TAG ACTIVITY ALERT
    [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
    
    // login request to server
    [[YasoundDataProvider main] login:email password:pword target:self action:@selector(requestDidReturn:info:)];
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
    
    // call root to launch the Radio
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil];
}





@end
