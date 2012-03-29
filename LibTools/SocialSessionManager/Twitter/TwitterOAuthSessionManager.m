//
//  TwitterOAuthSessionManager.h
//  OAuth twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//


#import "TwitterOAuthSessionManager.h"
#import "Security/SFHFKeychainUtils.h"
#import "YasoundAppDelegate.h"


#ifdef USE_DEV_SERVER
#define kOAuthConsumerKey @"iLkxaRcY8QKku0UhaMvPQ"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"rZYlrG4KXIat3nNJ3U8qXniQBSkJu8PjI1v7sCTHg"     //REPLACE With Twitter App OAuth Secret  
#else
#define kOAuthConsumerKey @"bvpS9ZEO6REqL96Sjuklg"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"TMdhQbWXarXoxkjwSdUbTif5CyapHLfcAdYfTnTOmc"     //REPLACE With Twitter App OAuth Secret  
#endif




@implementation TwitterOAuthSessionManager



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
      NSLog(@"TwitterOAuthSessionManager linked to DEV SERVER : id %@.", kOAuthConsumerKey);
#else
      NSLog(@"TwitterOAuthSessionManager linked to PRODUCTION SERVER : id %@.", kOAuthConsumerKey);
#endif      
      
      
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
    
        YasoundAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        NSArray* viewControllers = appDelegate.navigationController.childViewControllers;
        UIViewController* viewController = [viewControllers objectAtIndex:(viewControllers.count-1)];
      
        //LBDEBUG ICI //parent
        [viewController presentModalViewController:controller animated: YES];  
    }  
}



- (void)logout
{
  _isLoging = NO;
  
  // clean credentials
  NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_USERNAME];
  
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:OAUTH_USERNAME];
  
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
  
  if (requestType == SRequestInfoUser)
  {
    NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_USERNAME];
    NSString* userid = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_USERID];
    NSString* userscreenname = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_SCREENNAME];
    
    NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
    [user setValue:userid forKey:DATA_FIELD_ID];
    [user setValue:@"twitter" forKey:DATA_FIELD_TYPE];
      [user setValue:[[NSUserDefaults standardUserDefaults] objectForKey:DATA_FIELD_TOKEN] forKey:DATA_FIELD_TOKEN];
      [user setValue:[[NSUserDefaults standardUserDefaults] objectForKey:DATA_FIELD_TOKEN_SECRET] forKey:DATA_FIELD_TOKEN_SECRET];
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
    NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_USERNAME];
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
    NSLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  NSRange end = [data rangeOfString:@"&oauth_token_secret=" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    NSLog(@"TwitterOAuthSession Manager data parsing error!");
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
    NSLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  NSString* oauth_token_secret = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
  //LBDEBUG
  assert (oauth_token != nil);
  [[NSUserDefaults standardUserDefaults] setValue:oauth_token forKey:DATA_FIELD_TOKEN];
  assert (oauth_token_secret != nil);
  [[NSUserDefaults standardUserDefaults] setValue:oauth_token_secret forKey:DATA_FIELD_TOKEN_SECRET];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  //  NSLog(@"oauth_token %@", oauth_token);
  
  //  NSLog(@"oauth_token_secret %@", oauth_token_secret);
  
  
  //.....................................................................
  //
  // parse userid
  //
  
  begin = [data rangeOfString:@"user_id=" options:NSLiteralSearch range:range];
  if (begin.location == NSNotFound)
  {
    NSLog(@"TwitterOAuthSession warning : no userid has been parsed. May be normal.");
    return;
  }
  
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  end = [data rangeOfString:@"&" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    assert(0);
    NSLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  // extract user id
  NSString* userid = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
  // store it
  [[NSUserDefaults standardUserDefaults] setValue:userid forKey:OAUTH_USERID];
  
  
  
  //.....................................................................
  //
  // parse user screen name
  //
  
  range = NSMakeRange(end.location + end.length, length - (end.location + end.length));
  
  begin = [data rangeOfString:@"screen_name=" options:NSLiteralSearch range:range];
  if (begin.location == NSNotFound)
  {
    assert(0);
    NSLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  end = [data rangeOfString:@"&" options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    assert(0);
    NSLog(@"TwitterOAuthSession Manager data parsing error!");
    return;
  }
  
  // extract user screen name
  NSString* screenname = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
  
  // store it
  [[NSUserDefaults standardUserDefaults] setValue:screenname forKey:OAUTH_SCREENNAME];
  
  
  
  
  
}


//implement these methods to store off the creds returned by Twitter
- (void) storeCachedTwitterOAuthData: (NSString *)data forUsername: (NSString *) username
{
   NSLog(@"storeCachedTwitterOAuthData   data '%@'   username '%@'", data, username);
  
  if (!_isLoging)
    return;

  // store the credentials for later access
  [[NSUserDefaults standardUserDefaults] setValue:username forKey:OAUTH_USERNAME];
  
  
  
  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
  // secret credentials are NOT saved in the UserDefaults, for security reason. Prefer KeyChain.
  [SFHFKeychainUtils storeUsername:username andPassword:data  forServiceName:BundleName updateExisting:YES error:&error];
  
  // parse the credentials, to store the user info
  [self parseUserInfo:data];
}








	//if you don't do this, the user will have to re-authenticate every time they run
- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username
{
  // username parameter is broken (<=> nil) with iOS 5.
  // this issue is known on Twitter-OAuth-iPhone github.
  // => get the username from the UserDefaults, instead
  NSString* __username = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_USERNAME];

  NSError* error;
  NSString* BundleName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];

  // credentials have been stored in KeyChain, for security reason
  NSString* data = [SFHFKeychainUtils getPasswordForUsername:__username andServiceName:BundleName error:&error];
  
//  NSLog(@"username %@", __username);
//  NSLog(@"data %@", data);
  
  // warn the calling process that we have the credentials and that it can be considered itself as logged.
  if (_isLoging && (data != nil))
    [self performSelectorOnMainThread:@selector(onTwitterCredentialsRetrieved) withObject:nil waitUntilDone:FALSE];
  
  return data;
}




- (void) twitterOAuthConnectionFailedWithData: (NSData *) data
{
    NSLog(@"twitterOAuthConnectionFailedWithData");
    NSLog(@"data %@", data);
    
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
  _isLoging = NO;
  [self.delegate sessionDidLogin:YES];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller
{
  NSLog(@"OAuthTwitterControllerFailed");
  _isLoging = NO;
  [self.delegate sessionLoginFailed];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller
{
  _isLoging = NO;
  NSLog(@"OAuthTwitterControllerCanceled");
}





#pragma mark - XAuthTwitterEngineDelegate

- (void)userInfoReceived:(NSArray*)userInfo forRequest:(NSString *)connectionIdentifier
{
  //    NSLog(@"\nuserInfoReceived\n---------------------\n");
  //    NSLog(@"%@", userInfo);

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

    NSLog(@"statusesReceived");
    [self.delegate requestDidLoad:SRequestPostMessage data:nil];
  }
}





@end
