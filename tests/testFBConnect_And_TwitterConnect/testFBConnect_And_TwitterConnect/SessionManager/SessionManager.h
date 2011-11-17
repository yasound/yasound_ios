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

@property (retain) id<SessionDelegate> delegate;

@property (readonly) BOOL authorized;
@property (readonly) NSString* username;


- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login;
- (void)logout;



@end
