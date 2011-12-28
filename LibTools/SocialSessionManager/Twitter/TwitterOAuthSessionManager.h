//
//  TwitterOAuthSessionManager.h
//  OAuth twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionManager.h"
#import "SA_OAuthTwitterController.h" 
#import "SA_OAuthTwitterEngine.h"



#define OAUTH_USERNAME @"oauth_username"
#define OAUTH_USERID @"oauth_userid"
#define OAUTH_SCREENNAME @"oauth_name"



@interface TwitterOAuthSessionManager : SessionManager <SA_OAuthTwitterControllerDelegate>
{
  SA_OAuthTwitterEngine* _engine;
  UIViewController* _parent;
  
  NSString* _requestFriends;
  NSString* _requestFollowers;
  NSString* _requestPost;
  BOOL _isLoging;
}

- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login:(UIViewController*)parent;
- (void)logout;

- (BOOL)requestGetInfo:(SessionRequestType)requestType;
- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl;


@end
