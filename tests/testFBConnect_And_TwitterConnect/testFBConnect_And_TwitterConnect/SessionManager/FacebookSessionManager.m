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


#define FB_App_Id @"136849886422778"
#define DB_APP_Secret @"bcaadff05c7c07d36d38155d6b35088c"










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
    _facebookPermissions = [[NSArray arrayWithObjects:@"user_about_me", @"publish_stream", nil] retain];    
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
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) 
  {
    _facebookConnect.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
    _facebookConnect.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
//    NSLog(@"UserDefault FB token : expiration date %@", _facebookConnect.expirationDate);
  }
  
  if (![_facebookConnect isSessionValid]) 
  {
//    NSLog(@"FB authorize dialog.");
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
  
  if (requestType == SRequestInfoUsername)
  {
    _requestMe = [_facebookConnect requestWithGraphPath:@"me" andDelegate:self];
    return;
  }
  
  if (requestType == SRequestInfoFriends)
  {
    _requestFriends = [_facebookConnect requestWithGraphPath:@"me/friends" andDelegate:self];
    return;
  }
  
  return YES;
}




- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl
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
  
  _requestFeed = [_facebookConnect requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST"  andDelegate:self];  
  
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
    requestType = SRequestInfoUsername;
  else if (request == _requestFriends)
    requestType = SRequestInfoFriends;
  else if (request == _requestFeed)
    requestType = SRequestPostMessage;
  
  [self.delegate requestDidFailed:requestType error:error];
}




- (void)request:(FBRequest *)request didLoad:(id)result
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  //NSLog(@"Parsed Response: %@", result);
  
  if (request == _requestMe)
  {
    NSDictionary* dico = result;
    
    NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
    [user setValue:[dico valueForKey:@"id"] forKey:DATA_FIELD_ID];
    [user setValue:@"facebook" forKey:DATA_FIELD_TYPE];
    [user setValue:[dico valueForKey:@"username"] forKey:DATA_FIELD_USERNAME];
    [user setValue:[dico valueForKey:@"name"] forKey:DATA_FIELD_NAME];
    
    NSArray* data = [NSArray arrayWithObjects:user, nil];
    
    [self.delegate requestDidLoad:SRequestInfoUsername data:data];
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
