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




- (BOOL)requestGetInfo:(NSString*)requestTag
{
  if (!_facebookConnect)
    return NO;
  
  if ([requestTag isEqualToString:REQUEST_TAG_USERNAME])
    _requestMe = [_facebookConnect requestWithGraphPath:@"me" andDelegate:self];
  
  return YES;
}


- (BOOL)requestFriendList
{

}


- (BOOL)requestPostMessage:(NSString*)message
{

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

//- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
//{
//  
//}


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{

}

- (void)request:(FBRequest *)request didLoad:(id)result
{
  if (request == _requestMe)
  {
    NSDictionary* dico = result;
    [self.delegate requestDidLoad:REQUEST_TAG_USERNAME data:dico];
    return;
  }
  


  
}



- (BOOL)handleOpenURL:(NSURL *)url
{
  return [_facebookConnect handleOpenURL:url];
}

  







@end
