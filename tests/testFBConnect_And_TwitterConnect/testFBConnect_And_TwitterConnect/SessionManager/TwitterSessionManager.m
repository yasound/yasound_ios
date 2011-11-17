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

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) 
      _iosManager = [[TwitteriOSSessionManager alloc] init];
    else
      _oauthManager = [[TwitterOAuthSessionManager alloc] init];
    
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
    [_oauthManager login:self.delegate];
}



- (BOOL)requestGetInfo:(NSString*)requestTag;
{
  if (_iosManager)
    return [_iosManager requestGetInfo:requestTag];
  else
    return [_oauthManager requestGetInfo:requestTag];  
}



- (BOOL)requestPostMessage:(NSString*)message
{
  if (_iosManager)
    return [_iosManager requestPostMessage:message];
  else
    return [_oauthManager requestPostMessage:message];  
}












@end
