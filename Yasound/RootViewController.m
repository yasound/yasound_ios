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
//#import "GiftsViewController.h"
#import "ProfilViewController.h"
#import "AccountTwitterViewController.h"
#import "AccountFacebookViewController.h"
#import "WebPageViewController.h"
#import "Version.h"
#import "UIDevice+Resolutions.h"


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


@implementation NSURL (NSURLDebug)
- (CGFloat)length {
    DLog(@"SHOULD NOT HAPPEN!");
    assert(0);
}


@end











@implementation RootViewController


@synthesize user;
@synthesize radioSelectionViewController;
//@synthesize menuView;

//static MenuViewController* gMenuView = nil;


//+ (BOOL)menuIsCurrentScreen
//{
//    UIViewController* tmp = APPDELEGATE.navigationController.topViewController;
//    NSLog(@"class %@", [tmp class]);
//    NSLog(@"compare %@   %@", tmp, gMenuView);
//    
//    
//    return (APPDELEGATE.navigationController.topViewController == gMenuView);
//}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _firstTime = YES;
        
//    if ([UIDevice resolution] == UIDeviceResolution_iPhoneRetina4)
//        self.imageBackground.image = [UIImage imageNamed:@"Default-568h@2x.png"];
        
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
//    if (gMenuView != nil)
//        [gMenuView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
//    if ([UIDevice resolution] == UIDeviceResolution_iPhoneRetina4)
//        self.imageBackground.image = [UIImage imageNamed:@"Default-568h@2x.png"];
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifLaunchRadio:) name:NOTIF_LAUNCH_RADIO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPopAndGotoUploads:) name:NOTIF_POP_AND_GOTO_UPLOADS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDismissModal:) name:NOTIF_DISMISS_MODAL object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifCancelWizard:) name:NOTIF_CANCEL_WIZARD object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifWizard:) name:NOTIF_WIZARD object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPopToMenu:) name:NOTIF_POP_TO_MENU object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushMenu:) name:NOTIF_PUSH_MENU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorCommunicationServer:) name:NOTIF_ERROR_COMMUNICATION_SERVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifErrorConnectionChanged:) name:NOTIF_REACHABILITY_CHANGED object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoMenu:) name:NOTIF_GOTO_MENU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoSelection:) name:NOTIF_GOTO_SELECTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoFavorites:) name:NOTIF_GOTO_FAVORITES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoMyRadios:) name:NOTIF_GOTO_MYRADIOS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoGifts:) name:NOTIF_GOTO_GIFTS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoProfil:) name:NOTIF_GOTO_PROFIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoEditProfile:) name:NOTIF_GOTO_EDIT_PROFIL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushRadio:) name:NOTIF_PUSH_RADIO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoRadio:) name:NOTIF_GOTO_RADIO object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifPushLogin:) name:NOTIF_PUSH_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoLogin:) name:NOTIF_GOTO_LOGIN object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifDidLogout:) name:NOTIF_DID_LOGOUT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoTwitterAssociation:) name:NOTIF_GOTO_TWITTER_ASSOCIATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoFacebookAssociation:) name:NOTIF_GOTO_FACEBOOK_ASSOCIATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoWebPageView:) name:NOTIF_GOTO_WEB_PAGE_VIEW object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoRadioProgramming:) name:NOTIF_GOTO_RADIO_PROGRAMMING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoRadioStats:) name:NOTIF_GOTO_RADIO_STATS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifGotoCreateRadio:) name:NOTIF_GOTO_CREATE_RADIO object:nil];
    


    
  //Make sure the system follows our playback status
  // <=> Background audio playing
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
  [[AVAudioSession sharedInstance] setActive: YES error: nil];  
  [[AVAudioSession sharedInstance] setDelegate: self];

