//
//  RootViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"
#import "RadioViewController.h"
#import "YasoundSessionManager.h"
#import "ActivityAlertView.h"
#import "YasoundDataProvider.h"
#import "YasoundReachability.h"
#import "AudioStreamManager.h"
#import "PlaylistsViewController.h"
#import "RadioSelectionViewController.h"
#import "ConnectionView.h"
#import "YasoundAppDelegate.h"
#import "SongUploadManager.h"
#import "NotificationCenterViewController.h"
#import "CreateMyRadio.h"
#import "YasoundDataCache.h"

//#define FORCE_ROOTVIEW_RADIOS


//LBDEBUG
@implementation NSDictionary (NSDictionaryDebug)
- (BOOL)isEqualToString:(NSString*)str
{
        NSLog(@"SHOULD NOT HAPPEN : your NSURL* object is in fact a NSString* object!");
        assert(0);
}

- (void)addObject:(id)object
{
    NSLog(@"SHOULD NOT HAPPEN : your NSURL* object is in fact a NSString* object!");
    assert(0);
}

- (id)objectAtIndex:(NSInteger)index
{
    NSLog(@"SHOULD NOT HAPPEN : your NSURL* object is in fact a NSString* object!");
    assert(0);
}

@end


@implementation NSString (NSStringDebug)
- (NSString*) absoluteString
{
    NSLog(@"SHOULD NOT HAPPEN : your NSURL* object is in fact a NSString* object!");
    assert(0);
}
@end













@implementation RootViewController


@synthesize user;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorConnectionChanged:) name:NOTIF_REACHABILITY_CHANGED object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoMyRadio:) name:NOTIF_GOTO_MYRADIO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoCreateMyRadio:) name:NOTIF_GOTO_CREATE_MYRADIO object:nil];
    

    
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
        // TODO? message?
        return;
    }
    

    // import associated accounts
    [[YasoundSessionManager main] importUserData];

    if ([YasoundSessionManager main].registered)
    {
//        // TAG ACTIVITY ALERT
//        [ActivityAlertView showWithTitle:NSLocalizedString(@"LoginView_alert_title", nil)];        
        
        // show connection alert
        [self.view addSubview:[ConnectionView start]];
        
        if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
            [[YasoundSessionManager main] loginForFacebookWithTarget:self action:@selector(loginReturned:info:)];

        else if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
            [[YasoundSessionManager main] loginForTwitterWithTarget:self action:@selector(loginReturned:info:)];
        
        else if ([[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_YASOUND])
            [[YasoundSessionManager main] loginForYasoundWithTarget:self action:@selector(loginReturned:info:)];
        else
        {
            //for compatibility with previous exclusive system
            if ([[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_FACEBOOK])
                [[YasoundSessionManager main] loginForFacebookWithTarget:self action:@selector(loginReturned:info:)];
            
            else if ([[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_TWITTER])
                [[YasoundSessionManager main] loginForTwitterWithTarget:self action:@selector(loginReturned:info:)];
            
            else if ([[YasoundSessionManager main].loginType isEqualToString:LOGIN_TYPE_YASOUND])
                [[YasoundSessionManager main] loginForYasoundWithTarget:self action:@selector(loginReturned:info:)];
            else
            {
                assert(0);
                NSLog(@"LOGIN ERROR. COULD NOT DO ANYTHING.");
            }
        }
        
    }
    else
    {
        LoginViewController* view = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:view animated:NO];
        [view release];
    }
}

- (void)loginReturned:(User*)user info:(NSDictionary*)info
{
    // show connection alert
    [ConnectionView stop];

    if (user != nil)
    {
        [[YasoundSessionManager main] reloadUserData:user];
        
        self.user = user;
        
        // login the other associated accounts as well
        [[YasoundSessionManager main] associateAccountsAutomatic];
        
        // get the app menu from the server, before you can proceed
        [[YasoundDataProvider main] menuDescriptionWithTarget:self action:@selector(didReceiveMenuDescription:)];
    
    }
    else
    {
        NSString* message = nil;
        if (info != nil)
        {
            //LBDEBUG
            NSLog(@"DEBUG info %@", info);
            
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
        
        // and logout properly
        [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
    }
}



// you receive the current menu description from the server
- (void)didReceiveMenuDescription:(ASIHTTPRequest*)req
{
    NSString* menuDesc = req.responseString;

    // be sure to store it in the cache
    [[YasoundDataCache main] setMenu:menuDesc];
    
    
    [self enterTheAppAfterProperLogin];
}



// that's what I call a significant method name
- (void)enterTheAppAfterProperLogin
{
    if (APPDELEGATE.mustGoToNotificationCenter)
    {
        [self goToNotificationCenter];
        [APPDELEGATE setMustGoToNotificationCenter:NO];
    }
    else
    {
        NSNumber* radioId = [[NSUserDefaults standardUserDefaults] objectForKey:@"NowPlaying"];
        
        if (radioId == nil)
        {
            Radio* myRadio = self.user.own_radio;
            if (myRadio && myRadio.ready)
                [self launchRadio:myRadio];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_MENU object:nil];
        }
        else
            [self launchRadio:radioId];
    }
    
    NSNumber* lastUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastConnectedUserID"];
    if (lastUserID && [lastUserID intValue] == [self.user.id intValue])
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
    
    [[NSUserDefaults standardUserDefaults] setObject:self.user.id forKey:@"LastConnectedUserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}









- (void)logoutReturned
{
    // once logout done, go back to the home screen
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_SCREEN object:nil];
}

- (void)goToNotificationCenter
{
  if (_menuView == nil)
  {
    _menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
    [_menuView retain];
    [self.navigationController pushViewController:_menuView animated:NO];
  }
  else
  {
    [self.navigationController popToViewController:_menuView animated:NO];
  }
  
  NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
  [self.navigationController pushViewController:view animated:YES];
  [view release];
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
        _menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
        [_menuView retain];
        [self.navigationController pushViewController:_menuView animated:animatePushMenu];
    }
    else
    {
        [self.navigationController popToViewController:_menuView animated:animatePushMenu];
    }
    
  if (sendToSelection)
  {
      NSDictionary* entry = [[YasoundDataCache main] menuEntry:MENU_ENTRY_ID_SELECTION];
      NSString* url = [[YasoundDataCache main] entryParameter:MENU_ENTRY_PARAM_URL forEntry:entry];
      NSString* name = [entry objectForKey:@"name"];
      assert(entry);
      
      RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil withUrl:[NSURL URLWithString:url] andTitle:name];
    [self.navigationController pushViewController:view animated:NO];    
    [view release];
  }
}



- (void)onNotifLoginScreen:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [_menuView release];
    _menuView = nil;

    LoginViewController* view = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
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
    
//    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:YES radio:[YasoundDataProvider main].radio];
    
    PlaylistsViewController* view = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil wizard:YES];
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
  
  _menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
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



