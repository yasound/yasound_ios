//
//  RootViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 04/01/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"
#import "WallViewController.h"
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
#import "YasoundDataCache.h"
#import "ProgrammingViewController.h"
#import "RadioSelectionViewController.h"
#import "MyRadiosViewController.h"
#import "ProfilViewController.h"
#import "AccountTwitterViewController.h"
#import "AccountFacebookViewController.h"
#import "WebPageViewController.h"
#import "DeviceVersion.h"
#import "UIDevice+Resolutions.h"
#import "InviteContactsViewController.h"
#import "InviteFacebookFriendsViewController.h"
#import "InviteTwitterFriendsViewController.h"
#import "AccountYasoundViewController.h"
#import "NotificationCenterViewController.h"
#import "SongLocalCatalog.h"



@class CreateRadioViewController;
@class MyAccountViewController;
@class StatsViewController;

//LBDEBUG
//
//
//@implementation NSArray (NSArrayDebug)
//
//
//- (id)objectForKey:(NSString*)key
//{
//        DLog(@"SHOULD NOT HAPPEN : your NSDictionary* object is in fact a NSArray* object!");
//        assert(0);
//}
//@end


//@implementation NSDate (NSDateDebug)
//
//
//- (NSInteger)length
//{
//        DLog(@"SHOULD NOT HAPPEN ");
//        assert(0);
//}
//@end

//@implementation NSDictionary (NSDictionaryDebug)
//- (id)target
//{
//    NSLog(@"meuh");
//    assert(0);
//}
//@end


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


//@implementation NSURL (NSURLDebug)
//- (CGFloat)length {
//    DLog(@"SHOULD NOT HAPPEN!");
//    assert(0);
//}
//@end











@implementation RootViewController


@synthesize user;
@synthesize radioSelectionViewController;


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
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    if ([UIDevice resolution] == UIDeviceResolution_iPhoneRetina4)
        self.imageBackground.image = [UIImage imageNamed:@"commonLogoScreen-568h@2x.png"];
    else
        self.imageBackground.image = [UIImage imageNamed:@"commonLogoScreen.png"];
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifConnectionTimeout:) name:NOTIF_CONNECTION_TIMEOUT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifLaunchRadio:) name:NOTIF_LAUNCH_RADIO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPopAndGotoUploads:) name:NOTIF_POP_AND_GOTO_UPLOADS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDismissModal:) name:NOTIF_DISMISS_MODAL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorCommunicationServer:) name:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorConnectionChanged:) name:NOTIF_REACHABILITY_CHANGED object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoSelection:) name:NOTIF_GOTO_SELECTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoFavorites:) name:NOTIF_GOTO_FAVORITES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoMyRadios:) name:NOTIF_GOTO_MYRADIOS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoGifts:) name:NOTIF_GOTO_GIFTS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoNotifications:) name:NOTIF_GOTO_NOTIFICATIONS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoProfil:) name:NOTIF_GOTO_PROFIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoEditProfile:) name:NOTIF_GOTO_EDIT_PROFIL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushRadio:) name:NOTIF_PUSH_RADIO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoRadio:) name:NOTIF_GOTO_RADIO object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushLogin:) name:NOTIF_PUSH_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoLogin:) name:NOTIF_GOTO_LOGIN object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoTwitterAssociation:) name:NOTIF_GOTO_TWITTER_ASSOCIATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoFacebookAssociation:) name:NOTIF_GOTO_FACEBOOK_ASSOCIATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoYasoundAssociation:) name:NOTIF_GOTO_YASOUND_ASSOCIATION object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoWebPageView:) name:NOTIF_GOTO_WEB_PAGE_VIEW object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoRadioProgramming:) name:NOTIF_GOTO_RADIO_PROGRAMMING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoRadioStats:) name:NOTIF_GOTO_RADIO_STATS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoCreateRadio:) name:NOTIF_GOTO_CREATE_RADIO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoFriends:) name:NOTIF_GOTO_FRIENDS object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifInviteContacts:) name:NOTIF_INVITE_CONTACTS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifInviteFacebook:) name:NOTIF_INVITE_FACEBOOK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifInviteTwitter:) name:NOTIF_INVITE_TWITTER object:nil];
    


    
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


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.view.layer.shadowOpacity = 0.75f;
    self.navigationController.view.layer.shadowRadius = 10.0f;
    self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)start
{
    if (_firstTime)
    {
        _firstTime = NO;
        
        [[YasoundReachability main] startWithTargetForChange:self action:@selector(onReachabilityChanged:)];
    }

  [self becomeFirstResponder];
}


