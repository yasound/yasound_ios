//
//  AccountFacebookViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 30/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "AccountFacebookViewController.h"
#import "YasoundSessionManager.h"
#import "AudioStreamManager.h"
#import "ConnectionView.h"


@interface AccountFacebookViewController ()

@end

@implementation AccountFacebookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _titleItem.title = @"Facebook";
    _backItem.title = NSLocalizedString(@"Navigation_back", nil);    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    _usernameLabel.text = NSLocalizedString(@"AccountsView_username_label", nil);
    
    
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
    {
        _usernameLabel.textColor = [UIColor whiteColor];
        _usernameValue.textColor = [UIColor whiteColor];
        _logoutLabel.text = NSLocalizedString(@"AccountsView_logout_label", nil);
        
        _usernameValue.text = [YasoundDataProvider main].user.name;
    }
    else
    {
        _usernameLabel.textColor = [UIColor grayColor];
        _usernameValue.textColor = [UIColor grayColor];
        _logoutLabel.text = NSLocalizedString(@"AccountsView_login_label", nil);    
        
        _usernameValue.text = @"-";
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onButtonClicked:(id)sender
{
    // logout
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
    {
        [[YasoundSessionManager main] associateAccount:LOGIN_TYPE_FACEBOOK withTarget:self action:@selector(associateReturned:) associate:NO];
    }
    
    // login
    else
    {
        [[YasoundSessionManager main] associateAccount:LOGIN_TYPE_FACEBOOK withTarget:self action:@selector(associateReturned:) associate:YES];
        
        // show a connection alert
        [self.view addSubview:[ConnectionView start]];
    }
    
}



- (void)associateReturned:(NSDictionary*)info
{
    // close the connection alert
    [ConnectionView stop];
    
}


- (void)dissociateReturned:(NSDictionary*)info
{
    // close the connection alert
    [ConnectionView stop];
    
}







@end
