//
//  TwitterOAuthSessionManager.h
//  OAuth twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//


#import "TwitterOAuthSessionManager.h"
#import "Security/SFHFKeychainUtils.h"


#define kOAuthConsumerKey @"lm6cEvevtSlX1IwFL3ZM4w"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"bEDK1Un5srTcDeuX6crBkihu4pmb96aaMgJnOzD3VRY"     //REPLACE With Twitter App OAuth Secret  



@implementation TwitterOAuthSessionManager



- (void)setTarget:(id<SessionDelegate>)delegate
{
  self.delegate = delegate;
}


- (void)login:(UIViewController*)parent
{
  _parent = parent;
  
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
    [_parent presentModalViewController:controller animated: YES];  
  }  
}



- (void)logout
{
  // clean credentials
  NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:AUTH_NAME];
  
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:AUTH_NAME];
  
  // credentials are not stored in UserDefaults, for security reason. Go to KeyChain.
  //[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"authName"];
  
  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
  [SFHFKeychainUtils deleteItemForUsername:username andServiceName:BundleName error:&error];

  // clean twitter engine
  if (_engine)
  {
    [_engine clearAccessToken];
    [_engine clearsCookies];

    [_engine release];
    _engine=nil;  
  }
  
  [self.delegate sessionDidLogout];  
}




- (BOOL)authorized
{
  if (_engine == nil)
    return NO;
  
  return [_engine isAuthorized];
}




- (BOOL)requestGetInfo:(SessionRequestType)requestType
{
  if (!_engine || ![_engine isAuthorized])
    return NO;
  
  if (requestType == SRequestInfoUsername)
  {
    NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:AUTH_NAME];
    NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];
    [dico setValue:username forKey:@"username"];
    [self.delegate requestDidLoad:SRequestInfoUsername data:dico];
    return YES;
  }
  
  if (requestType == SRequestInfoFriends)
  {
    _requestFriends = [_engine getFollowersIncludingCurrentStatus:YES];
    return YES;
  }
  
  return NO;

}

- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl
{
//   -(void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier { mFollowerArray	=	nil; mFollowerArray	=	[userInfo retain]; }
}















#pragma mark - SA_OAuthTwitterEngineDelegate


//implement these methods to store off the creds returned by Twitter
- (void) storeCachedTwitterOAuthData: (NSString *)data forUsername: (NSString *) username
{
//   NSLog(@"storeCachedTwitterOAuthData   data '%@'   username '%@'", data, username);
  
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
  // username parameter is broken (<=> nil) with iOS 5.
  // this issue is known on Twitter-OAuth-iPhone github.
  // => get the username from the UserDefaults, instead
  NSString* __username = [[NSUserDefaults standardUserDefaults] valueForKey:AUTH_NAME];

  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];

  // credentials have been stored in KeyChain, for security reason
  NSString* data = [SFHFKeychainUtils getPasswordForUsername:__username andServiceName:BundleName error:&error];
  
//  NSLog(@"username %@", __username);
//  NSLog(@"data %@", data);
  
  // warn the calling process that we have the credentials and that it can be considered itself as logged.
  if (data != nil)
    [self performSelectorOnMainThread:@selector(onTwitterCredentialsRetrieved) withObject:nil waitUntilDone:nil];
  
  return data;
}




- (void) twitterOAuthConnectionFailedWithData: (NSData *) data
{
  NSLog(@"twitterOAuthConnectionFailedWithData");
  [self.delegate sessionLoginFailed];
}



- (void)onTwitterCredentialsRetrieved
{
  [self.delegate sessionDidLogin:YES];
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
  [self.delegate sessionLoginFailed];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller
{
  NSLog(@"OAuthTwitterControllerCanceled");
}





#pragma mark - XAuthTwitterEngineDelegate

- (void)userInfoReceived:(NSArray*)userInfo forRequest:(NSString *)connectionIdentifier
{
  if ([connectionIdentifier isEqualToString:_requestFriends])
  {
    NSLog(@"\n---------------------\n");
    NSLog(@"%@", userInfo);
    
    return;
  }
}




@end
