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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushRadioSelection:) name:NOTIF_PUSH_RADIO_SELECTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifLoginScreen:) name:NOTIF_LOGIN_SCREEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifWizard:) name:NOTIF_WIZARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifMenu:) name:NOTIF_MENU object:nil];
    
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
//    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:YES radio:[YasoundDataProvider main].radio];
//    [self.navigationController pushViewController:view animated:NO];
//    [view release];

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
        
#ifdef FORCE_ROOTVIEW_RADIOS
        // add tabs
        RadioTabBarController* tabBarController = [[RadioTabBarController alloc] init];
        [self.navigationController pushViewController:tabBarController animated:NO];    
        [tabBarController release];
#else
        [self loginProcess];
#endif
    
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)loginProcess
{
    if ([YasoundSessionManager main].registered)
    {
        // TAG ACTIVITY ALERT
        [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
        
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
    if (user != nil)
    {
        [self launchRadio];
    }
    else
    {
        [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
    }
}

- (void)logoutReturned
{

}



- (void)onNotifPushRadio:(NSNotification *)notification
{
    // go back to root, removing all viewcontroller
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self launchRadio];
}

- (void)onNotifPushRadioSelection:(NSNotification*)notification
{
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:3] forKey:@"forceTabIndex"];
//    [[NSUserDefaults standardUserDefaults] synchronize];

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
    
    RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil title:NSLocalizedString(@"selection_tab_selection", nil) tabIcon:@"tabIconNew.png"];
    [self.navigationController pushViewController:view animated:NO];    
    [view relese];
}



- (void)onNotifLoginScreen:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    HomeViewController* view = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:NO];
    [view release];
}

- (void)onNotifWizard:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:YES radio:[YasoundDataProvider main].radio];
    [self.navigationController pushViewController:view animated:NO];
    [view release];
}

- (void)onNotifMenu:(NSNotification *)notification
{
    [self.navigationController popToViewController:_menuView animated:YES];
}





- (void)launchRadio
{
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"automaticLaunch"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


#pragma mark - Background Audio Playing


//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder 
{
  return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event 
{
  //if it is a remote control event handle it correctly
  if (event.type == UIEventTypeRemoteControl) 
  {
    if (event.subtype == UIEventSubtypeRemoteControlPlay) 
      [[AudioStreamManager main] startRadio:[AudioStreamManager main].currentRadio];
    
    else if (event.subtype == UIEventSubtypeRemoteControlPause) 
      [[AudioStreamManager main] stopRadio];
    
    else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) 
      [[AudioStreamManager main] togglePlayPauseRadio];
    
  }
}




@end
