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
#import "CreateMyRadio.h"
#import "YasoundSessionManager.h"
#import "YasoundDataProvider.h"
#import "ActivityAlertView.h"
#import "RootViewController.h"
#import "ConnectionView.h"
#import "YasoundReachability.h"


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





#pragma mark - IBActions


- (IBAction) onFacebook:(id)sender
{
    if (([YasoundReachability main].hasNetwork == YR_NO) || ([YasoundReachability main].isReachable == YR_NO))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_CONNECTION_NO object:nil];
        return;
    }
    
    // TAG ACTIVITY ALERT
    if ([YasoundSessionManager main].registered && [[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
    {
        // J'AIMERAI SAVOIR SI ON REPASSE ICI OU PAS
        assert(0);
        [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
    }

    [[YasoundSessionManager main] loginForFacebookWithTarget:self action:@selector(socialLoginReturned:info:)];
    
    // and disable facebook button
    _facebookButton.enabled = NO;

    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    _facebookButton.alpha = 0;
    _facebookLoginLabel.alpha = 0;

    [UIView commitAnimations];   
    
    // show a connection alert
    [self.view addSubview:[ConnectionView start]];
    

}




- (void)socialLoginReturned:(User*)user info:(NSDictionary*)info
{
    // close the connection alert
    [ConnectionView stop];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    _facebookButton.alpha = 1;
    _facebookLoginLabel.alpha = 1;
    
    [UIView commitAnimations];   
    

    if (user != nil)
    {
        // check if local account has been setted (<=> radio full configured)
        if ([[YasoundSessionManager main] getAccount:user])
            // call root to launch the Radio
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_RADIO object:nil];
        else
        {
            [[YasoundSessionManager main] addAccount:user];

            // ask for radio contents to the provider, in order to launch the radio configuration
            [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(onGetRadio:info:)];
        }
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


- (void)logoutReturned
{
    // once logout done, go back to the home screen
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_SCREEN object:nil];    
}

            
            
#pragma mark - YasoundDataProvider
            
- (void)onGetRadio:(Radio*)radio info:(NSDictionary*)info
{
//    assert(radio);
    
    // account just being create, go to configuration screen
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"skipRadioCreationSendToSelection"];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
    
    CreateMyRadio* view = [[CreateMyRadio alloc] initWithNibName:@"CreateMyRadio" bundle:nil wizard:YES radio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];    
}



@end
