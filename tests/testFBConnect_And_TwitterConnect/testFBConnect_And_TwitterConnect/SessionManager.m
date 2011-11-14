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
  
  // TODO
  if (_facebook)
    return NO;
  
  return NO;
}



//.......................................................................
//
// login using twitter
//
- (UIViewController*)twitterLoginDialog
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


- (BOOL)loginUsingTwitter:(NSString*)username password:(NSString*)password
{

}




#pragma mark - SA_OAuthTwitterControllerDelegate

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username
{
  NSLog(@"OAuthTwitterController::authenticatedWithUsername '%@'", username);
  [self.delegate loginDidFinish:YES];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller
{
  NSLog(@"OAuthTwitterControllerFailed");
  [self.delegate loginDidFinish:NO];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller
{
  NSLog(@"OAuthTwitterControllerCanceled");
}





//.......................................................................
//
// login using facebook
//
- (void)loginUsingFacebook:(NSString*)username password:(NSString*)password
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




- (BOOL)handleOpenURL:(NSURL *)url
{
  if (!_facebook)
    return NO;
  
  return [_facebook handleOpenURL:url];
}

  







@end
