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



#define ROW_EMAIL 0
#define ROW_PWORD 1
#define ROW_USERNAME 0



@implementation SignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title =  NSLocalizedString(@"SignupView_title", nil);   
    }
    return self;
}


- (void) dealloc
{
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

    [_submitBtn setTitle:NSLocalizedString(@"SignupView_submit_label", nil) forState:UIControlStateNormal];
    _submitBtn.enabled = NO;
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
    return 2;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
        return 2;
    return 1;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ((indexPath.section == 0) && (indexPath.row == ROW_EMAIL))
        return _cellEmail;

    if ((indexPath.section == 0) && (indexPath.row == ROW_PWORD))
        return _cellPword;

    if ((indexPath.section == 1) && (indexPath.row == ROW_USERNAME))
        return _cellUsername;
    

    return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
    NSString* username = [_cellUsernameTextfield.text stringByTrimmingCharactersInSet:space];
    
    // login request to server
    [[YasoundDataProvider main] signup:username password:pword email:email target:self action:@selector(requestDidReturn:info:)];
}


- (void) requestDidReturn:(User*)user info:(NSDictionary*)info
{
    NSLog(@"requestDidReturn %@ - %@", user.name, info);
    
    //    [ActivityAlertView showWithTitle:(NSString *)title message:(NSString *)message;
    //    + (void)close;
    //    UIAlertView* 
}






@end
