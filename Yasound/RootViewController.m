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
#import "SongUploadViewController.h"
#import "RadioSelectionViewController.h"
#import "TabBar.h"
#import "MyRadiosViewController.h"
#import "GiftsViewController.h"
#import "ProfilViewController.h"


//LBDEBUG
//
//
@implementation NSArray (NSArrayDebug)
- (id)objectForKey:(NSString*)key
{
        DLog(@"SHOULD NOT HAPPEN : your NSURL* object is in fact a NSString* object!");
        assert(0);
}
@end
//
//
//@implementation NSDictionary (NSDictionaryDebug)
//- (BOOL)isEqualToString:(NSString*)str
//{
//        DLog(@"SHOULD NOT HAPPEN : your NSURL* object is in fact a NSString* object!");
//        assert(0);
//}
//
//- (void)addObject:(id)object
//{
//    DLog(@"SHOULD NOT HAPPEN : your NSURL* object is in fact a NSString* object!");
//    assert(0);
//}
//
//- (id)objectAtIndex:(NSInteger)index
//{
//    DLog(@"SHOULD NOT HAPPEN : your NSURL* object is in fact a NSString* object!");
//    assert(0);
//}
//
//@end


//@implementation NSString (NSStringDebug)
//- (NSString*) absoluteString
//{
//    DLog(@"SHOULD NOT HAPPEN : your NSURL* object is in fact a NSString* object!");
//    assert(0);
//}
//@end













@implementation RootViewController


@synthesize user;
@synthesize menuView;



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

- (void)dealloc
{
    if (self.menuView != nil)
        [self.menuView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushRadio:) name:NOTIF_PUSH_RADIO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPopAndGotoUploads:) name:NOTIF_POP_AND_GOTO_UPLOADS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifCancelWizard:) name:NOTIF_CANCEL_WIZARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifLoginScreen:) name:NOTIF_LOGIN_SCREEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifWizard:) name:NOTIF_WIZARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPopToMenu:) name:NOTIF_POP_TO_MENU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushMenu:) name:NOTIF_PUSH_MENU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorCommunicationServer:) name:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorConnectionChanged:) name:NOTIF_REACHABILITY_CHANGED object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoMenu:) name:NOTIF_GOTO_MENU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoSelection:) name:NOTIF_GOTO_SELECTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoFavorites:) name:NOTIF_GOTO_FAVORITES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoMyRadios:) name:NOTIF_GOTO_MYRADIOS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoGifts:) name:NOTIF_GOTO_GIFTS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoProfil:) name:NOTIF_GOTO_PROFIL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoRadio:) name:NOTIF_GOTO_RADIO object:nil];
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
        
        // if the user has already signed in, launch the automatic login process
        if ([YasoundSessionManager main].registered)
        {
            [self automaticLoginProcess];
        }
        
        // get the app menu from the server, before you can proceed
        [[YasoundDataProvider main] menuDescriptionWithTarget:self action:@selector(didReceiveMenuDescription:)];
        
        // didReceivedMenuDescription will proceed to the app entry
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)automaticLoginProcess
{
    // import associated accounts
    [[YasoundSessionManager main] importUserData];

        
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
            DLog(@"LOGIN ERROR. COULD NOT DO ANYTHING.");
        }
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
            //DLog(@"DEBUG info %@", info);
            
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
    
    DLog(@"menuDesc : %@", menuDesc);

    // be sure to store it in the cache
    [[YasoundDataCache main] setMenu:menuDesc];
    
    
    [self enterTheApp];
}



// that's what I call a significant method name
- (void)enterTheApp
{
    
//    // go to the menu, either you are connected or not
//    self.menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
//    [self.navigationController pushViewController:self.menuView animated:YES];

    
    if (APPDELEGATE.mustGoToNotificationCenter)
    {
        [self goToNotificationCenter];
        [APPDELEGATE setMustGoToNotificationCenter:NO];
    }
    else
    {
        NSNumber* radioId = [[UserSettings main] objectForKey:USKEYnowPlaying];
        
        if (radioId == nil)
        {
            Radio* myRadio = self.user.own_radio;
            if (myRadio && myRadio.ready)
                [self launchRadio:myRadio];
            else
                // default screen is Selection
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_SELECTION object:nil];
        }
        else
            [self launchRadio:radioId];
    }

    BOOL error;
    NSInteger lastUserID = [[UserSettings main] integerForKey:USKEYuserId error:&error];
    
    if (!error && (lastUserID == [self.user.id intValue]))
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
    
    [[UserSettings main] setObject:self.user.id forKey:USKEYuserId];
}









- (void)logoutReturned
{
    // once logout done, go back to the home screen
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MENU object:nil];
}

