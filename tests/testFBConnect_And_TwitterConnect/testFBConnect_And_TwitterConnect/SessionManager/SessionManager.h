//
//  SessionManager.h
//  online login management
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

#define REQUEST_TAG_USERNAME @"username"
#define REQUEST_TAG_FRIENDLIST @"friendlist"




@protocol SessionDelegate <NSObject>
@required
- (void)sessionDidLogin:(BOOL)authorized;
- (void)sessionLoginFailed;
- (void)sessionDidLogout;
- (void)requestDidLoad:(NSString*)requestTag data:(NSDictionary*)data;
@end



@interface SessionManager : NSObject
{
}

@property (retain) id<SessionDelegate> delegate;

@property (readonly) BOOL authorized;

- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login;
- (void)logout;

- (BOOL)requestGetInfo:(NSString*)requestTag;
- (BOOL)requestPostMessage:(NSString*)message;



@end
