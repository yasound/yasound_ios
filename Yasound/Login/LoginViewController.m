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



#define INDEX_FACEBOOK 0
#define INDEX_TWITTER 1
#define INDEX_YASOUND 2


@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _keyboardVisible = NO;
        _loginViewVisible = NO;
        _yasoundLoginViewVisible = NO;
        _yasoundSignupViewVisible = NO;
        
    }
    return self;
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
    [self yasoundLogin_ViewDidLoad];
    [self yasoundSignup_ViewDidLoad];
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
    if (tableView == _yasoundLoginTableView)
        return [self yasoundLogin_numberOfSectionsInTableView];

    if (tableView == _yasoundSignupTableView)
        return [self yasoundSignup_numberOfSectionsInTableView];

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (tableView == _yasoundLoginTableView)
        return [self yasoundLogin_numberOfRowsInSection:section];
    
    if (tableView == _yasoundSignupTableView)
        return [self yasoundSignup_numberOfRowsInSection:section];
    
    return 3;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView == _yasoundLoginTableView)
        return [self yasoundLogin_cellForRowAtIndexPath:indexPath];
    
    if (tableView == _yasoundSignupTableView)
        return [self yasoundSignup_cellForRowAtIndexPath:indexPath];
    
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.row)
    {
        case INDEX_FACEBOOK: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_facebook", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:[UIImage imageNamed:@"loginIconFacebook.png"]];
            break;
        }
            
        case INDEX_TWITTER: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_twitter", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:[UIImage imageNamed:@"loginIconTwitter.png"]];
            break;
        }

        case INDEX_YASOUND: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_yasound", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:[UIImage imageNamed:@"loginIconYasound.png"]];
            break;
        }

    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _yasoundLoginTableView)
    {
        [self yasoundLogin_didSelectRowAtIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
        return;
    }
    
    if (tableView == _yasoundSignupTableView)
    {
        [self yasoundSignup_didSelectRowAtIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
        return;
    }
    
    if (indexPath.row == INDEX_YASOUND)
    {
        [self flipToView:_yasoundLoginView removeView:_loginView fromLeft:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
        return;
    }
    
//    RadioTabBarController* tabBarController = [[RadioTabBarController alloc] init];
//    [self.navigationController pushViewController:tabBarController animated:YES];
    
    if (indexPath.row == INDEX_FACEBOOK)
    {
    RadioViewController* view = [[RadioViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
        return;
    }
    
    if (indexPath.row == INDEX_TWITTER)
    {

        SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    

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
    _yasoundLoginViewVisible = NO;
    _yasoundSignupViewVisible = NO;

    if (view == _loginView)
        _loginViewVisible = YES;
    else if (view == _yasoundLoginView)
    {
        _yasoundLoginViewVisible = YES;
        [self yasoundLogin_ViewDidAppear];
    }
    else if (view == _yasoundSignupView)
    {
        _yasoundSignupViewVisible = YES;
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

    if (_yasoundLoginViewVisible)
    {
        _yasoundLoginTableView.contentInset = UIEdgeInsetsMake([[sheet.customProperties objectForKey:@"inset"] integerValue], 0.0, 0, 0.0);
        _yasoundLoginTableView.frame = sheet.frame;
    }
    else if (_yasoundSignupViewVisible)
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

    if (_yasoundLoginViewVisible)
    {
        _yasoundLoginTableView.contentInset = UIEdgeInsetsMake([[sheet.customProperties objectForKey:@"inset"] integerValue], 0.0, 0, 0.0);
        _yasoundLoginTableView.frame = sheet.frame;
    }
    else if (_yasoundSignupViewVisible)
    {
        _yasoundSignupTableView.contentInset = UIEdgeInsetsMake([[sheet.customProperties objectForKey:@"inset"] integerValue], 0.0, 0, 0.0);
        _yasoundSignupTableView.frame = sheet.frame;
    }
    
    [UIView commitAnimations];    
}

@end
