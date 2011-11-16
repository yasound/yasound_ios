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



@implementation TwitterSessionManager

@synthesize iosManager = _iosManager;
@synthesize  oauthManager = _oauthManager;







#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)






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



- (void)logout
{
  if (_iosManager)
    [_iosManager logout];
  else
    [_oauthManager logout];
 
}




- (void)login:(UIViewController*)target;
{
  if (_iosManager)
    [_iosManager login:target];
  else
    [_oauthManager login:target];
}












@end