- (void)onReachabilityChanged:(NSString*)message
{
    // connection problem. do you want to retry?
    if (([YasoundReachability main].hasNetwork != YR_YES) || ([YasoundReachability main].isReachable != YR_YES)) {
        
        if (message) {
            
            _alertReachabilityNo = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_host", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_OK", nil) otherButtonTitles:nil];
            [_alertReachabilityNo show];
            [_alertReachabilityNo release];

        }
        else  {
            
            _alertReachabilityNo = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YasoundReachability_host", nil) message:NSLocalizedString(@"YasoundReachability_connection_no", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Navigation_OK", nil) otherButtonTitles:nil];
            [_alertReachabilityNo show];
            [_alertReachabilityNo release];
            
        }
        return;
    }
    

    [[YasoundReachability main] removeTarget];
    
    // launch the local songs catalog building, in a thread
    [[SongLocalCatalog main] build];

    
    // if the user has already signed in, launch the automatic login process
    if ([YasoundSessionManager main].registered)
    {
        [self automaticLoginProcess];
    }
    else
    {
        [self enterTheApp];
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
    [self.view addSubview:[ConnectionView startWithFrame:self.view.frame  target:self timeout:@selector(onConnectionTimeout)]];

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


- (void)onConnectionTimeout {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CONNECTION_TIMEOUT object:nil];
}


