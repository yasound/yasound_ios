//
//  SignupViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SignupViewController.h"
#import "SettingsViewController.h"
#import "YasoundDataProvider.h"
#import "LegalViewController.h"
#import "ActivityAlertView.h"
#import "RegExp.h"

#define SECTION_LOGIN 0
#define ROW_LOGIN_EMAIL 0
#define ROW_LOGIN_PWORD 1

#define SECTION_USERNAME 1
#define ROW_USERNAME 0

#define SECTION_LEGAL 2
#define ROW_LEGAL_READ 0
#define ROW_LEGAL_VALID 1

#define SECTION_SUBMIT 3
#define ROW_SUBMIT 0



@implementation SignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title =  NSLocalizedString(@"SignupView_title", nil); 
        _userValidatedInfo = NO;
        _userValidatedLegal = NO;
        
    }
    return self;
}


- (void) dealloc
{
    [_cellLegalReadLabel release];
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
    
    _titleLabel.text = NSLocalizedString(@"SignupView_title", nil);
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);

    _cellUsernameLabel.text = NSLocalizedString(@"SignupView_username_label", nil);
    _cellUsernameTextfield.placeholder = NSLocalizedString(@"SignupView_username_placeholder", nil);
    
    _cellPwordLabel.text = NSLocalizedString(@"SignupView_pword_label", nil);
    _cellPwordTextfield.placeholder = NSLocalizedString(@"SignupView_pword_placeholder", nil);
    
    _cellEmailLabel.text = NSLocalizedString(@"SignupView_email_label", nil);
    _cellEmailTextfield.placeholder = NSLocalizedString(@"SignupView_email_placeholder", nil);

    _cellLegalReadLabel = NSLocalizedString(@"SignupView_legal_read_label", nil);
    [_cellLegalReadLabel retain];
    _cellLegalValidLabel.text = NSLocalizedString(@"SignupView_legal_valid_label", nil);

    [_submitBtn setTitle:NSLocalizedString(@"SignupView_submit_label", nil) forState:UIControlStateNormal];
    _submitBtn.enabled = NO;
    
    
    //LBDEBUG pour accélerer
    _cellEmailTextfield.text = @"neywen5@neywen.net";
    _cellPwordTextfield.text = @"neywen";
    _cellUsernameTextfield.text = @"neywen";
    _userValidatedInfo = YES;
    _userValidatedLegal = YES;

    
}


- (void)viewDidAppear:(BOOL)animated
{
    [_tableView reloadData];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
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
    return 4;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECTION_LOGIN)
        return 2;
    if (section == SECTION_USERNAME)
        return 1;
    if (section == SECTION_LEGAL)
        return 2;
    if (section == SECTION_SUBMIT)
        return 1;
    
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_SUBMIT) && (indexPath.row == ROW_SUBMIT))
    {
        UIView* view = [[UIView alloc] initWithFrame:cell.frame];
        view.backgroundColor = [UIColor clearColor];
        cell.backgroundView = view;
        [view release];
    }

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == SECTION_LOGIN) && (indexPath.row == ROW_LOGIN_EMAIL))
        return _cellEmail;

    if ((indexPath.section == SECTION_LOGIN) && (indexPath.row == ROW_LOGIN_PWORD))
        return _cellPword;

    if ((indexPath.section == SECTION_USERNAME) && (indexPath.row == ROW_USERNAME))
        return _cellUsername;
    
    if ((indexPath.section == SECTION_LEGAL) && (indexPath.row == ROW_LEGAL_READ))
    {
        static NSString* CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.textLabel.text = _cellLegalReadLabel;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }

    if ((indexPath.section == SECTION_LEGAL) && (indexPath.row == ROW_LEGAL_VALID))
        return _cellLegal;
    
    if ((indexPath.section == SECTION_SUBMIT) && (indexPath.row == ROW_SUBMIT))
        return _cellSubmit;

    return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_LEGAL) && (indexPath.row == ROW_LEGAL_READ))
    {
        LegalViewController* view = [[LegalViewController alloc] initWithNibName:@"LegalViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];    
    }

}




#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _cellUsernameTextfield)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0.0, 0, 0.0);
        [UIView commitAnimations];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _cellEmailTextfield)
    {
        [_cellPwordTextfield becomeFirstResponder];
    }
    else if (textField == _cellPwordTextfield)
    {
        [_cellUsernameTextfield becomeFirstResponder];
    }
    else
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33];
        _tableView.contentInset = UIEdgeInsetsMake(96, 0.0, 0, 0.0);
        [UIView commitAnimations];
        
        [textField resignFirstResponder];    

        // activate "submit" button
        NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString* email = [_cellEmailTextfield.text stringByTrimmingCharactersInSet:space];
        NSString* pword = [_cellPwordTextfield.text stringByTrimmingCharactersInSet:space];
        NSString* username = [_cellUsernameTextfield.text stringByTrimmingCharactersInSet:space];
        if ((username.length != 0) && (pword.length != 0)  && (email.length != 0))
            _userValidatedInfo = YES;
        else
            _userValidatedInfo = NO;
        
        if (_userValidatedInfo && _userValidatedLegal)
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



-(IBAction)onSwitch:(id)sender 
{
    UISwitch* switchControl = sender;
    
    if(switchControl.on)
    {
        _userValidatedLegal = YES;
    }
    else
    {
        _userValidatedLegal = NO;
    }
    
    if (_userValidatedInfo && _userValidatedLegal)
        _submitBtn.enabled = YES;
    else
        _submitBtn.enabled = NO;
    
}



- (IBAction) onSubmit:(id)sender
{
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* email = [_cellEmailTextfield.text stringByTrimmingCharactersInSet:space];
    NSString* pword = [_cellPwordTextfield.text stringByTrimmingCharactersInSet:space];
    NSString* username = [_cellUsernameTextfield.text stringByTrimmingCharactersInSet:space];

    if (![RegExp emailIsValid:email])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SignupView_alert_title", nil) message:NSLocalizedString(@"SignupView_alert_email_not_valid", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;    
    }

    [ActivityAlertView showWithTitle:NSLocalizedString(@"Alert_contact_server", nil)];
    
    NSLog(@"Signup  email '%@'   pword '%@'    username '%@'", email, pword, username);
    
    // login request to server
    [[YasoundDataProvider main] signup:email password:pword username:username target:self action:@selector(requestDidReturn:info:)];
}


- (void) requestDidReturn:(User*)user info:(NSDictionary*)info
{
    [ActivityAlertView close];
    NSLog(@"signup requestDidReturn %@ - %@", user.name, info);
    
    if (user == nil)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SignupView_alert_title", nil) message:NSLocalizedString(@"SignupView_alert_message_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;
    }

    // go to next screen
    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:YES];
    [self.navigationController pushViewController:view animated:YES];
    [view release];    
}

         
         
#pragma mark - UIAlertViewDelegate

 // Called when a button is clicked. The view will be automatically dismissed after this call returns
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
 {
     
 }
         






@end
