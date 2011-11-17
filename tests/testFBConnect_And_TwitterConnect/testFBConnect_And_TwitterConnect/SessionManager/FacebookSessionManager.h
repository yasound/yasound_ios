//
//  FacebookSessionManager.h
//  inherited from SessionManager
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionManager.h"
#import "FBConnect.h"



@interface FacebookSessionManager : SessionManager <FBSessionDelegate>
{
  Facebook* _facebookConnect;
  NSArray* _facebookPermissions;
}

@property (retain) Facebook* facebookConnect;


+ (FacebookSessionManager*)facebook;

- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login;
- (void)logout;

- (void)getUserInfo:(id)sender;
- (void)getUserFriendList:(id)sender;
- (void)postToFriendsWall;


- (BOOL)handleOpenURL:(NSURL *)url;


@end
