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



@interface FacebookSessionManager : SessionManager <FBSessionDelegate, FBRequestDelegate>
{
  Facebook* _facebookConnect;
  NSArray* _facebookPermissions;
  
  FBRequest* _requestMe;
  FBRequest* _requestFriends;
}

@property (retain) Facebook* facebookConnect;


+ (FacebookSessionManager*)facebook;

- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login;
- (void)logout;

- (BOOL)requestGetInfo:(NSString*)requestTag;
- (BOOL)requestPostMessage:(NSString*)message;



- (BOOL)handleOpenURL:(NSURL *)url;


@end
