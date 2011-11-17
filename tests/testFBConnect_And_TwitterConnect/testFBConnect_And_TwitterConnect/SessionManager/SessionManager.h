//
//  SessionManager.h
//  online login management
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SessionDelegate <NSObject>
@required
- (void)sessionDidLogin:(BOOL)authorized;
- (void)sessionLoginFailed;
- (void)sessionDidLogout;
@end



@interface SessionManager : NSObject
{
}

@property (readonly) BOOL authorized;
@property (retain) id<SessionDelegate> delegate;


- (void)login:(UIViewController*)target;
- (void)logout;



@end