//    // put the menu above the root viewController
//     MenuViewController* menu = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
//    [self.view addSubview:menu.view];
    
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
//    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(mydebug) userInfo:nil repeats:NO];
//}
//
//- (void)mydebug{
    
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
        else
            
        {
            // get the app menu from the server, before you can proceed
            //[[YasoundDataProvider main] menuDescriptionWithTarget:self action:@selector(didReceiveMenuDescription:)];
        
            // didReceivedMenuDescription will proceed to the app entry
            
            [self enterTheApp];

        }
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
        [[YasoundSessionManager main] writeUserIdentity:user];
        
        self.user = user;
        
        // login the other associated accounts as well
        [[YasoundSessionManager main] associateAccountsAutomatic];
        
        // get the app menu from the server, before you can proceed
        //[[YasoundDataProvider main] menuDescriptionWithTarget:self action:@selector(didReceiveMenuDescription:)];
        [self enterTheApp];

    
    }
    else
    {
        NSString* message = nil;
        if (info != nil)
        {
            //LBDEBUG
            //DLog(@"DEBUG info %@", info);
            
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


//// you receive the current menu description from the server
//- (void)didReceiveMenuDescription:(ASIHTTPRequest*)req
//{
//    NSString* menuDesc = req.responseString;
//    
//    DLog(@"menuDesc : %@", menuDesc);
//
//    // be sure to store it in the cache
//    [[YasoundDataCache main] setMenu:menuDesc];
//    
//    
//    [self enterTheApp];
//
//}



// that's what I call a significant method name
- (void)enterTheApp
{
    
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
            //LBDEBUG TODO ICI : own_radio pas bon
            Radio* myRadio = self.user.own_radio;
            if (myRadio && myRadio.ready)
                [self launchRadio:myRadio.id];
            else
                // default screen is Selection
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_SELECTION object:nil];
        }
        else
            [self launchRadio:radioId];
    }

    BOOL error;
    NSInteger lastUserID = [[UserSettings main] integerForKey:USKEYuserId error:&error];
    
    if (self.user && !error && (lastUserID == [self.user.id intValue]))
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
    
    if (self.user)
        [[UserSettings main] setObject:self.user.id forKey:USKEYuserId];
}






- (void)onDismissModal:(NSNotification*)notif {
    
    [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
}



- (void)logoutReturned
{
    // once logout done, go back to the home screen
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MENU object:nil];
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
    
    Radio* radio = notification.object;
    
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
//    [self gotoMenuAnimated:NO];
    
    LoginViewController* view = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//    [self.navigationController pushViewController:view animated:YES];
    [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
    [view release];
}

- (void)onNotifPushLogin:(NSNotification *)notification
{
    LoginViewController* view = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//    [self.navigationController pushViewController:view animated:YES];
    [APPDELEGATE.navigationController presentModalViewController:view animated:YES];
    
    //LBDEBUG ICI
//    [APPDELEGATE.navigationController presentViewController:view animated:YES completion:nil];
    
  [view release];
}




- (void)onNotifPushRadio:(NSNotification*)notification
{
    Radio* r = notification.object;
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
    Radio* r = notification.object;
    assert(r != nil);

    DLog(@"onNotifGotoRadio '%@' (ready %@)", r.name, r.ready);

//    [self gotoMenuAnimated:NO];
    
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
    
//    [self gotoMenuAnimated:NO];
    
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
    
//    [self gotoMenuAnimated:NO];
    
//    GiftsViewController* view = [[GiftsViewController alloc] initWithNibName:@"GiftsViewController" bundle:nil];
//    [self.navigationController pushViewController:view animated:animated];
//    [view release];
}


- (void)onNotifGotoProfil:(NSNotification*)notification
{
    DLog(@"onNotifGotoProfil");
    
    NSNumber* nbAnimated = notification.object;
    BOOL animated = YES;
    if (nbAnimated)
        animated = [nbAnimated boolValue];
    
//    [self gotoMenuAnimated:NO];
    
    ProfilViewController* view = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil forUser:[YasoundDataProvider main].user];
    [self.navigationController pushViewController:view animated:animated];
    [view release];
}









- (void)onNotifGotoMyRadio:(NSNotification *)notification
{
    Radio* r = [YasoundDataProvider main].radio;
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
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onNotifGotoFacebookAssociation:(NSNotification *)notification
{
    AccountFacebookViewController* view = [[AccountFacebookViewController alloc] initWithNibName:@"AccountFacebookViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
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
    Radio* radio = notification.object;
    ProgrammingViewController* view = [[ProgrammingViewController alloc] initWithNibName:@"ProgrammingViewController" bundle:nil  forRadio:radio];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)onNotifGotoRadioStats:(NSNotification *)notification
{
    Radio* radio = notification.object;
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


- (void)onNotifGotoEditProfile:(NSNotification*)notification
{
    MyAccountViewController* view = [[MyAccountViewController alloc] initWithNibName:@"MyAccountViewController" bundle:nil];
    [APPDELEGATE.navigationController pushViewController:view animated:YES];
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