////
//// onNotifErrorConnectionBack 
////
//// when the 3G or wifi turns on
//// 
//- (void)onNotifErrorConnectionBack:(NSNotification *)notification
//{
//    
//   else 
//       NSLog(@"onNotifErrorConnectionBack ERROR unexpected STATUS CODE!");
//    
//    
//    
////    // show alert message for connection error
////    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_connection", nil) message:NSLocalizedString(@"YasoundReachability_connection_lost", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
////    [av show];
////    [av release];  
////    
////    // and logout properly
////    [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
//}
//








- (void)onNotifErrorConnectionChanged:(NSNotification *)notification
{
    NetworkStatus status = [YasoundReachability main].networkStatus;

    if ([YasoundReachability main].hasNetwork == YR_NO)
    {
        NSLog(@"onNotifErrorConnectionChanged no network ");

        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_connection", nil) message:NSLocalizedString(@"YasoundReachability_connection_no", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];  
        
        if ([SongUploadManager main].isRunning)
        {
            [[SongUploadManager main] interruptUploads];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SONG_GUI_NEED_REFRESH object:nil];

        // and logout properly
        //[[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
    }

    // Wifi turns on
    else if (status == ReachableViaWiFi)
    {
        NSLog(@"onNotifErrorConnectionChanged WIFI ");

        // don't test if it's running. If may runs, but paused if the connection was lost, for instance
//        if (![SongUploadManager main].isRunning)
            [[SongUploadManager main] resumeUploads];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SONG_GUI_NEED_REFRESH object:nil];
    }
    
    // 3G turns on (<=> or wifi turns off, then 3G turns on)
    else if (status == ReachableViaWWAN)
    {
        NSLog(@"onNotifErrorConnectionChanged WWAN ");
        
        if ([SongUploadManager main].isRunning)
        {
            [[SongUploadManager main] interruptUploads];
            
            if (_alertWifiInterrupted == nil)
            {
                // show alert message for connection error
                _alertWifiInterrupted = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundUpload_interrupt_WIFI_title", nil) message:NSLocalizedString(@"YasoundUpload_interrupt_WIFI_message", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [_alertWifiInterrupted show];
                [_alertWifiInterrupted release];  
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SONG_GUI_NEED_REFRESH object:nil];
    }
    
}
    
    
//    // show alert message for connection error
//    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_connection", nil) message:NSLocalizedString(@"YasoundReachability_connection_lost", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [av show];
//    [av release];  
//    
//    // and logout properly
//    [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
//}

//- (void)onNotifErrorConnectionNo:(NSNotification *)notification
//{
//    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_connection", nil) message:NSLocalizedString(@"YasoundReachability_connection_no", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [av show];
//    [av release];  
//    
//    // and logout properly
//    [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturned)];
//}







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
        _menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
        [_menuView retain];
        [self.navigationController pushViewController:_menuView animated:NO];
    }
    else
    {
        [self.navigationController popToViewController:_menuView animated:NO];
    }

    if ([[YasoundDataProvider main].radio.id intValue] == [radio.id intValue])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MYRADIO object:nil];
    }
    else
    {
        _menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
        [_menuView retain];
        [self.navigationController pushViewController:_menuView animated:NO];
    }
}





- (void)onNotifGotoMyRadio:(NSNotification *)notification
{
    Radio* r = [YasoundDataProvider main].radio;
    NSLog(@"go to my radio '%@' (%@)", r.name, r.ready);

    if (![r.ready boolValue])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_CREATE_MYRADIO object:nil];
        return;
    }
        
    RadioViewController* view = [[RadioViewController alloc] initWithRadio:r];
    [(APPDELEGATE).navigationController pushViewController:view animated:YES];
    [view release];
}



- (void*)onNotifGotoCreateMyRadio:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"skipRadioCreationSendToSelection"];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
    
    CreateMyRadio* view = [[CreateMyRadio alloc] initWithNibName:@"CreateMyRadio" bundle:nil wizard:NO radio:[YasoundDataProvider main].radio];
    [(APPDELEGATE).navigationController pushViewController:view animated:YES];
    [view release];
}




#pragma mark - Background Audio Playing


//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder 
{
  return YES;
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertWifiInterrupted)
    {
        _alertWifiInterrupted = nil;
    }
}





@end