- (void)goToNotificationCenter
{
  if (self.menuView == nil)
  {
    self.menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
    [self.navigationController pushViewController:self.menuView animated:NO];
  }
  else
  {
    [self.navigationController popToViewController:self.menuView animated:NO];
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

- (void)onPopAndGotoUploads:(NSNotification*)notification
{
    [self.navigationController popViewControllerAnimated:NO];
    
    SongUploadViewController* newView = [[SongUploadViewController alloc] initWithNibName:@"SongUploadViewController" bundle:nil];
    
    [self.navigationController pushViewController:newView animated:YES];
    [newView release];
}



- (void)onNotifCancelWizard:(NSNotification*)notification
{  
    BOOL sendToSelection = [[UserSettings main] boolForKey:USKEYskipRadioCreation error:nil];
    BOOL animatePushMenu = !sendToSelection;

    if (self.menuView == nil)
    {
        self.menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
        [self.navigationController pushViewController:self.menuView animated:animatePushMenu];
    }
    else
    {
        [self.navigationController popToViewController:self.menuView animated:animatePushMenu];
    }
    
  if (sendToSelection)
  {
      RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:NO];    
    [view release];
  }
}



- (void)onNotifLoginScreen:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.menuView release];
    self.menuView = nil;

    LoginViewController* view = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onNotifWizard:(NSNotification *)notification
{
    BOOL willSendToSelection = [[UserSettings main] boolForKey:USKEYskipRadioCreation error:nil];
  if (willSendToSelection || !self.menuView)
  {
    [self.navigationController popToRootViewControllerAnimated:NO];
      if (self.menuView != nil)
      {
          [self.menuView release];
          self.menuView = nil;
      }
  }
  else
  {
    [self.navigationController popToViewController:self.menuView animated:NO];
  }
    
//    SettingsViewController* view = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil wizard:YES radio:[YasoundDataProvider main].radio];
    
    PlaylistsViewController* view = [[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil wizard:YES];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onNotifPopToMenu:(NSNotification *)notification
{
    [self.navigationController popToViewController:self.menuView animated:YES];
}

- (void)onNotifPushMenu:(NSNotification*)notification
{
  if (self.menuView)
  {
    [self.navigationController popToViewController:self.menuView animated:YES];
    return;
  }
  
  [self.navigationController popToRootViewControllerAnimated:NO];
  
  self.menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
  [self.menuView retain];
  [self.navigationController pushViewController:self.menuView animated:YES];
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
//       DLog(@"onNotifErrorConnectionBack ERROR unexpected STATUS CODE!");
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
        DLog(@"onNotifErrorConnectionChanged no network ");

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
        DLog(@"onNotifErrorConnectionChanged WIFI ");

        // don't test if it's running. If may runs, but paused if the connection was lost, for instance
//        if (![SongUploadManager main].isRunning)
            [[SongUploadManager main] resumeUploads];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SONG_GUI_NEED_REFRESH object:nil];
    }
    
    // 3G turns on (<=> or wifi turns off, then 3G turns on)
    else if (status == ReachableViaWWAN)
    {
        DLog(@"onNotifErrorConnectionChanged WWAN ");
        
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

    if (radio == nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_SELECTION object:nil];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO object:radio];

//    if ([[YasoundDataProvider main].radio.id intValue] == [radio.id intValue])
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MYRADIO object:nil];
//    }
//    
//    else
//    {
//        self.menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
//        [self.navigationController pushViewController:self.menuView animated:NO];
//    }
}





- (void)gotoMenuAnimated:(BOOL)animated
{
    if (self.menuView == nil)
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
        self.menuView = [[MenuDynamicViewController alloc] initWithNibName:@"MenuDynamicViewController" bundle:nil withSections:[[YasoundDataCache main] menu]];
        [self.navigationController pushViewController:self.menuView animated:animated];
    }
    else
    {
        [self.navigationController popToViewController:self.menuView animated:animated];
    }
}



- (void)onNotifGotoRadio:(NSNotification*)notification
{
    Radio* r = notification.object;
    assert(r != nil);

    DLog(@"onNotifGotoRadio '%@' (ready %@)", r.name, r.ready);

    [self gotoMenuAnimated:NO];

    RadioViewController* view = [[RadioViewController alloc] initWithRadio:r];
    [self.navigationController pushViewController:view animated:YES];
    [view release];    
}


- (void)onNotifGotoMenu:(NSNotification*)notification
{
    DLog(@"onNotifGotoMenu");
    
    [self gotoMenuAnimated:YES];
}


- (void)onNotifGotoSelection:(NSNotification*)notification
{
    DLog(@"onNotifGotoSelection");
    
    [self gotoMenuAnimated:NO];
    
    RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil withTabIndex:TabIndexSelection];
    [self.navigationController pushViewController:view animated:YES];    
    [view release];
}

- (void)onNotifGotoFavorites:(NSNotification*)notification
{
    DLog(@"onNotifGotoFavorites");
    
    [self gotoMenuAnimated:NO];
    
    RadioSelectionViewController* view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil withTabIndex:TabIndexFavorites];
    [self.navigationController pushViewController:view animated:YES];    
    [view release];
}

- (void)onNotifGotoMyRadios:(NSNotification*)notification
{
    DLog(@"onNotifGotoMyRadios");
    
    [self gotoMenuAnimated:NO];
    
    MyRadiosViewController* view = [[MyRadiosViewController alloc] initWithNibName:@"MyRadiosViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];    
    [view release];
}

- (void)onNotifGotoGifts:(NSNotification*)notification
{
    DLog(@"onNotifGotoGifts");
    
    [self gotoMenuAnimated:NO];
    
    GiftsViewController* view = [[GiftsViewController alloc] initWithNibName:@"GiftsViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];    
    [view release];
}


- (void)onNotifGotoProfil:(NSNotification*)notification
{
    DLog(@"onNotifGotoProfil");
    
    [self gotoMenuAnimated:NO];
    
    ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];    
    [view release];
}









- (void)onNotifGotoMyRadio:(NSNotification *)notification
{
    Radio* r = [YasoundDataProvider main].radio;
    DLog(@"go to my radio '%@' (%@)", r.name, r.ready);

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
    [[UserSettings main] setBool:NO forKey:USKEYskipRadioCreation];
    
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
























/*


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
                DLog(@"LOGIN ERROR. COULD NOT DO ANYTHING.");
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
            DLog(@"DEBUG info %@", info);
            
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
*/




@end
