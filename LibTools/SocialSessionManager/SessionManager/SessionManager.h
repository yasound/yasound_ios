//
//  SessionManager.h
//  online login management
//
//  Created by LOIC BERTHELOT on 10/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum 
{
  SRequestInfoUser = 0,
  SRequestInfoFriends,
  SRequestInfoFollowers,
  SRequestPostMessage
  
} SessionRequestType;

#define DATA_FIELD_ID @"id"
#define DATA_FIELD_TOKEN @"token"
#define DATA_FIELD_TOKEN_SECRET @"token_secret"
#define DATA_FIELD_TYPE @"type"
#define DATA_FIELD_USERNAME @"username"
#define DATA_FIELD_NAME @"name"
#define DATA_FIELD_EMAIL @"email"






@protocol SessionDelegate <NSObject>
@required
- (void)sessionDidLogin:(BOOL)authorized;
- (void)sessionLoginFailed;
- (void)sessionLoginCanceled;
- (void)sessionDidLogout;

- (void)requestDidLoad:(SessionRequestType)requestType data:(NSArray*)data;
- (void)requestDidFailed:(SessionRequestType)requestType error:(NSError*)error errorMessage:(NSString*)errorMessage;

@end



@interface SessionManager : NSObject
{
}

@property (retain) id<SessionDelegate> delegate;

@property (readonly) BOOL authorized;

- (void)setTarget:(id<SessionDelegate>)delegate;
- (void)login;
- (void)logout;

- (BOOL)requestGetInfo:(SessionRequestType)requestType;
- (BOOL)requestPostMessage:(NSString*)message title:(NSString*)title picture:(NSURL*)pictureUrl;


@end
