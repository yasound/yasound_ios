//
//  AccountTwitterViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 30/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "AccountTwitterViewController.h"
#import "YasoundSessionManager.h"
#import "AudioStreamManager.h"
#import "ConnectionView.h"
#import "ActivityAlertView.h"

@interface AccountTwitterViewController ()

@end

@implementation AccountTwitterViewController

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
    
    _titleItem.title = @"Twitter";
    _backItem.title = NSLocalizedString(@"Navigation_back", nil);    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    
    _usernameLabel.text = NSLocalizedString(@"AccountsView_username_label", nil);
    
    [self update];
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








- (void)update
{
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
    {
        _usernameLabel.textColor = [UIColor whiteColor];
        _usernameValue.textColor = [UIColor whiteColor];
        _logoutLabel.text = NSLocalizedString(@"AccountsView_logout_label", nil);
        
        [_logoutButton setImage:@"BigActionRedButton.png" forState:UIControlStateNormal];
        [_logoutButton setImage:@"BigActionRedButtonHighlighted.png" forState:UIControlStateHighlighted];
        [_logoutButton setImage:@"BigActionButtonDisabled.png" forState:UIControlStateDisabled];

        NSDictionary* account = [[YasoundSessionManager main] accountManagerGet:LOGIN_TYPE_TWITTER];
        _usernameValue.text = [account objectForKey:@"username"];

        // disable the button if you want to prevent the user to disconnect from the only one associated account
        if ([[YasoundSessionManager main] accountManagerNumberOfAccounts] == 1)
            _logoutButton.enabled = NO;
    }
    else
    {
        _usernameLabel.textColor = [UIColor grayColor];
        _usernameValue.textColor = [UIColor grayColor];
        _logoutLabel.text = NSLocalizedString(@"AccountsView_login_label", nil);    
        
        [_logoutButton setImage:@"BigActionGreenButton.png" forState:UIControlStateNormal];
        [_logoutButton setImage:@"BigActionGreenButtonHighlighted.png" forState:UIControlStateHighlighted];
        [_logoutButton setImage:@"BigActionButtonDisabled.png" forState:UIControlStateDisabled];
        
        _usernameValue.text = @"-";
    }
}





#pragma mark - IBActions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onButtonClicked:(id)sender
{
    // logout
    if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
    {
        [[YasoundSessionManager main] dissociateAccount:LOGIN_TYPE_TWITTER target:self action:@selector(dissociateReturned:)];
    }
    
    // login
    else
    {
        [[YasoundSessionManager main] associateAccountTwitter:self action:@selector(associateReturned:)];
        
        // show a connection alert
        [self.view addSubview:[ConnectionView startWithFrame:CGRectMake(86,340, 138, 90)]];
    }
    
}



- (void)associateReturned:(NSDictionary*)info
{
    NSLog(@"associateReturned :%@", info);
    
    // close the connection alert
    [ConnectionView stop];
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    succeeded = [nb boolValue];
    
    if (!succeeded)
    {
        NSString* title =  NSLocalizedString(@"AccountsView_alert_title", nil);
        title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Twitter"];
        
        NSString* message = [info objectForKey:@"response"];
        if (message == nil)
            message = NSLocalizedString(@"AccountsView_alert_user_incorrect", nil);
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;    
    }
    
    
    // success
    NSString* title =  NSLocalizedString(@"AccountsView_alert_login_success", nil);
    title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Twitter"];
    [ActivityAlertView showWithTitle:title closeAfterTimeInterval:2];
    
    [self update];
    
}



- (void)dissociateReturned:(NSDictionary*)info
{
    NSLog(@"dissociateReturned :%@", info);
    
    // close the connection alert
    [ConnectionView stop];
    
    BOOL succeeded = NO;
    
    NSNumber* nb = [info objectForKey:@"succeeded"];
    succeeded = [nb boolValue];
    
    if (!succeeded)
    {
        NSString* title =  NSLocalizedString(@"AccountsView_alert_title", nil);
        title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Twitter"];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"AccountsView_alert_logout_error", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        return;    
    }
    
    
    // success
    NSString* title =  NSLocalizedString(@"AccountsView_alert_logout_success", nil);
    title = [title stringByReplacingOccurrencesOfString:@"%@" withString:@"Twitter"];
    [ActivityAlertView showWithTitle:title closeAfterTimeInterval:2];
    
    [self update];
    
}








@end
