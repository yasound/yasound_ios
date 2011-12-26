//
//  LoginViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "LoginViewController.h"
//#import "RadioTabBarController.h"
#import "RadioViewController.h"
#import "BundleFileManager.h"
#import "SettingsViewController.h"



#define SECTION_LOGIN 0
#define ROW_USERNAME 0
#define ROW_PWORD 1

#define SECTION_SUBMIT 1
#define ROW_SUBMIT 0

#define SECTION_SIGNUP 2
#define ROW_SIGNUP 0

#define SECTION_OTHERS 3
#define ROW_FACEBOOK 0
#define ROW_TWITTER 1




@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _keyboardVisible = NO;
        _loginViewVisible = NO;
        _yasoundSignupViewVisible = NO;
        
        self.title = @"Yasound";
        
        _backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigation_back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];        
    }
    return self;
}


- (void) dealloc
{
    [_backBtn release];
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
    [self yasoundSignup_ViewDidLoad];

    _yasoundLoginCellUsernameLabel.text = NSLocalizedString(@"yasoundLogin_Username_label", nil);
    _yasoundLoginCellUsernameTextField.placeholder = NSLocalizedString(@"yasoundLogin_Username_placeholder", nil);
    
    _yasoundLoginCellPwordLabel.text = NSLocalizedString(@"yasoundLogin_Pword_label", nil);
    _yasoundLoginCellPwordTextField.placeholder = NSLocalizedString(@"yasoundLogin_Pword_placeholder", nil);
    
    
    _yasoundLoginCellSignupLabel.text = NSLocalizedString(@"yasoundLogin_Signup_label", nil);
}


- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
    
    [self flipToView:_loginView removeView:nil fromLeft:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if (tableView == _yasoundSignupTableView)
        return [self yasoundSignup_numberOfSectionsInTableView];

    return 4;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (tableView == _yasoundSignupTableView)
        return [self yasoundSignup_numberOfRowsInSection:section];
    
    if (section == SECTION_LOGIN)
        return 2;
    
    if (section == SECTION_OTHERS)
        return 2;
    
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{	
    if (section == SECTION_LOGIN)
        return NSLocalizedString(@"yasoundLogin_section_title", nil);

    if (section == SECTION_SIGNUP)
        return NSLocalizedString(@"yasoundLogin_Signup_section_title", nil);

    if (section == SECTION_OTHERS)
        return NSLocalizedString(@"yasoundLogin_Others_section_title", nil);
    
    return @"";
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_OTHERS)
        return 38;
    
    return 38;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView == _yasoundSignupTableView)
        return [self yasoundSignup_cellForRowAtIndexPath:indexPath];
    
    
    if ((indexPath.section == SECTION_LOGIN) && (indexPath.row == ROW_USERNAME))
        return _yasoundLoginCellUsername;

    if ((indexPath.section == SECTION_LOGIN) && (indexPath.row == ROW_PWORD))
        return _yasoundLoginCellPword;

    if ((indexPath.section == SECTION_SUBMIT) && (indexPath.row == ROW_SUBMIT))
    {
        _yasoundLoginCellSubmitLabel.text = NSLocalizedString(@"yasoundLogin_Submit_label", nil);
        return _yasoundLoginCellSubmit;
    }
    
    if ((indexPath.section == SECTION_SIGNUP) && (indexPath.row == ROW_SIGNUP))
        return _yasoundLoginCellSignup;

    
    // SECTION_OTHERS
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.row)
    {
        case ROW_FACEBOOK: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_facebook", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:[UIImage imageNamed:@"loginIcon26Facebook.png"]];
            break;
        }
            
        case ROW_TWITTER: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_twitter", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:[UIImage imageNamed:@"loginIcon26Twitter.png"]];
            break;
        }

    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _yasoundSignupTableView)
    {
        [self yasoundSignup_didSelectRowAtIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
        return;
    }
    
    if ((indexPath.section == SECTION_SIGNUP) && (indexPath.row == ROW_SIGNUP))
    {
        NSArray* data = [NSArray arrayWithObjects:_yasoundLoginCellSignupLabel, _yasoundLoginCellSignupLabel.textColor, nil];
        _yasoundLoginCellSignupLabel.textColor = [UIColor whiteColor];
        
        [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(onLabelUnselected:) userInfo:data repeats:NO];
        
        [self flipToView:_yasoundSignupView removeView:_loginView fromLeft:YES];
        
        return;
    }

    
//    RadioTabBarController* tabBarController = [[RadioTabBarController alloc] init];
//    [self.navigationController pushViewController:tabBarController animated:YES];
    
    if ((indexPath.section == SECTION_OTHERS) && (indexPath.row == ROW_FACEBOOK))
    {
        RadioViewController* view = [[RadioViewController alloc] init];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
    
    if ((indexPath.section == SECTION_OTHERS) && (indexPath.row == ROW_TWITTER))
    {

        SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    

}



- (void)onLabelUnselected:(NSTimer*)timer
{
    NSArray* data = timer.userInfo;
    UILabel* label = [data objectAtIndex:0];
    UIColor* color = [data objectAtIndex:1];
    label.textColor = color;
}






#pragma mark - IBActions

- (void) onBack:(id)sender
{
    if (_yasoundSignupViewVisible)
        [self flipToView:_loginView removeView:_yasoundSignupView fromLeft:NO];
}




#pragma mark - Flip View

- (void) flipToView:(UIView*)view removeView:(UIView*)viewToRemove fromLeft:(BOOL)fromLeft
{
    [self keyboardDidHide:nil];
    
    UIViewAnimationOptions animOptions = UIViewAnimationOptionTransitionFlipFromLeft;
    if (!fromLeft)
        animOptions = UIViewAnimationOptionTransitionFlipFromRight;
    
    [UIView transitionWithView:_container
                    duration:0.75
                    options:animOptions
                    animations:^{ if (viewToRemove != nil) [viewToRemove removeFromSuperview];  [_container addSubview:view]; }
                    completion:NULL];

    _loginViewVisible = NO;
    _yasoundSignupViewVisible = NO;

    if (view == _loginView)
    {
        _loginViewVisible = YES;
        [[self navigationItem] setLeftBarButtonItem:nil];      
        self.title = @"Yasound";
    }
    else if (view == _yasoundSignupView)
    {
        _yasoundSignupViewVisible = YES;
        [[self navigationItem] setLeftBarButtonItem:_backBtn];        
        [self yasoundSignup_ViewDidAppear];
    }
    
    
}





#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:TRUE];
    return FALSE;
}






#pragma mark - Notifications



-(void) keyboardDidShow: (NSNotification *)notif 
{
    // If keyboard is visible, return
    if (_keyboardVisible) 
    {
        NSLog(@"Keyboard is already visible. Ignoring notification.");
        return;
    }
    
    _keyboardVisible = YES;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.33];
    
    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"loginYasoundTableFrame2" retainStylesheet:NO overwriteStylesheet:NO error:nil];

    if (_yasoundSignupViewVisible)
    {
        _yasoundSignupTableView.contentInset = UIEdgeInsetsMake([[sheet.customProperties objectForKey:@"inset"] integerValue], 0.0, 0, 0.0);
        _yasoundSignupTableView.frame = sheet.frame;
    }
    
    [UIView commitAnimations];
}




-(void) keyboardDidHide: (NSNotification *)notif 
{
    // Is the keyboard already shown
    if (!_keyboardVisible) 
    {
        NSLog(@"Keyboard is already hidden. Ignoring notification.");
        return;
    }

    _keyboardVisible = NO;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.33];
    
    BundleStylesheet* sheet = [[BundleFileManager main] stylesheetForKey:@"loginYasoundTableFrame1" retainStylesheet:NO overwriteStylesheet:NO error:nil];

    if (_yasoundSignupViewVisible)
    {
        _yasoundSignupTableView.contentInset = UIEdgeInsetsMake([[sheet.customProperties objectForKey:@"inset"] integerValue], 0.0, 0, 0.0);
        _yasoundSignupTableView.frame = sheet.frame;
    }
    
    [UIView commitAnimations];    
}

@end
