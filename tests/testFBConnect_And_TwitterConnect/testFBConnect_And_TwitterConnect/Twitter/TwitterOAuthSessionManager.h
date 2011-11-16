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






@interface TwitterOAuthSessionManager : SessionManager <SA_OAuthTwitterControllerDelegate>
{
  SA_OAuthTwitterEngine* _engine;
}

- (void)login:(UIViewController*)target;
- (void)logout;




@end
