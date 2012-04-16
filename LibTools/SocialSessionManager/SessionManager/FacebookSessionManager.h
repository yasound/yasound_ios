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



@interface FacebookSessionManager : SessionManager <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>
{
  Facebook* _facebookConnect;
  NSArray* _facebookPermissions;
  
  FBRequest* _requestMe;
  FBRequest* _requestFriends;
  FBRequest* _requestFeed;
    
    BOOL _logout;
}

@property (retain) Facebook* facebookConnect;


+ (FacebookSessionManager*)facebook;

- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login;
- (void)logout;

- (BOOL)requestGetInfo:(SessionRequestType)requestType;
- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl link:(NSURL*)link;

- (void)inviteFriends;


- (void)invalidConnexion;


- (BOOL)handleOpenURL:(NSURL *)url;


@end
