//
//  TwitteriOSSessionManager.h
//  iOS twitter session manager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionManager.h"
#import <Accounts/Accounts.h>
#import "TwitterAccountsViewController.h"
#import "TwitterOAuthSessionManager.h"


// note : TwitteriOSSessionManager is using SessionDelegate in a special case : no twitter account has been registered in the system yet, 
// and we use  TwitterOAuthSessionManager to get the user credentiels and to create the twitter system account automatically

@interface TwitteriOSSessionManager : SessionManager <TwitterAccountsDelegate, SessionDelegate>
{
  ACAccount* _account;
  NSArray* _accounts;
  TwitterOAuthSessionManager* _oauthManager;
  BOOL _granted;
}

@property (retain) ACAccountStore* store;
@property (retain) ACAccount* account;
@property (retain) NSArray* accounts;


- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login;
- (void)logout;
- (void)invalidConnexion;

- (BOOL)requestGetInfo:(SessionRequestType)requestType;
- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl;
- (void)enableUpdatesFor:(NSString *)username; // friendships/create (follow username)

@end
