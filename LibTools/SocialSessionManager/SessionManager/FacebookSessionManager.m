//
//  FacebookSessionManager.h
//  inherited from SessionManager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "FacebookSessionManager.h"



@implementation FacebookSessionManager

@synthesize facebookConnect = _facebookConnect;


#define FB_App_Id @"296167703762159"
#define DB_APP_Secret @"af4d20f383ed42cabfb4bf4b960bb03f"










// Singleton
static FacebookSessionManager* _facebook = nil;

+ (FacebookSessionManager*)facebook;
{
  if (!_facebook)
  {
    _facebook = [[FacebookSessionManager alloc] init];
  }
  
  return _facebook;
}



- (id)init
{
  self = [super init];
  if (self)
  {
    _facebookConnect = nil;
//    _facebookPermissions = [[NSArray arrayWithObjects:@"user_about_me", @"publish_stream", @"publish_actions", @"offline_access", nil] retain];    
    _facebookPermissions = [[NSArray arrayWithObjects:@"user_about_me", @"publish_stream", @"offline_access", nil] retain];    
  }
  return self;
}


- (void)dealloc
{
  [_facebookConnect release]; 
  [super dealloc];
}






- (BOOL)authorized
{
  return [_facebookConnect isSessionValid];
}






#pragma mark - Facebook


- (void)setTarget:(id<SessionDelegate>)delegate
{
  self.delegate = delegate;
}


//.......................................................................
//
// login using facebook
//
- (void)login
{
  _facebookConnect = [[Facebook alloc] initWithAppId:FB_App_Id andDelegate:self];
    
 //   [_facebookConnect authorizeWithFBAppAuth:YES safariAuth:NO];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) 
  {
    _facebookConnect.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
    _facebookConnect.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
//    NSLog(@"UserDefault FB token : expiration date %@", _facebookConnect.expirationDate);
  }
  
  if (![_facebookConnect isSessionValid]) 
  {
    [_facebookConnect authorize:_facebookPermissions];
  }
  else
  {
//    NSLog(@"FB Session is still valid.");  
    [self.delegate sessionDidLogin:YES];    
  }
}




- (void)logout
{
  [_facebookConnect logout:self];
}




- (BOOL)requestGetInfo:(SessionRequestType)requestType
{
  if (!_facebookConnect)
    return NO;
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  
  if (requestType == SRequestInfoUser)
  {
    _requestMe = [_facebookConnect requestWithGraphPath:@"me" andDelegate:self];
    return YES;
  }
  
  if (requestType == SRequestInfoFriends)
  {
    _requestFriends = [_facebookConnect requestWithGraphPath:@"me/friends" andDelegate:self];
    return YES;
  }
  
  return YES;
}




- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl link:(NSURL*)link
{
  if (!_facebookConnect)
    return NO;

//  NSLog(@"POST MESSAGE : %@", message);
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  
  NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
  
  if (pictureUrl == nil)
  {
    [params setObject:@"status" forKey:@"type"];
    if (title)
      [params setObject:title forKey:@"name"];
    [params setObject:message forKey:@"message"];
  }
  else
  {
    [params setObject:@"status" forKey:@"type"];
    if (title)
      [params setObject:title forKey:@"name"];
    [params setObject:[pictureUrl absoluteString] forKey:@"picture"];
    [params setObject:message forKey:@"description"];
  }

  if (link)
  {
      [params setObject:[link absoluteString] forKey:@"link"];
  }
    
  _requestFeed = [_facebookConnect requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST"  andDelegate:self];  
  // get feedback in didLoad delegate
  
  return YES;
}










#pragma mark - FBSessionDelegate

- (void)fbDidLogin 
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[_facebookConnect accessToken] forKey:@"FBAccessTokenKey"];
  [defaults setObject:[_facebookConnect expirationDate] forKey:@"FBExpirationDateKey"];
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






#pragma mark - FBRequestDelegate

//- (void)requestLoading:(FBRequest *)request
//{
//  NSLog(@"requestLoading");
//}
//
//- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
//{
//  NSLog(@"didReceiveResponse");
//}


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

  NSLog(@"didFailWithError : %@", [error localizedDescription]);
  NSLog(@"Err details: %@", [error description]);
  
  SessionRequestType requestType;
  if (request == _requestMe)
    requestType = SRequestInfoUser;
  else if (request == _requestFriends)
    requestType = SRequestInfoFriends;
  else if (request == _requestFeed)
    requestType = SRequestPostMessage;
  
  [self.delegate requestDidFailed:requestType error:error errorMessage:nil];
}




- (void)request:(FBRequest *)request didLoad:(id)result
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  //NSLog(@"Parsed Response: %@", result);
  
  if (request == _requestMe)
  {
    NSDictionary* dico = result;
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    
    NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
      [user setValue:[dico valueForKey:@"id"] forKey:DATA_FIELD_ID];
      [user setValue:[defaults objectForKey:@"FBAccessTokenKey"] forKey:DATA_FIELD_TOKEN];
    [user setValue:@"facebook" forKey:DATA_FIELD_TYPE];
    [user setValue:[dico valueForKey:@"username"] forKey:DATA_FIELD_USERNAME];
      [user setValue:[dico valueForKey:@"name"] forKey:DATA_FIELD_NAME];
      
      NSString* email = [dico valueForKey:@"email"];
      //LBDEBUG EMAIL
      NSLog(@"facebook email '%@'", email);
      [user setValue:email forKey:DATA_FIELD_EMAIL];
    
    NSArray* data = [NSArray arrayWithObjects:user, nil];
    
    [self.delegate requestDidLoad:SRequestInfoUser data:data];
    return;
  }
  
  if (request == _requestFriends)
  {
    NSArray* friends = [result objectForKey:@"data"];
    
    NSMutableArray* data = [[NSMutableArray alloc] init];
    for (NSDictionary* friend in friends)
    {
      NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
      [user setValue:[friend valueForKey:@"id"] forKey:DATA_FIELD_ID];
      [user setValue:@"facebook" forKey:DATA_FIELD_TYPE];
      [user setValue:@"" forKey:DATA_FIELD_USERNAME]; // no username directly available from this list
      [user setValue:[friend valueForKey:@"name"] forKey:DATA_FIELD_NAME];

      [data addObject:user];
    }
    
    [self.delegate requestDidLoad:SRequestInfoFriends data:data];
    return;
  }
  
  if (request == _requestFeed)
  {
    [self.delegate requestDidLoad:SRequestPostMessage data:nil];
    return;
  }
}


  


- (BOOL)handleOpenURL:(NSURL *)url
{
  return [_facebookConnect handleOpenURL:url];
}

  







@end
