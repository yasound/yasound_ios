//
//  TwitterOAuthSessionManager.h
//  OAuth twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//


#import "TwitterOAuthSessionManager.h"


#define kOAuthConsumerKey @"lm6cEvevtSlX1IwFL3ZM4w"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"bEDK1Un5srTcDeuX6crBkihu4pmb96aaMgJnOzD3VRY"     //REPLACE With Twitter App OAuth Secret  




@implementation TwitterOAuthSessionManager





- (void)login:(UIViewController*)target
{
  self.delegate = target;
  
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
    [self.delegate presentModalViewController:controller animated: YES];  
  }  
}



- (void)logout
{
  if (_engine)
  {
    [_engine clearAccessToken];
    [_engine clearsCookies];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authData"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"authName"];
    
    //    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authName"]);
    //    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authData"]);
    
    [_engine release];
    _engine=nil;  
    
    [self.delegate sessionDidLogout];  
    
    return;
  }
}




- (BOOL)authorized
{
  if (_engine == nil)
    return NO;
  
  return [_engine isAuthorized];
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
  [self.delegate sessionDidLogin:NO];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller
{
  NSLog(@"OAuthTwitterControllerCanceled");
}




@end
