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
    
    
    if ([YasoundSessionManager main].registered && [[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
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


- (IBAction)onLogoutClicked:(id)sender
{
    // logout
    if ([YasoundSessionManager main].registered && [[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        [[YasoundSessionManager main] logoutForFacebookWithTarget:self action:@selector(socialLoginReturned:info:)];
    }
    
    // login
    else
    {
        [[YasoundSessionManager main] loginForFacebookWithTarget:self action:@selector(socialLoginReturned:info:)];
        
        // show a connection alert
        [self.view addSubview:[ConnectionView start]];
    }
    
}



- (void)socialLoginReturned:(User*)user info:(NSDictionary*)info
{
    // close the connection alert
    [ConnectionView stop];
    
    
    if (user != nil)
    {
        NSNumber* lastUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastConnectedUserID"];
        if (lastUserID && [lastUserID intValue] == [user.id intValue])
        {
            [[SongUploadManager main] importUploads];
            
            if ([YasoundReachability main].networkStatus == kReachableViaWiFi)
                // restart song uploads not completed on last application shutdown
                [[SongUploadManager main] resumeUploads];
            else if ([SongUploadManager main].items.count > 0)
            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundUpload_restart_WIFI_title", nil) message:NSLocalizedString(@"YasoundUpload_restart_WIFI_message", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [av release];  
            }
        }
        else
        {
            [[SongUploadManager main] clearStoredUpdloads];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:user.id forKey:@"LastConnectedUserID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSString* message = nil;
        if (info != nil)
        {
            NSString* errorValue = [info objectForKey:@"error"];
            if ([errorValue isEqualToString:@"Login"])
                message = NSLocalizedString(@"YasoundSessionManager_login_error", nil);
            else if ([errorValue isEqualToString:@"UserInfo"])
                message = NSLocalizedString(@"YasoundSessionManager_login_error", nil);
            
        }
        else
        {
            message = NSLocalizedString(@"YasoundSessionManager_userinfo_error", nil);        
        }
        
        // show alert message for connection error
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundSessionManager_login_title", nil) message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        
        //        // enable the facebook again, to let the user retry
        //        _facebookButton.enabled = YES;
        // and logout properly
        [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
        
        
    }
}




- (void)logoutDidReturned
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_SCREEN object:nil];
}




@end
