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
#import "SongUser.h"
#import "NextSong.h"

#define USE_YASOUND_LOCAL_SERVER 0

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
@property (readonly) Radio* radio;

+ (YasoundDataProvider*) main;

- (void)resetUser;

// Yasound
- (void)signup:(NSString*)email password:(NSString*)pwd username:(NSString*)username target:(id)target action:(SEL)selector;
- (void)login:(NSString*)email password:(NSString*)pwd target:(id)target action:(SEL)selector;

- (void)loginFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token email:(NSString*)email target:(id)target action:(SEL)selector;
- (void)loginTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email target:(id)target action:(SEL)selector;

- (void)userRadioWithTarget:(id)target action:(SEL)selector;

- (void)friendsWithTarget:(id)target action:(SEL)selector;

- (void)radioWithId:(NSNumber*)radioId target:(id)target action:(SEL)selector;
- (void)songWithId:(NSNumber*)songId target:(id)target action:(SEL)selector;

- (void)radiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)topRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)selectedRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)newRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)friendsRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)favoriteRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;

- (void)searchRadios:(NSString*)search withGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;

- (void)radioUserForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)setMood:(UserMood)mood forRadio:(Radio*)radio;
- (void)setRadio:(Radio*)radio asFavorite:(BOOL)favorite;

- (void)updateRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)setPicture:(UIImage*)img forRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)setPicture:(UIImage*)img forUser:(User*)user target:(id)target action:(SEL)selector;

- (void)setMood:(UserMood)mood forSong:(Song*)song;
- (void)songUserForSong:(Song*)song target:(id)target action:(SEL)selector;

- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize target:(id)target action:(SEL)selector;
- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize afterEventWithID:(NSNumber*)lastEventID target:(id)target action:(SEL)selector;

- (void)favoriteUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)likersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)connectedUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)listenersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)songsForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)postWallMessage:(NSString*)message toRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)addSongToUserRadio:(Song*)song;

- (void)nextSongsForUserRadioWithTarget:(id)target action:(SEL)selector;


//
//  NextSong editing
//
//  all the callback functions for these actions give an array with the NextSong objects with the right 'order' values
//  since an action on one object affects the 'order' values of all the others
//
- (void)moveNextSong:(NextSong*)nextSong toPosition:(int)position target:(id)target action:(SEL)selector;   // didMoveNextSong:(NSArray*)new_next_songs info:(NSDictionary*)info
- (void)deleteNextSong:(NextSong*)nextSong target:(id)target action:(SEL)selector;                          // didDeleteNextSong:(NSArray*)new_next_songs info:(NSDictionary*)info
- (void)addSongToNextSongs:(Song*)song atPosition:(int)position target:(id)target action:(SEL)selector;     // didAddNextSong:(NSArray*)new_next_songs info:(NSDictionary*)info


- (void)enterRadioWall:(Radio*)radio;
- (void)leaveRadioWall:(Radio*)radio;

- (void)startListeningRadio:(Radio*)radio;
- (void)stopListeningRadio:(Radio*)radio;

- (NSURL*)urlForPicture:(NSString*)picturePath;


- (void)updatePlaylists:(NSData*)data forRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)taskStatus:(taskID)task_id target:(id)target action:(SEL)selector;
@end
