//
//  HomeViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "SettingsViewController.h"
#import "MyYasoundViewController.h"
#import "RadioTabBarController.h"

#define ROW_LOGIN 0
#define ROW_SIGNUP 1



@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title =  NSLocalizedString(@"HomeView_title", nil);        
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
    
    _titleLabel.text = NSLocalizedString(@"HomeView_title", nil);

    _facebookLoginLabel.text = NSLocalizedString(@"HomeView_facebook_label", nil);
    _twitterLoginLabel.text = NSLocalizedString(@"HomeView_twitter_label", nil);
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
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
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
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.row)
    {
        case ROW_LOGIN: 
        {
            cell.textLabel.text = NSLocalizedString(@"HomeView_login_label", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
            
        case ROW_SIGNUP: 
        {
            cell.textLabel.text = NSLocalizedString(@"HomeView_signup_label", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }

    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == ROW_LOGIN)
    {
        LoginViewController* view = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }

    if (indexPath.row == ROW_SIGNUP)
    {
        SignupViewController* view = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
        return;
    }
}






#pragma mark - IBActions


- (IBAction) onFacebook:(id)sender
{
    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (IBAction) onTwitter:(id)sender
{
//    MyYasoundViewController* view = [[MyYasoundViewController alloc] initWithNibName:@"MyYasoundViewController" bundle:nil];
//    self.navigationController.navigationBarHidden = YES;
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
    RadioTabBarController* tabBarController = [[RadioTabBarController alloc] init];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:tabBarController animated:YES];    
}





@end
