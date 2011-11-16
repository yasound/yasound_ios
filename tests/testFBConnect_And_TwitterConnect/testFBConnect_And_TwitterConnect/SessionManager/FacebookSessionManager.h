//
//  SessionManager.h
//  online login management
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h" 
#import "SA_OAuthTwitterEngine.h"
#import "FBConnect.h"
#import <Accounts/Accounts.h>
#import "TwitterAccountsViewController.h"





@protocol SessionDelegate <NSObject>
@required
- (void)sessionDidLogin:(BOOL)authorized;
- (void)sessionDidLogout;
@end



@interface SessionManager : NSObject <SA_OAuthTwitterControllerDelegate, FBSessionDelegate, TwitterAccountsDelegate>
{
  SA_OAuthTwitterEngine* _twitterEngine; 
  ACAccount* _twitterAccount;
  Facebook* _facebook;
  
  id<SessionDelegate> _delegate;
}

//@property (retain) id<SessionDelegate> delegate;
@property (readonly) BOOL authorized;

@property (retain) SA_OAuthTwitterEngine* twitterEngine;
@property (retain) ACAccount* twitterAccount;
@property (retain) Facebook* facebook;


+ (SessionManager*)manager;

- (void)loginUsingTwitter:(UIViewController*)target;
- (void)loginUsingFacebook:(UIViewController*)target;
- (void)logout;

- (BOOL)handleOpenURL:(NSURL *)url;


@end