- (void)loginReturned:(User*)user info:(NSDictionary*)info
{
    // show connection alert
    [ConnectionView stop];
    
    if (user != nil)
    {
        [[YasoundSessionManager main] writeUserIdentity:user];
        
        self.user = user;
        
        // login the other associated accounts as well
        [[YasoundSessionManager main] associateAccountsAutomatic];
        
        [self enterTheApp];
    }
    else
    {
        NSString* message = nil;
        if (info != nil)
        {
            NSString* errorValue = [info objectForKey:@"error"];
            if (errorValue)
            {
                if ([errorValue isEqualToString:@"Login"])
                    message = NSLocalizedString(@"YasoundSessionManager_login_error", nil);
                else if ([errorValue isEqualToString:@"UserInfo"])
                        message = NSLocalizedString(@"YasoundSessionManager_userinfo_error", nil);
            }
                
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



// that's what I call a significant method name
- (void)enterTheApp
{
    
    NSNumber* radioId = [[UserSettings main] objectForKey:USKEYnowPlaying];
    
    if (radioId == nil)
    {
        //LBDEBUG TODO ICI : own_radio pas bon
        YaRadio* myRadio = self.user.own_radio;
        if (myRadio && myRadio.ready)
            [self launchRadio:myRadio.id];
        else
            // default screen is Selection
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_SELECTION object:nil];
    }
    else
        [self launchRadio:radioId];
    

    BOOL error;
    NSInteger lastUserID = [[UserSettings main] integerForKey:USKEYuserId error:&error];
    
    if (self.user && !error && (lastUserID == [self.user.id intValue]))
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
    
    if (self.user)
        [[UserSettings main] setObject:self.user.id forKey:USKEYuserId];
    
    if (APPDELEGATE.mustGoToNotificationCenter)
    {
        [self goToNotificationCenter];
        [APPDELEGATE setMustGoToNotificationCenter:NO];
    }    
}






- (void)onDismissModal:(NSNotification*)notif {
    
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
}



- (void)logoutReturned
{
}

- (void)goToNotificationCenter
{
    NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}




- (void)onNotifLaunchRadio:(NSNotification *)notification
{
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];

    // my radio
    [self launchRadio:nil];
}

- (void)onPopAndGotoUploads:(NSNotification*)notification
{
    [self gotoRadioSelectionAnimated:NO];
    
    YaRadio* radio = notification.object;
    
    ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil  forRadio:radio];
    [self.navigationController pushViewController:view animated:YES];
    
    [view.wheelSelector stickToItem:PROGRAMMING_WHEEL_ITEM_UPLOADS silent:NO];
    [view release];
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
            NSInteger nbUploads = [[SongUploadManager main] countUploads];
            
            [[SongUploadManager main] interruptUploads];
            
            if ((nbUploads > 0) && (_alertWifiInterrupted == nil))
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
    
    




- (void)launchRadio:(NSNumber*)radioId
{
    if (radioId != nil)
    {
        YaRadio* newRadio = nil;
        [[YasoundDataProvider main] radioWithId:radioId withCompletionBlock:^(int status, NSString* response, NSError* error){
            if (error)
            {
                DLog(@"radio with id error: %d - %@", error.code, error. domain);
            }
            else if (status != 200)
            {
                DLog(@"radio with id error: response status %d", status);
            }
            else
            {
                YaRadio* newRadio = (YaRadio*)[response jsonToModel:[YaRadio class]];
                if (!newRadio)
                {
                    DLog(@"radio with id error: cannot parse response: %@", response);
                }
            }
            
            [self gotoRadio:newRadio];
        }];
    }
    else
    {
        // ask for radio contents to the provider        
        [[YasoundDataProvider main] userRadioWithTargetWithCompletionBlock:^(YaRadio* userRadio){
            [self gotoRadio:userRadio];
        }];
    }
}

- (void)gotoRadio:(YaRadio*)radio
{
    [ActivityAlertView close];
    if (radio == nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_SELECTION object:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO object:radio];
}




- (void)gotoRadioSelectionAnimated:(BOOL)animated
{
    if (self.radioSelectionViewController != nil) {
        [self.navigationController popToViewController:self.radioSelectionViewController animated:animated];
        return;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else {
        [self.navigationController popToViewController:APPDELEGATE.menuViewController animated:NO];
    }
    
    if ([UIDevice resolution] == UIDeviceResolution_iPhoneRetina4) {
        self.radioSelectionViewController = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController-4inch" bundle:nil withWheelIndex:WheelIdSelection];
    }
    else  {
        self.radioSelectionViewController = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil withWheelIndex:WheelIdSelection];
    }
    
    [self.navigationController pushViewController:self.radioSelectionViewController animated:animated];
}

- (void)onNotifGotoLogin:(NSNotification *)notification
{
    LoginViewController* view = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
    [view release];
}

- (void)onNotifPushLogin:(NSNotification *)notification
{
    LoginViewController* view = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
    [view release];
}




- (void)onNotifPushRadio:(NSNotification*)notification
{
    YaRadio* r = notification.object;
    if (r == nil)
    {
        DLog(@"ERROR radio is nil in RootViewController:onNotifPushRadio");
        return;
    }

    DLog(@"onNotifPushRadio '%@' (ready %@)", r.name, r.ready);

    WallViewController* view = [[WallViewController alloc] initWithRadio:r];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onNotifGotoRadio:(NSNotification*)notification
{
    YaRadio* r = notification.object;
    assert(r != nil);

    DLog(@"onNotifGotoRadio '%@' (ready %@)", r.name, r.ready);

    [self gotoRadioSelectionAnimated:NO];
    
    [APPDELEGATE.slideController resetTopView];

    WallViewController* view = [[WallViewController alloc] initWithRadio:r];
    [self.navigationController pushViewController:view animated:YES];
    [view release];    
}




- (void)onNotifGotoSelection:(NSNotification*)notification
{
    DLog(@"onNotifGotoSelection");
    
    NSNumber* nbAnimated = notification.object;
    BOOL animated = YES;
    if (nbAnimated)
        animated = [nbAnimated boolValue];

    RadioSelectionViewController* view = nil;
    if ([UIDevice resolution] == UIDeviceResolution_iPhoneRetina4) {
        view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController-4inch" bundle:nil withWheelIndex:WheelIdSelection];
    }
    else  {
        view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil withWheelIndex:WheelIdSelection];
    }

    
    [self.navigationController pushViewController:view animated:animated];
    [view release];
}

- (void)onNotifGotoFavorites:(NSNotification*)notification
{
    DLog(@"onNotifGotoFavorites");
    
    NSNumber* nbAnimated = notification.object;
    BOOL animated = YES;
    if (nbAnimated)
        animated = [nbAnimated boolValue];
    
//    [self gotoMenuAnimated:NO];
    
    RadioSelectionViewController* view = nil;
    if ([UIDevice resolution] == UIDeviceResolution_iPhoneRetina4) {
        view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController-4inch" bundle:nil withWheelIndex:WheelIdSelection];
    }
    else  {
        view = [[RadioSelectionViewController alloc] initWithNibName:@"RadioSelectionViewController" bundle:nil withWheelIndex:WheelIdSelection];
    }

    [self.navigationController pushViewController:view animated:animated];
    [view release];
}

- (void)onNotifGotoMyRadios:(NSNotification*)notification
{
    DLog(@"onNotifGotoMyRadios");
    
    NSNumber* nbAnimated = notification.object;
    BOOL animated = YES;
    if (nbAnimated)
        animated = [nbAnimated boolValue];
    
    MyRadiosViewController* view = [[MyRadiosViewController alloc] initWithNibName:@"MyRadiosViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:animated];
    [view release];
}

- (void)onNotifGotoGifts:(NSNotification*)notification
{
    DLog(@"onNotifGotoGifts");
    
    NSNumber* nbAnimated = notification.object;
    BOOL animated = YES;
    if (nbAnimated)
        animated = [nbAnimated boolValue];
}


- (void)onNotifGotoNotifications:(NSNotification*)notification
{
    NotificationCenterViewController* view = [[NotificationCenterViewController alloc] initWithNibName:@"NotificationCenterViewController" bundle:nil];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
    [view release];
}



- (void)onNotifGotoProfil:(NSNotification*)notification
{
    DLog(@"onNotifGotoProfil");
    
    NSNumber* nbAnimated = notification.object;
    BOOL animated = YES;
    if (nbAnimated)
        animated = [nbAnimated boolValue];
    
    ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:[YasoundDataProvider main].user];
    [self.navigationController pushViewController:view animated:animated];
    [view release];
}









- (void)onNotifGotoMyRadio:(NSNotification *)notification
{
    YaRadio* r = [YasoundDataProvider main].radio;
    DLog(@"go to my radio '%@' (%@)", r.name, r.ready);

    if (![r.ready boolValue])
    {
        //LBDEBUG  : VOIR QUAND CA ARRIVE ET ADAPTER
        assert(0);
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_CREATE_MYRADIO object:nil];
        return;
    }
        
    WallViewController* view = [[WallViewController alloc] initWithRadio:r];
    [(APPDELEGATE).navigationController pushViewController:view animated:YES];
    [view release];
}


