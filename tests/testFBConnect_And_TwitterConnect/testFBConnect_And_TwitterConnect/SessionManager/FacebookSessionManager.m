//
//  SessionManager.h
//  online login management
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SessionManager.h"



@implementation SessionManager

//@synthesize delegate;
@synthesize authorized;
@synthesize twitterEngine = _twitterEngine;
@synthesize twitterAccount = _twitterAccount;
@synthesize facebook = _facebook;



// consumer key, consumer secre, fb app id and secret, are based on app "neywenTest"

#define kOAuthConsumerKey @"lm6cEvevtSlX1IwFL3ZM4w"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"bEDK1Un5srTcDeuX6crBkihu4pmb96aaMgJnOzD3VRY"     //REPLACE With Twitter App OAuth Secret  

#define FB_App_Id @"136849886422778"
#define DB_APP_Secret @"bcaadff05c7c07d36d38155d6b35088c"






#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)






// Singleton
static SessionManager* _manager = nil;

+ (SessionManager*)manager
{
  if (!_manager)
  {
    _manager = [[SessionManager alloc] init];
  }
  
  return _manager;
}



- (id)init
{
  self = [super init];
  if (self)
  {
    _twitterEngine = nil;
    _facebook = nil;
    _delegate = nil;
  }
  return self;
}


- (void)dealloc
{
  if (_twitterEngine)
    [_twitterEngine release]; 
  if (_facebook)
    [_facebook release]; 
}


- (BOOL)authorized
{
  if (_twitterEngine)
    return [_twitterEngine isAuthorized];
  
  if (_facebook)
    return [_facebook isSessionValid];
  
  return NO;
}


- (void)logout
{
  if (_twitterEngine)
  {
    [_twitterEngine clearAccessToken];
    [_twitterEngine clearsCookies];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authData"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"authName"];
    
//    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authName"]);
//    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authData"]);
    
    [_twitterEngine release];
    _twitterEngine=nil;  
    
    [_delegate sessionDidLogout];  
    
    return;
  }
  
  if (_facebook)
  {
    [_facebook logout:self];
    return;
  }
}






#pragma mark - Twitter


//.......................................................................
//
// login using twitter
//
- (void)loginUsingTwitter:(UIViewController*)target
{
  _delegate = target;
  
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) 
    [self loginUsingTwitteriOS];
  else
    [self loginUsingTwitterOAuth];
}

- (void)loginUsingTwitteriOS
{
  TwitterAccountsViewController* controller = [[TwitterAccountsViewController alloc] initWithNibName:@"TwitterAccountsViewController" bundle:nil target:self];
}


- (void)loginUsingTwitterOAuth
{
  if (!_twitterEngine)
  {  
    _twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
    _twitterEngine.consumerKey    = kOAuthConsumerKey;  
    _twitterEngine.consumerSecret = kOAuthConsumerSecret;  
  }  
  
  if(![_twitterEngine isAuthorized])
  {  
    SA_OAuthTwitterController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_twitterEngine delegate:self];  
    if (!controller)
      return;
    
    controller.delegate = self;
    [_delegate presentModalViewController:controller animated: YES];  
  }  
}



#pragma mark - TwitterAccountsDelegate

- (void)twitterDidLoadAccounts:(TwitterAccountsViewController*)sender nbAccounts:(NSInteger)nbAccounts
{
  if (nbAccounts == 0)
  {
    NSString* message = @"Please go to the system Settings\nand add a Twitter account.";
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Twitter Account" message:message delegate:self
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];  
    return;
  }

  [_delegate presentModalViewController:sender animated: YES];  
  [sender release];
}


//// This identifier can be used to look up the account using [ACAccountStore accountWithIdentifier:].
//@property (nonatomic, readonly) NSString            *identifier;
//
//// Accounts are stored with a particular account type. All available accounts of a particular type 
//// can be looked up using [ACAccountStore accountsWithAccountType:]. When creating new accounts
//// this property is required.
//@property (nonatomic, retain)   ACAccountType       *accountType;
//
//// A human readable description of the account.
//// This property is only available to applications that have been granted access to the account by the user.
//@property (nonatomic, copy)     NSString            *accountDescription;
//
//// The username for the account. This property can be set and saved during account creation. The username is
//// only available to applications that have been granted access to the account by the user.
//@property (nonatomic, copy)     NSString            *username;
//
//// The credential for the account. This property can be set and saved during account creation. It is 
//// inaccessible once the account has been saved.
//@property (nonatomic, retain)   ACAccountCredential *credential;

- (void)twitterDidSelectAccount:(ACAccount*)account
{
  self.twitterAccount = account;
  
  NSLog(@"accountDescription %@", account.accountDescription);
  NSLog(@"username %@", account.username);
  NSLog(@"accountDescription %@", account.accountDescription);
  
}








#pragma mark - SA_OAuthTwitterControllerDelegate

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username
{
  NSLog(@"OAuthTwitterController::authenticatedWithUsername '%@'", username);
  [_delegate sessionDidLogin:YES];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller
{
  NSLog(@"OAuthTwitterControllerFailed");
  [_delegate sessionDidLogin:NO];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller
{
  NSLog(@"OAuthTwitterControllerCanceled");
}











#pragma mark - Facebook



//.......................................................................
//
// login using facebook
//
- (void)loginUsingFacebook:(UIViewController*)target
{
  _delegate = target;
  
  _facebook = [[Facebook alloc] initWithAppId:FB_App_Id andDelegate:self];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) 
  {
    _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
    _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    NSLog(@"UserDefault FB token : expiration date %@", _facebook.expirationDate);
  }
  
  if (![_facebook isSessionValid]) 
  {
    NSLog(@"FB authorize dialog.");
    [_facebook authorize:nil];
  }
  else
  {
    NSLog(@"FB Session is still valid.");  
    [_delegate sessionDidLogin:YES];    
  }
}


#pragma mark - FBSessionDelegate

- (void)fbDidLogin 
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
  [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
  [defaults synchronize];  
  
  [_delegate sessionDidLogin:YES];
}

- (void)fbDidLogout
{
  // Remove saved authorization information if it exists
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"FBAccessTokenKey"]) {
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
  }
  
  [_delegate sessionDidLogout];  
}










- (BOOL)handleOpenURL:(NSURL *)url
{
  if (!_facebook)
    return NO;
  
  return [_facebook handleOpenURL:url];
}

  







@end
