//
//  TwitterOAuthSessionManager.h
//  OAuth twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//


#import "TwitterOAuthSessionManager.h"
#import "SFHFKeychainUtils.h"


#define kOAuthConsumerKey @"lm6cEvevtSlX1IwFL3ZM4w"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"bEDK1Un5srTcDeuX6crBkihu4pmb96aaMgJnOzD3VRY"     //REPLACE With Twitter App OAuth Secret  

#define AUTH_NAME @"authName"


@implementation TwitterOAuthSessionManager





- (void)login:(UIViewController*)target
{
  self.delegate = target;
  
  if (!_engine)
  {  
    _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
    _engine.consumerKey    = kOAuthConsumerKey;  
    _engine.consumerSecret = kOAuthConsumerSecret;  
  }  
  
  if(![_engine isAuthorized])
  {  
    SA_OAuthTwitterController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];  
    if (!controller)
      return;
    
    controller.delegate = self;
    [self.delegate presentModalViewController:controller animated: YES];  
  }  
}



- (void)logout
{
  if (_engine)
  {
    [_engine clearAccessToken];
    [_engine clearsCookies];

    NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:AUTH_NAME];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AUTH_NAME];
    
    // credentials are not stored in UserDefaults, for security reason. Go to KeyChain.
    //[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"authName"];
    
    NSError* error;
    NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    [SFHFKeychainUtils deleteItemForUsername:username andServiceName:BundleName error:&error];

    [_engine release];
    _engine=nil;  
    
    [self.delegate sessionDidLogout];  
    
    return;
  }
}




- (BOOL)authorized
{
  if (_engine == nil)
    return NO;
  
  return [_engine isAuthorized];
}



#pragma mark - SA_OAuthTwitterEngineDelegate


//implement these methods to store off the creds returned by Twitter
- (void) storeCachedTwitterOAuthData: (NSString *)data forUsername: (NSString *) username
{
  // NSLog(@"storeCachedTwitterOAuthData   data '%@'   username '%@'", data, username);
  
  // store the credentials for later access
  [[NSUserDefaults standardUserDefaults] setValue:username forKey:AUTH_NAME];
  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
  // secret credentials are NOT saved in the UserDefaults, for security reason. Prefer KeyChain.
  [SFHFKeychainUtils storeUsername:username andPassword:data  forServiceName:BundleName updateExisting:YES error:&error];
}





	//if you don't do this, the user will have to re-authenticate every time they run
- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username
{
  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];

  // credentials have been stored in KeyChain, for security reason
  return [SFHFKeychainUtils getPasswordForUsername:username andServiceName:BundleName error:&error];
}




- (void) twitterOAuthConnectionFailedWithData: (NSData *) data
{
  NSLog(@"twitterOAuthConnectionFailedWithData");
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




@end