- (void)onNotifGotoTwitterAssociation:(NSNotification *)notification
{
    AccountTwitterViewController* view = [[AccountTwitterViewController alloc] initWithNibName:@"AccountTwitterViewController" bundle:nil];
    [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
    [view release];
}

- (void)onNotifGotoFacebookAssociation:(NSNotification *)notification
{
    AccountFacebookViewController* view = [[AccountFacebookViewController alloc] initWithNibName:@"AccountFacebookViewController" bundle:nil];
    [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
    [view release];
}


- (void)onNotifGotoYasoundAssociation:(NSNotification *)notification
{
    AccountYasoundViewController* view = [[AccountYasoundViewController alloc] initWithNibName:@"AccountYasoundViewController" bundle:nil];
    [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
    [view release];
}

- (void)onNotifGotoWebPageView:(NSNotification *)notification
{
    NSURL* url = notification.object;
    WebPageViewController* view = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil withUrl:url andTitle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onNotifGotoRadioProgramming:(NSNotification *)notification
{
    YaRadio* radio = notification.object;
    ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil  forRadio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onNotifGotoRadioStats:(NSNotification *)notification
{
    YaRadio* radio = notification.object;
    StatsViewController* view = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil forRadio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onNotifGotoCreateRadio:(NSNotification *)notification
{
    CreateRadioViewController* view = [[CreateRadioViewController alloc] initWithNibName:@"CreateRadioViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}


- (void)onNotifGotoFriends:(NSNotification *)notification
{
    [self onNotifInviteContacts:notification];
}



- (void)onNotifGotoEditProfile:(NSNotification*)notification
{
    BOOL animated = YES;
    NSNumber* nbAnimated = notification.object;
    if (nbAnimated)
        animated = [nbAnimated boolValue];
    
    MyAccountViewController* view = [[MyAccountViewController alloc] initWithNibName:@"MyAccountViewController" bundle:nil];
    [APPDELEGATE.navigationController presentModalViewController:view animated:animated];
    [view release];
}

- (void)onNotifInviteContacts:(NSNotification*)notification
{
    if (![YasoundSessionManager main].registered)
    {
        NSNumber* animated = [NSNumber numberWithBool:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_LOGIN object:animated];
        return ;
    }
    
    InviteContactsViewController* controller = [[InviteContactsViewController alloc] init];
    [APPDELEGATE.navigationController presentModalViewController:controller animated:YES];
    [controller release];
}

- (void)onNotifInviteFacebook:(NSNotification*)notification
{
    if (![YasoundSessionManager main].registered)
    {
        NSNumber* animated = [NSNumber numberWithBool:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_LOGIN object:animated];
        return ;
    }
    BOOL facebookEnabled = [[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK];
    if (!facebookEnabled)
    {
        NSNumber* animated = [NSNumber numberWithBool:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_FACEBOOK_ASSOCIATION object:animated];
        return;
    }
    
    InviteFacebookFriendsViewController* controller = [[InviteFacebookFriendsViewController alloc] init];
    [APPDELEGATE.navigationController presentModalViewController:controller animated:YES];
    [controller release];

}

- (void)onNotifInviteTwitter:(NSNotification*)notification
{
    if (![YasoundSessionManager main].registered)
    {
        NSNumber* animated = [NSNumber numberWithBool:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_LOGIN object:animated];
        return ;
    }
    BOOL twitterEnabled = [[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER];
    if (!twitterEnabled)
    {
        NSNumber* animated = [NSNumber numberWithBool:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_TWITTER_ASSOCIATION object:animated];
        return;
    }
    
    InviteTwitterFriendsViewController* controller = [[InviteTwitterFriendsViewController alloc] init];
    [APPDELEGATE.navigationController presentModalViewController:controller animated:YES];
    [controller release];
}



- (void)onNotifConnectionTimeout:(NSNotification*)notification {
    
    
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:NO];
    
    [[YasoundSessionManager main] logoutWithTarget:self action:@selector(logoutReturnedAfterTimeout)];
}


- (void)logoutReturnedAfterTimeout
{
    [APPDELEGATE.slideController resetTopView];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_LOGIN object:nil];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginView_title", nil) message:NSLocalizedString(@"Connection.timeout", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];
    
    
}



#pragma mark - Background Audio Playing


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertWifiInterrupted)
    {
        _alertWifiInterrupted = nil;
        return;
    }
    
    if (alertView == _alertReachabilityNo) {
        
        [ActivityAlertView showWithTitle:nil];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onRetryTick:) userInfo:nil repeats:NO];
        return;
    }
    
}

- (void)onRetryTick:(NSTimer*)timer {
    
    [ActivityAlertView close];
    [[YasoundReachability main] startWithTargetForChange:self action:@selector(onReachabilityChanged:)];

}








@end
