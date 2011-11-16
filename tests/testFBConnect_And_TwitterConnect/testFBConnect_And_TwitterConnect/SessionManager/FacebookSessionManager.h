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
}

@property (retain) Facebook* facebookConnect;


+ (FacebookSessionManager*)facebook;

- (void)login:(id)target;
- (void)logout;

- (BOOL)handleOpenURL:(NSURL *)url;


@end
