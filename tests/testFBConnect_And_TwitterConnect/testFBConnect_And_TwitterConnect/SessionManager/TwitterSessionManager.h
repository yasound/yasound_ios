//
//  TwitterSessionManager.h
//  inherited from SessionManager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitteriOSSessionManager.h"
#import "TwitterOAuthSessionManager.h"


@interface TwitterSessionManager : SessionManager
{
}

@property (retain) TwitteriOSSessionManager* iosManager;
@property (retain) TwitterOAuthSessionManager* oauthManager; 


+ (TwitterSessionManager*)twitter;

- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login;
- (void)logout;



@end
