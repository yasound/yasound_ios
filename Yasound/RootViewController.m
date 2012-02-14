//
//  RootViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "RadioViewController.h"
#import "YasoundSessionManager.h"
#import "ActivityAlertView.h"
#import "YasoundDataProvider.h"
#import "YasoundReachability.h"
#import "AudioStreamManager.h"
#import "SettingsViewController.h"
#import "RadioSelectionViewController.h"
#import "ConnectionView.h"
#import "YasoundAppDelegate.h"

//#define FORCE_ROOTVIEW_RADIOS


@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _firstTime = YES;
        _menuView = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    if (_menuView != nil)
        [_menuView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushRadio:) name:NOTIF_PUSH_RADIO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifCancelWizard:) name:NOTIF_CANCEL_WIZARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifLoginScreen:) name:NOTIF_LOGIN_SCREEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifWizard:) name:NOTIF_WIZARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPopToMenu:) name:NOTIF_POP_TO_MENU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushMenu:) name:NOTIF_PUSH_MENU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorCommunicationServer:) name:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorConnectionLost:) name:NOTIF_ERROR_CONNECTION_LOST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorConnectionNo:) name:NOTIF_ERROR_CONNECTION_NO object:nil];

    

    
  //Make sure the system follows our playback status
  // <=> Background audio playing
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
  [[AVAudioSession sharedInstance] setActive: YES error: nil];  
  [[AVAudioSession sharedInstance] setDelegate: self];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (_firstTime)
    {
        _firstTime = NO;
        
        [[YasoundReachability main] startWithTargetForChange:self action:@selector(onReachabilityChanged)];
    }

  [self becomeFirstResponder];
}


- (void)onReachabilityChanged
{
    if (([YasoundReachability main].hasNetwork == YR_YES) && ([YasoundReachability main].isReachable == YR_YES))
    {
        [[YasoundReachability main] removeTarget];
        
        [self loginProcess];
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)loginProcess
{
    if (([YasoundReachability main].hasNetwork == YR_NO) || ([YasoundReachability main].isReachable == YR_NO))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ERROR_CONNECTION_NO object:nil];
        return;
    }
    
    
    if ([YasoundSessionManager main].registered)
    {
//        // TAG ACTIVITY ALERT
//        [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
        
        // show connection alert
        [self.view addSubview:[ConnectionView start]];
        
        if ([[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
            [[YasoundSessionManager main] loginForFacebookWithTarget:self action:@selector(loginReturned:)];
        else if ([[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_TWITTER])
            [[YasoundSessionManager main] loginForTwitterWithTarget:self action:@selector(loginReturned:)];
        else
            [[YasoundSessionManager main] loginForYasoundWithTarget:self action:@selector(loginReturned:)];
    }
    else
    {
        HomeViewController* view = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:NO];
        [view release];
    }
}

- (void)loginReturned:(User*)user
{
    // show connection alert
    [ConnectionView stop];

    if (user != nil)
    {
        NSNumber* radioId = [[NSUserDefaults standardUserDefaults] objectForKey:@"NowPlaying"];
        
        [self launchRadio:radioId];
    }
    else
    {
        // show alert message for connection error
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundSessionManager_login_title", nil) message:NSLocalizedString(@"YasoundSessionManager_login_error", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        
        // and logout properly
        [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
    }
}

- (void)logoutReturned
{
    // once logout done, go back to the home screen
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_SCREEN object:nil];
}



- (void)onNotifPushRadio:(NSNotification *)notification
{
    // my radio
    [self launchRadio:nil];
}

- (void)onNotifCancelWizard:(NSNotification*)notification
{  
  BOOL sendToSelection = [[[NSUserDefaults standardUserDefaults] objectForKey:@"skipRadioCreationSendToSelection"] boolValue];
  BOOL animatePushMenu = !sendToSelection;

    if (_menuView == nil)
    {
        _menuView = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        [_menuView retain];
        [self.navigationController pushViewController:_menuView animated:animatePushMenu];
    }
    else
    {
        [self.navigationController popToViewController:_menuView animated:animatePushMenu];
    }
    
  if (sendToSelection)
  {
    RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:NSLocalizedString(@"selection_tab_selection", nil) tabIcon:@"tabIconNew.png"];
    [self.navigationController pushViewController:view animated:NO];    
    [view release];
  }
}



- (void)onNotifLoginScreen:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [_menuView release];
    _menuView = nil;

    HomeViewController* view = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:NO];
    [view release];
}

- (void)onNotifWizard:(NSNotification *)notification
{
  BOOL willSendToSelection = [[[NSUserDefaults standardUserDefaults] objectForKey:@"skipRadioCreationSendToSelection"] boolValue];
  if (willSendToSelection || !_menuView)
  {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [_menuView release];
    _menuView = nil;
  }
  else
  {
    [self.navigationController popToViewController:_menuView animated:NO];
  }
    
    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:YES radio:[YasoundDataProvider main].radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onNotifPopToMenu:(NSNotification *)notification
{
    [self.navigationController popToViewController:_menuView animated:YES];
}

- (void)onNotifPushMenu:(NSNotification*)notification
{
  if (_menuView)
  {
    [self.navigationController popToViewController:_menuView animated:YES];
    return;
  }
  
  [self.navigationController popToRootViewControllerAnimated:NO];
  
  _menuView = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
  [_menuView retain];
  [self.navigationController pushViewController:_menuView animated:YES];
}

- (void)onNotifErrorCommunicationServer:(NSNotification *)notification
{
    // show alert message for connection error
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection", nil) message:NSLocalizedString(@"Error_communication_server", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
    
    // and logout properly
    [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
}

- (void)onNotifErrorConnectionLost:(NSNotification *)notification
{
    // show alert message for connection error
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_connection", nil) message:NSLocalizedString(@"YasoundReachability_connection_lost", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
    
    // and logout properly
    [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
}

- (void)onNotifErrorConnectionNo:(NSNotification *)notification
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_connection", nil) message:NSLocalizedString(@"YasoundReachability_connection_no", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
    
    // and logout properly
    [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
}







- (void)launchRadio:(NSNumber*)radioId
{
    if (radioId != nil)
        [[YasoundDataProvider main] radioWithId:(NSNumber*)radioId target:self action:@selector(onGetRadio:info:)];

    else
        // ask for radio contents to the provider
        [[YasoundDataProvider main] userRadioWithTarget:self action:@selector(onGetRadio:info:)];
}



- (void)onGetRadio:(Radio*)radio info:(NSDictionary*)info
{
    [ActivityAlertView close];
    
    if (_menuView == nil)
    {
        _menuView = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        [_menuView retain];
        [self.navigationController pushViewController:_menuView animated:NO];
    }
    else
    {
        [self.navigationController popToViewController:_menuView animated:NO];
    }

    //LBDEBUG TEST
//    RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:NSLocalizedString(@"selection_tab_selection", nil) tabIcon:@"tabIconNew.png"];
//    [self.navigationController pushViewController:view animated:NO];    
//    [view release];
    
//    RadioViewController* view = [[RadioViewController alloc] initWithRadio:radio];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
  YasoundAppDelegate* appDelegate =  (YasoundAppDelegate*)[[UIApplication sharedApplication] delegate];
  [appDelegate goToMyRadioFromViewController:self];
}


#pragma mark - Background Audio Playing


//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder 
{
  return YES;
}




@end
