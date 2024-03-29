//
//  TwitterOAuthSessionManager.h
//  OAuth twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//


#import "TwitterOAuthSessionManager.h"
#import "Security/SFHFKeychainUtils.h"
#import "UserSettings.h"

#import "YasoundAppDelegate.h"


//LBDEBUG ICI
#ifdef USE_DEV_SERVER
#define kOAuthConsumerKey @"iLkxaRcY8QKku0UhaMvPQ"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"rZYlrG4KXIat3nNJ3U8qXniQBSkJu8PjI1v7sCTHg"     //REPLACE With Twitter App OAuth Secret  
#else
#define kOAuthConsumerKey @"bvpS9ZEO6REqL96Sjuklg"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"TMdhQbWXarXoxkjwSdUbTif5CyapHLfcAdYfTnTOmc"     //REPLACE With Twitter App OAuth Secret  
#endif



@implementation TwitterOAuthSessionManager



+ (NSString*) oauthConsumerKeyForYasound
{
    return [NSString stringWithString:kOAuthConsumerKey];
}

+ (NSString*) oauthConsumerSecretForYasound
{
    return [NSString stringWithString:kOAuthConsumerSecret];    
}


- (void)setTarget:(id<SessionDelegate>)delegate
{
  self.delegate = delegate;
}


- (void)login:(UIViewController*)parent
{
  _parent = parent;
  _isLoging = YES;
  
  if (!_engine)
  {  
#ifdef USE_DEV_SERVER
      DLog(@"TwitterOAuthSessionManager linked to DEV SERVER : id %@.", kOAuthConsumerKey);
#else
      DLog(@"TwitterOAuthSessionManager linked to PRODUCTION SERVER : id %@.", kOAuthConsumerKey);
#endif      
      
      
    _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
    _engine.consumerKey    = kOAuthConsumerKey;  
    _engine.consumerSecret = kOAuthConsumerSecret;  
  }  
  
    if(![_engine isAuthorized])
    {  
        _controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];  
        if (!_controller)
          return;

        _controller.delegate = self;
    
        [APPDELEGATE.navigationController presentModalViewController:_controller animated:YES];
        
    }
}



- (void)logout
{
  _isLoging = NO;

    [self invalidConnexion];
  
  [self.delegate sessionDidLogout];  
}



- (void)invalidConnexion
{
    // clean credentials
    NSString* username = [[UserSettings main] objectForKey:USKEYtwitterOAuthUsername];
    NSString* token = [[UserSettings main] objectForKey:USKEYtwitterOAuthToken];
    
    [[UserSettings main] removeObjectForKey:USKEYtwitterOAuthUsername];
    [[UserSettings main] removeObjectForKey:USKEYtwitterOAuthScreenname];
    [[UserSettings main] removeObjectForKey:USKEYtwitterOAuthUserId];
    [[UserSettings main] removeObjectForKey:USKEYtwitterOAuthToken];
    
    // credentials are not stored in UserSettings, for security reason. Go to KeyChain.
    
    NSError* error;
    NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    [SFHFKeychainUtils deleteItemForUsername:username andServiceName:BundleName error:&error];
    
    [SFHFKeychainUtils deleteItemForUsername:token andServiceName:BundleName error:nil];
    
    
    if (_engine)
    {
        [_engine clearAccessToken];
        [_engine clearsCookies];
        
        [_engine release];
        _engine=nil;  
    }

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
  
  if (requestType == SRequestInfoUser)
  {
      NSString* username = [[UserSettings main] objectForKey:USKEYtwitterOAuthUsername];
      NSString* userid = [[UserSettings main] objectForKey:USKEYtwitterOAuthUserId];
      NSString* userscreenname = [[UserSettings main] objectForKey:USKEYtwitterOAuthScreenname];

    
    NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
    [user setValue:userid forKey:DATA_FIELD_ID];
    [user setValue:@"twitter" forKey:DATA_FIELD_TYPE];
      
      NSString* token = [[UserSettings main] objectForKey:USKEYtwitterOAuthToken];
      
      NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
      NSString* tokenSecret = [SFHFKeychainUtils getPasswordForUsername:token andServiceName:BundleName error:nil];
      
      [user setValue:token forKey:DATA_FIELD_TOKEN];
      [user setValue:tokenSecret forKey:DATA_FIELD_TOKEN_SECRET];

    [user setValue:username forKey:DATA_FIELD_USERNAME];
    [user setValue:userscreenname forKey:DATA_FIELD_NAME];
      
      //twitter doesn't provide the user's email, event if he's authenticated
      [user setValue:@"" forKey:DATA_FIELD_EMAIL];
      
    
    NSArray* data = [NSArray arrayWithObjects:user, nil];

    [self.delegate requestDidLoad:SRequestInfoUser data:data];
    return YES;
  }
  
  if (requestType == SRequestInfoFriends)
  {
      NSString* username = [[UserSettings main] objectForKey:USKEYtwitterOAuthUsername];
    _requestFriends = [_engine getRecentlyUpdatedFriendsFor:username startingAtPage:0];
    // get the response in userInfoReceived delegate, below
    return YES;
  }

  if (requestType == SRequestInfoFollowers)
  {
    _requestFollowers = [_engine getFollowersIncludingCurrentStatus:YES];
    // get the response in userInfoReceived delegate, below
    return YES;
  }
  
  return NO;

}


- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl
{
  _requestPost = [_engine sendUpdate:message];
  return TRUE;
}


- (void)enableUpdatesFor:(NSString *)username
{
  NSString* res = [_engine enableUpdatesFor:username];
  NSLog(@"Follow twitter user %@: %@\n", username, res);
}













#pragma mark - SA_OAuthTwitterEngineDelegate

- (void)parseUserInfo:(NSString*)data
{
  NSInteger length = [data length];
  NSRange range = NSMakeRange(0, length);
  
  
  //.....................................................................
  //
  // parse oauth_token and oauth_token_secret
  //
  NSRange begin = [data rangeOfString:@"oauth_token=" options:NSLiteralSearch range:range];
  if (begin.location == NSNotFound)
  {
    DLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  NSRange end = [data rangeOfString:@"&oauth_token_secret=" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    DLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  //.....................................................................
  //
  // extract and store
  //
  NSString* oauth_token = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
  begin = end;
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  end = [data rangeOfString:@"&" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    DLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  NSString* oauth_token_secret = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
  //LBDEBUG
  assert (oauth_token != nil);
    [[UserSettings main] setObject:oauth_token forKey:USKEYtwitterOAuthToken];
    

    assert (oauth_token_secret != nil);
    NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    [SFHFKeychainUtils storeUsername:oauth_token andPassword:oauth_token_secret  forServiceName:BundleName updateExisting:YES error:nil];

    
  
  //.....................................................................
  //
  // parse userid
  //
  
  begin = [data rangeOfString:@"user_id=" options:NSLiteralSearch range:range];
  if (begin.location == NSNotFound)
  {
    DLog(@"TwitterOAuthSession warning : no userid has been parsed. May be normal.");
    return;
  }
  
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  end = [data rangeOfString:@"&" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    assert(0);
    DLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  // extract user id
  NSString* userid = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
  // store it
    [[UserSettings main] setObject:userid forKey:USKEYtwitterOAuthUserId];
  
  
  
  //.....................................................................
  //
  // parse user screen name
  //
  
  range = NSMakeRange(end.location + end.length, length - (end.location + end.length));
  
  begin = [data rangeOfString:@"screen_name=" options:NSLiteralSearch range:range];
  if (begin.location == NSNotFound)
  {
    assert(0);
    DLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  end = [data rangeOfString:@"&" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
      end.location = data.length;
  }
  
  // extract user screen name
  NSString* screenname = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
  // store it
    [[UserSettings main] setObject:screenname forKey:USKEYtwitterOAuthScreenname];
  
}




//implement these methods to store off the creds returned by Twitter
- (void) storeCachedTwitterOAuthData: (NSString *)data forUsername: (NSString *) username
{
   DLog(@"storeCachedTwitterOAuthData   data '%@'   username '%@'", data, username);
  
  if (!_isLoging)
    return;

  // store the credentials for later access
    [[UserSettings main] setObject:username forKey:USKEYtwitterOAuthUsername];
  
  
  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
  // secret credentials are NOT saved in the User Settings, for security reason. Prefer KeyChain.
  [SFHFKeychainUtils storeUsername:username andPassword:data  forServiceName:BundleName updateExisting:YES error:&error];
  
  // parse the credentials, to store the user info
  [self parseUserInfo:data];
}



+ (NSString*) buildDataFromToken:(NSString*)token token_secret:(NSString*)token_secret user_id:(NSString*)user_id screen_name:(NSString*)screen_name
{
    return [NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@&user_id=%@&screen_name=%@",
            token, token_secret, user_id, screen_name];
}





	//if you don't do this, the user will have to re-authenticate every time they run
- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username
{
    
  // username parameter is broken (<=> nil) with iOS 5.
  // this issue is known on Twitter-OAuth-iPhone github.
  // => get the username from the User Settings, instead
    NSString* __username = username;
    if (__username == nil)
        __username = [[UserSettings main] objectForKey:USKEYtwitterOAuthUsername];

  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];

  // credentials have been stored in KeyChain, for security reason
  NSString* data = [SFHFKeychainUtils getPasswordForUsername:__username andServiceName:BundleName error:&error];
    
    
  
//  DLog(@"username %@", __username);
//  DLog(@"data %@", data);
  
  // warn the calling process that we have the credentials and that it can be considered itself as logged.
  if (_isLoging && (data != nil))
      [self performSelectorOnMainThread:@selector(onTwitterCredentialsRetrieved:) withObject:data waitUntilDone:FALSE];
  
  return data;
}




- (void) twitterOAuthConnectionFailedWithData: (NSData *) data
{
    DLog(@"twitterOAuthConnectionFailedWithData");
    DLog(@"data %@", data);
    
  [self.delegate sessionLoginFailed];
}



- (void)onTwitterCredentialsRetrieved:(NSString*)data
{
    if (data == nil)
        DLog(@"onTwitterCredentialsRetrieved data nil!");
    else if (data.length == 0)
        DLog(@"onTwitterCredentialsRetrieved data empty!");
    
    BOOL res = ((data != nil) && (data.length > 0));
    [self.delegate sessionDidLogin:res];
}





#pragma mark - SA_OAuthTwitterControllerDelegate

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username
{
  DLog(@"OAuthTwitterController::authenticatedWithUsername '%@'", username);
  _isLoging = NO;
    
  [self.delegate sessionDidLogin:YES];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller
{
  DLog(@"OAuthTwitterControllerFailed");
  _isLoging = NO;
  [self.delegate sessionLoginFailed];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller
{
  _isLoging = NO;
  [self.delegate sessionLoginCanceled];
  DLog(@"OAuthTwitterControllerCanceled");
}

- (void)credentialFailed:(SA_OAuthTwitterController *) controller
{
    // why is this delegate called? I don't know, but everything works if you just ignore it....
    
//    DLog(@"credentialFailed");
//    _isLoging = NO;
//    [self.delegate sessionLoginFailed];
}




#pragma mark - XAuthTwitterEngineDelegate

- (void)userInfoReceived:(NSArray*)userInfo forRequest:(NSString *)connectionIdentifier
{
  //    DLog(@"\nuserInfoReceived\n---------------------\n");
  //    DLog(@"TwitterOAuthSessionManager userInfoReceived %@", userInfo);

  bool isRequestFriends = [connectionIdentifier isEqualToString:_requestFriends];
  bool isRequestFollowers = [connectionIdentifier isEqualToString:_requestFollowers];
  
  if (isRequestFriends || isRequestFollowers)
  {
    _requestFriends = nil;
    _requestFollowers = nil;
    
    NSMutableArray* data = [[NSMutableArray alloc] init];
    for (NSDictionary* user in userInfo)
    {
      NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
      [userInfo setValue:[user valueForKey:@"id"] forKey:DATA_FIELD_ID];
      [userInfo setValue:@"twitter" forKey:DATA_FIELD_TYPE];
      [userInfo setValue:[user valueForKey:@"screen_name"] forKey:DATA_FIELD_USERNAME]; // no username directly available from this list
      [userInfo setValue:[user valueForKey:@"name"] forKey:DATA_FIELD_NAME];
      
      [data addObject:userInfo];
    }
    
    SessionRequestType requestType = (isRequestFriends)? SRequestInfoFriends : SRequestInfoFollowers;
    [self.delegate requestDidLoad:requestType data:data];

    return;
  }
  
}


- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
  if ([connectionIdentifier isEqualToString:_requestPost])
  {
    _requestPost = nil;

    DLog(@"statusesReceived");
    [self.delegate requestDidLoad:SRequestPostMessage data:nil];
  }
}





@end
