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


#define ROW_USERNAME 0
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
    
    _cellUsernameLabel.text = NSLocalizedString(@"LoginView_username_label", nil);
    _cellUsernameTextfield.placeholder = NSLocalizedString(@"LoginView_username_placeholder", nil);
    
    _cellPwordLabel.text = NSLocalizedString(@"LoginView_pword_label", nil);
    _cellPwordTextfield.placeholder = NSLocalizedString(@"LoginView_pword_placeholder", nil);
    
    _submitLabel.text = NSLocalizedString(@"LoginView_submit_label", nil);
    
    _submitBtn.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
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
    if (indexPath.row == ROW_USERNAME)
        return _cellUsername;
    
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
    if (textField == _cellUsernameTextfield)
    {
        [_cellPwordTextfield becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];    
        
        // activate "submit" button
        NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString* username = [_cellUsernameTextfield.text stringByTrimmingCharactersInSet:space];
        NSString* pword = [_cellPwordTextfield.text stringByTrimmingCharactersInSet:space];
        if ((username.length != 0) && (pword.length != 0))
            _submitBtn.enabled = YES;
        else
            _submitBtn.enabled = NO;

    }
    return YES;
}





#pragma mark - IBActions


- (IBAction) onSubmit:(id)sender
{
    NSCharacterSet* space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString* username = [_cellUsernameTextfield.text stringByTrimmingCharactersInSet:space];
    NSString* pword = [_cellPwordTextfield.text stringByTrimmingCharactersInSet:space];

    // login request to server
  [[YasoundDataProvider main] login:username password:pword target:self action:@selector(loginDidReturn:info:)];
}

- (void) loginDidReturn:(User*)user info:(NSDictionary*)info
{
    NSLog(@"loginDidReturn %@ - %@", user.name, info);
}





@end
