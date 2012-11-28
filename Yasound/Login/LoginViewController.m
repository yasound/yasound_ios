//
//  LoginViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "LoginViewController.h"
#import "YasoundSessionManager.h"
#import "YasoundReachability.h"
#import "RootViewController.h"
#import "ActivityAlertView.h"
#import "ConnectionView.h"
#import "SongUploadManager.h"
#import "YasoundLoginViewController.h"
#import "SignupViewController.h"
#import "YasoundDataCache.h"
#import "YasoundAppDelegate.h"

@implementation LoginViewController

@synthesize user;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        //self.title =  NSLocalizedString(@"LoginView_title", nil);
        _dismissed = NO;
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
    
    _backBtn.title = NSLocalizedString(@"Navigation_back", nil);    

    _titleLabel.title = NSLocalizedString(@"LoginView_title", nil);
    
    _facebookLabel.text = NSLocalizedString(@"LoginView_facebook_label", nil);    
    _twitterLabel.text = NSLocalizedString(@"LoginView_twitter_label", nil);    
    _yasoundLabel.text = NSLocalizedString(@"LoginView_yasound_label", nil);    
    
    [_signupButton setTitle:NSLocalizedString(@"LoginView_signup_label", nil) forState:UIControlStateNormal  textAlignment:UITextAlignmentRight];

    
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}




- (void)viewDidAppear:(BOOL)animated
{
    //[self enableButtons:YES];
    [super viewDidAppear:animated];
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


- (IBAction)onFacebook:(id)sender
{
    if (([YasoundReachability main].hasNetwork == YR_NO) || ([YasoundReachability main].isReachable == YR_NO))
    {
        // TODO? message?
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
    
    // and disable buttons
    [self enableButtons:NO];
    
    [self hideButtons:YES];
        
    // show a connection alert
    [self.view addSubview:[ConnectionView start]];
    
    
}





- (IBAction)onTwitter:(id)sender
{
    if (([YasoundReachability main].hasNetwork == YR_NO) || ([YasoundReachability main].isReachable == YR_NO))
    {
        // TODO? message?
        return;
    }
    
    // TAG ACTIVITY ALERT
    if ([YasoundSessionManager main].registered && [[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_TWITTER])
    {
        // J'AIMERAI SAVOIR SI ON REPASSE ICI OU PAS
        assert(0);
        [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
    }
    
    // close the current modal first
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    _dismissed = YES;
    
    [[YasoundSessionManager main] loginForTwitterWithTarget:self action:@selector(socialLoginReturned:info:)];
    
    // and disable buttons
    [self enableButtons:NO];
    
    [self hideButtons:YES];

    
    // show a connection alert
    [self.view addSubview:[ConnectionView start]];
}


- (void)onConnectionTimeout {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CONNECTION_TIMEOUT object:nil];
}



- (void)socialLoginReturned:(User*)user info:(NSDictionary*)info
{
    // close the connection alert
    [ConnectionView stop];

    [self hideButtons:NO];
    
    
    if (user != nil)
    {
        [[YasoundSessionManager main] writeUserIdentity:user];
        
        // login the other associated accounts as well
        [[YasoundSessionManager main] associateAccountsAutomatic];
        
        
        self.user = user;
        
        [self enterTheAppAfterProperLogin];


    }
    else
    {
        NSString* message = nil;
        if (info != nil)
        {
            DLog(@"socialLoginReturned with info %@", info);
            
            NSString* errorValue = [info objectForKey:@"error"];
          if ([errorValue isEqualToString:@"Cancel"])
            message = nil;
          else if ([errorValue isEqualToString:@"Login"])
            message = NSLocalizedString(@"YasoundSessionManager_login_error", nil);
          else if ([errorValue isEqualToString:@"UserInfo"])
            message = NSLocalizedString(@"YasoundSessionManager_login_error", nil);
            
            [self enableButtons:YES];
            
        }
        else
        {
            // case of automatic associating. not an error
            //message = NSLocalizedString(@"YasoundSessionManager_userinfo_error", nil);      
            return;
        }
        
        // show alert message for connection error
        if (message != nil)
        {
          UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundSessionManager_login_title", nil) message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
          [av show];
          [av release];
        }
        
        // and logout properly
        [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
        
        
    }
}





- (void)enterTheAppAfterProperLogin
{

    
    // check if local account has been set (<=> radio full configured)
    if ([[YasoundSessionManager main] isUser:self.user])
        // call root to launch the Radio
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LAUNCH_RADIO object:nil];
    else
    {
        [[YasoundSessionManager main] addAccount:self.user];
        
        // ask for radio contents to the provider, in order to launch the radio configuration
        [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(onGetRadio:info:)];
    }
    
    BOOL error;
    NSInteger lastUserID = [[UserSettings main] integerForKey:USKEYuserId error:&error];
    
    if (!error && (lastUserID == [self.user.id intValue]))
    {
        [[SongUploadManager main] importUploads];
        
        if ([YasoundReachability main].networkStatus == kReachableViaWiFi)
            // restart song uploads not completed on last application shutdown
            [[SongUploadManager main] resumeUploads];
        else if ([[SongUploadManager main] countUploads] > 0)

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
    
    [[UserSettings main] setInteger:[user.id intValue] forKey:USKEYuserId];
}


- (void)logoutReturned
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MENU object:nil];
}








- (IBAction)onYasound:(id)sender
{
    YasoundLoginViewController* viewC = [[YasoundLoginViewController alloc] initWithNibName:@"YasoundLoginViewController" bundle:nil];
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [APPDELEGATE.navigationController presentModalViewController:viewC animated:NO];
    [viewC release];
}


- (IBAction)onYasoundSignup:(id)sender
{
    SignupViewController* viewC = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    [APPDELEGATE.navigationController presentModalViewController:viewC animated:NO];
    [viewC release];
}









- (void)enableButtons:(BOOL)enable
{
    _facebookButton.enabled = enable;
    _twitterButton.enabled = enable;
    _yasoundButton.enabled = enable;
    _signupButton.enabled = enable;
}


- (void)hideButtons:(BOOL)hide
{
    CGFloat alpha = (hide)? 0 : 1;
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    _facebookButton.alpha = alpha;
    _facebookLabel.alpha = alpha;
    _twitterButton.alpha = alpha;
    _twitterLabel.alpha = alpha;
    _yasoundButton.alpha = alpha;
    _yasoundLabel.alpha = alpha;
    _signupButton.alpha = alpha;
    [UIView commitAnimations];   
}





#pragma mark - YasoundDataProvider

- (void)onGetRadio:(Radio*)radio info:(NSDictionary*)info
{
    // account just being create, go to configuration screen
    [[UserSettings main] setBool:YES forKey:USKEYskipRadioCreation];

    if (!_dismissed) {
        _dismissed = YES;
        [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
    }
    
    [APPDELEGATE.slideController resetTopView];
}




#pragma mark - IBActions


#pragma mark - TopBarModalDelegate

- (BOOL)shouldShowActionButton {
    return NO;
}

- (NSString*)topBarTitle
{
    NSString* str = NSLocalizedString(@"LoginView_title", nil);
    return str;
}

- (NSString*)titleForCancelButton {
    
    return NSLocalizedString(@"Navigation.close", nil);
}





@end
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
