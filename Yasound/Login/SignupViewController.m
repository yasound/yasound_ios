//
//  SignupViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SignupViewController.h"
#import "SettingsViewController.h"



#define ROW_USERNAME 0
#define ROW_PWORD 1
#define ROW_EMAIL 0



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
    
    _cellUsernameLabel.text = NSLocalizedString(@"SignupView_username_label", nil);
    _cellUsernameTextfield.placeholder = NSLocalizedString(@"SignupView_username_placeholder", nil);
    
    _cellPwordLabel.text = NSLocalizedString(@"SignupView_pword_label", nil);
    _cellPwordTextfield.placeholder = NSLocalizedString(@"SignupView_pword_placeholder", nil);
    
    _cellEmailLabel.text = NSLocalizedString(@"SignupView_email_label", nil);
    _cellEmailTextfield.placeholder = NSLocalizedString(@"SignupView_email_placeholder", nil);

    _submitLabel.text = NSLocalizedString(@"SignupView_submit_label", nil);
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
    [_tableView reloadData];
    
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
    if ((indexPath.section == 0) && (indexPath.row == ROW_USERNAME))
        return _cellUsername;
    
    if ((indexPath.section == 0) && (indexPath.row == ROW_PWORD))
        return _cellPword;

    if ((indexPath.section == 1) && (indexPath.row == ROW_EMAIL))
        return _cellEmail;

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
    else if (textField == _cellPwordTextfield)
    {
        [_cellEmailTextfield becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];    
    }
    return YES;
}





#pragma mark - IBActions


- (IBAction) onSubmit:(id)sender
{

}





@end
