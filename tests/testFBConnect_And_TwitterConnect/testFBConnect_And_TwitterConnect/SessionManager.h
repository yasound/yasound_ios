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


@protocol SessionDelegate <NSObject>
@required
- (void)loginDidFinish:(BOOL)authorized;
@end



@interface SessionManager : NSObject <SA_OAuthTwitterControllerDelegate, FBSessionDelegate>
{
  SA_OAuthTwitterEngine* _twitterEngine; 
  Facebook* _facebook;
  
  id<SessionDelegate> delegate;
}

@property (retain) id<SessionDelegate> delegate;
@property (readonly) BOOL authorized;

+ (SessionManager*)manager;

- (UIViewController*)twitterLoginDialog;
- (BOOL)loginUsingTwitter:(NSString*)username password:(NSString*)password;
- (void)loginUsingFacebook:(NSString*)username password:(NSString*)password;

- (BOOL)handleOpenURL:(NSURL *)url;


@end
