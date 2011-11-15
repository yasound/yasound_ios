//
//  SessionManager.h
//  online login management
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "SessionManager.h"


@implementation SessionManager

@synthesize delegate;
@synthesize authorized;


// consumer key, consumer secre, fb app id and secret, are based on app "neywenTest"

#define kOAuthConsumerKey @"lm6cEvevtSlX1IwFL3ZM4w"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"bEDK1Un5srTcDeuX6crBkihu4pmb96aaMgJnOzD3VRY"     //REPLACE With Twitter App OAuth Secret  

#define FB_App_Id @"136849886422778"
#define DB_APP_Secret @"bcaadff05c7c07d36d38155d6b35088c"



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
    
    [self.delegate sessionDidLogout];  
    
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
- (UIViewController*)loginUsingTwitter
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
      return nil;
    
    controller.delegate = self;
    return controller;
  }  
}








#pragma mark - SA_OAuthTwitterControllerDelegate

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username
{
  NSLog(@"OAuthTwitterController::authenticatedWithUsername '%@'", username);
  [self.delegate sessionDidLogin:YES];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller
{
  NSLog(@"OAuthTwitterControllerFailed");
  [self.delegate sessionDidLogin:NO];
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
- (void)loginUsingFacebook
{
  _facebook = [[Facebook alloc] initWithAppId:FB_App_Id andDelegate:self];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) 
  {
    _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
    _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
  }
  
  if (![_facebook isSessionValid]) 
    [_facebook authorize:nil];
}


#pragma mark - FBSessionDelegate

- (void)fbDidLogin 
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
  [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
  [defaults synchronize];  
  
  [self.delegate sessionDidLogin:YES];
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
  
  [self.delegate sessionDidLogout];  
}










- (BOOL)handleOpenURL:(NSURL *)url
{
  if (!_facebook)
    return NO;
  
  return [_facebook handleOpenURL:url];
}

  







@end
