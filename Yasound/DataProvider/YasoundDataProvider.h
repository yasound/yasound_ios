//
//  YasoundDataProvider.h
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Communicator.h"
#import "Radio.h"
#import "WallEvent.h"
#import "ApiKey.h"
#import "RadioUser.h"

typedef NSString* taskID;

typedef enum  
{
  eTaskPending = 0,
  eTaskStarted = 1,
  eTaskRetry = 2,
  eTaskFailure = 3,
  eTaskSuccess = 4,
  eTaskStatusNone = 5
} taskStatus;

taskStatus stringToStatus(NSString* str);

@interface YasoundDataProvider : NSObject
{
  Communicator* _communicator;
  User* _user;
  Radio* _radio;
  NSString* _apiKey;
  NSString* _password;
}

@property (readonly) Auth* apiKeyAuth;
@property (readonly) Auth* passwordAuth;
@property (readonly) NSHTTPCookie* appCookie;

@property (readonly) User* user;

+ (YasoundDataProvider*) main;

- (void)resetUser;

// Yasound
- (void)signup:(NSString*)email password:(NSString*)pwd username:(NSString*)username target:(id)target action:(SEL)selector;
- (void)login:(NSString*)email password:(NSString*)pwd target:(id)target action:(SEL)selector;

- (void)loginFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token email:(NSString*)email target:(id)target action:(SEL)selector;
- (void)loginTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email target:(id)target action:(SEL)selector;

- (void)userRadioWithTarget:(id)target action:(SEL)selector;

- (void)radiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)topRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)selectedRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)newRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)friendsRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)favoriteRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;

- (void)searchRadios:(NSString*)search withGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;

- (void)radioUserForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)setMood:(RadioUserMood)mood forRadio:(Radio*)radio;
- (void)setRadio:(Radio*)radio asFavorite:(BOOL)favorite;

- (void)updateRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)setPicture:(UIImage*)img forRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)setPicture:(UIImage*)img forUser:(User*)user target:(id)target action:(SEL)selector;

- (void)wallEventsForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)likersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)connectedUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)songsForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)postWallMessage:(NSString*)message toRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)enterRadio:(Radio*)radio;
- (void)leaveRadio:(Radio*)radio;

- (NSURL*)urlForPicture:(NSString*)picturePath;


- (void)updatePlaylists:(NSData*)data forRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)taskStatus:(taskID)task_id target:(id)target action:(SEL)selector;
@end
