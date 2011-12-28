//
//  TwitterSessionManager.h
//  inherited from SessionManager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "TwitterSessionManager.h"
#import "SA_OAuthTwitterController.h" 
#import "SA_OAuthTwitterEngine.h"
#import <Accounts/Accounts.h>
#import "TwitterAccountsViewController.h"
#import "Version/Version.h"



//#define FORCE_OAUTH_LIB 1


@implementation TwitterSessionManager

@synthesize iosManager = _iosManager;
@synthesize  oauthManager = _oauthManager;






// Singleton
static TwitterSessionManager* _twitter = nil;

+ (TwitterSessionManager*)twitter;
{
  if (!_twitter)
  {
    _twitter = [[TwitterSessionManager alloc] init];
  }
  
  return _twitter;
}



- (id)init
{
  self = [super init];
  if (self)
  {
    _iosManager = nil;
    _oauthManager = nil;

#ifdef FORCE_OAUTH_LIB
    
    _oauthManager = [[TwitterOAuthSessionManager alloc] init];
    
#else
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) 
      _iosManager = [[TwitteriOSSessionManager alloc] init];
    else
      _oauthManager = [[TwitterOAuthSessionManager alloc] init];
    
#endif
    
  }
  return self;
}


- (void)dealloc
{
  if (_iosManager)
    [_iosManager release]; 
  else
    [_oauthManager release]; 
  
  [super dealloc];
}




- (BOOL)authorized
{
  if (_iosManager)
    return _iosManager.authorized;
  else
    return _oauthManager.authorized;
}



- (void)setTarget:(id<SessionDelegate>)delegate
{
  self.delegate = delegate;

  if (_iosManager)
    [_iosManager setTarget:delegate];
  else
    [_oauthManager setTarget:delegate];
}




- (void)logout
{
  if (_iosManager)
    [_iosManager logout];
  else
    [_oauthManager logout];
 
}




- (void)login;
{
  if (_iosManager)
    [_iosManager login];
  else
  {
    UIViewController* parent = self.delegate;
    [_oauthManager login:parent];
  }
}



- (BOOL)requestGetInfo:(SessionRequestType)requestType;
{
  if (_iosManager)
    return [_iosManager requestGetInfo:requestType];
  else
    return [_oauthManager requestGetInfo:requestType];  
}



- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl
{
  if (_iosManager)
    return [_iosManager requestPostMessage:message title:title picture:pictureUrl];
  else
    return [_oauthManager requestPostMessage:message title:title picture:pictureUrl];  
}












@end
