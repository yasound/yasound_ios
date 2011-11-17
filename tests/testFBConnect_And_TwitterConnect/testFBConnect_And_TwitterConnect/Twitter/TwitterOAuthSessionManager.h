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



#define AUTH_NAME @"authName"



@interface TwitterOAuthSessionManager : SessionManager <SA_OAuthTwitterControllerDelegate>
{
  SA_OAuthTwitterEngine* _engine;
  UIViewController* _parent;
}

- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login:(UIViewController*)parent;
- (void)logout;

- (BOOL)requestGetInfo:(NSString*)requestTag;
- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl;


@end
