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
  _isLoging = YES;
  
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
  
  if (requestType == SRequestInfoUsername)
  {
    NSString* username = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_USERNAME];
    NSString* userid = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_USERID];
    NSString* userscreenname = [[NSUserDefaults standardUserDefaults] valueForKey:OAUTH_SCREENNAME];
    
    NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
    [user setValue:userid forKey:DATA_FIELD_ID];
    [user setValue:@"twitter" forKey:DATA_FIELD_TYPE];
    [user setValue:username forKey:DATA_FIELD_USERNAME];
    [user setValue:userscreenname forKey:DATA_FIELD_NAME];
    
    NSArray* data = [NSArray arrayWithObjects:user, nil];

    [self.delegate requestDidLoad:SRequestInfoUsername data:data];
    return YES;
  }
  
  if (requestType == SRequestInfoFriends)
  {
    _requestFriends = [_engine getFollowersIncludingCurrentStatus:YES];
    // get the response in userInfoReceived delegate, below
    return YES;
  }
  
  return NO;

}

- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl
{
  _requestPost = [_engine sendUpdate:message];
}















#pragma mark - SA_OAuthTwitterEngineDelegate


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



- (void)parseUserInfo:(NSString*)data
{
  NSInteger length = [data length];
  NSRange range = NSMakeRange(0, length);

  //.....................................................................
  //
  // parse userid
  //
  
  NSRange begin = [data rangeOfString:@"user_id=" options:NSLiteralSearch range:range];
  if (begin.location == NSNotFound)
  {
    NSLog(@"TwitterOAuthSession warning : no userid has been parsed. May be normal.");
    return;
  }

  range = NSMakeRange(begin.location + begin.length, length - (begin.location + begin.length));
  NSRange end = [data rangeOfString:@"&" options:NSLiteralSearch range:range];
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
  if ([connectionIdentifier isEqualToString:_requestFriends])
  {
//    NSLog(@"\n---------------------\n");
//    NSLog(@"%@", userInfo);
    
    NSMutableArray* data = [[NSMutableArray alloc] init];
    for (NSDictionary* friend in userInfo)
    {
      NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
      [user setValue:[friend valueForKey:@"id"] forKey:DATA_FIELD_ID];
      [user setValue:@"twitter" forKey:DATA_FIELD_TYPE];
      [user setValue:[friend valueForKey:@"screen_name"] forKey:DATA_FIELD_USERNAME]; // no username directly available from this list
      [user setValue:[friend valueForKey:@"name"] forKey:DATA_FIELD_NAME];
      
      [data addObject:user];
    }
    
    [self.delegate requestDidLoad:SRequestInfoFriends data:data];

    
    return;
  }
  

  if ([connectionIdentifier isEqualToString:_requestPost])
  {
    NSLog(@"post message request acknowledged");
    NSLog(@"%@", userInfo);
    return;
  }

}


- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
  if ([connectionIdentifier isEqualToString:_requestPost])
  {
    NSLog(@"statusesReceived");
    [self.delegate requestDidLoad:SRequestPostMessage data:nil];
  }
}





@end
