//
//  RootViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "RadioTabBarController.h"
#import "RadioViewController.h"
#import "YasoundSessionManager.h"
#import "ActivityAlertView.h"
#import "YasoundDataProvider.h"
#import "YasoundReachability.h"
#import "AudioStreamManager.h"


//#define FORCE_ROOTVIEW_RADIOS


@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _firstTime = YES;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPushRadio:) name:@"NOTIF_PushRadio" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginScreen:) name:@"NOTIF_LoginScreen" object:nil];
    
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
    if (_firstTime)
    {
        _firstTime = NO;
        
        [[YasoundReachability main] startWithTargetForChange:self action:@selector(onReachabilityChanged)];
    }

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



- (void)onPushRadio:(NSNotification *)notification
{
    // go back to root, removing all viewcontroller
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self launchRadio];
}


- (void)onLoginScreen:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    HomeViewController* view = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:NO];
    [view release];
}



- (void)launchRadio
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"automaticLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // add tabs
    RadioTabBarController* tabBarController = [[RadioTabBarController alloc] init];
    [self.navigationController pushViewController:tabBarController animated:NO];    
    [tabBarController release];
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
