//
//  YasoundDataProvider.h
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Communicator.h"
#import "YaRadio.h"
#import "WallEvent.h"
#import "WallMessagePost.h"
#import "ApiKey.h"
#import "RadioUser.h"
#import "SongUser.h"
#import "NextSong.h"
#import "Song.h"
#import "RadioListeningStat.h"
#import "LeaderBoardEntry.h"
#import "Playlist.h"
#import "YasoundSong.h"
#import "APNsDeviceToken.h"
#import "APNsPreferences.h"
#import "ASIHTTPRequest+Model.h"
#import "UserNotification.h"
#import "UserSettings.h"
#import "FacebookSharePreferences.h"
#import "CityInfo.h"
#import "Show.h"
#import "YaRequest.h"
#import "NSString+JsonLoading.h"

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

@interface TaskInfo : NSObject

@property taskStatus status;
@property float progress;
@property (retain) NSString* message;

- (id)initWithStatus:(taskStatus)s progress:(float)p message:(NSString*)m;
- (id)initWithDictionary:(NSDictionary*)desc;
- (id)initWithString:(NSString*)desc;

+ (TaskInfo*)taskInfoWithStatus:(taskStatus)s progress:(float)p message:(NSString*)m;
+ (TaskInfo*)taskInfoWithDictionary:(NSDictionary*)desc;
+ (TaskInfo*)taskInfoWithString:(NSString*)desc;

@end

taskStatus stringToStatus(NSString* str);

@interface YasoundDataProvider : NSObject
{
  Communicator* _communicator;
  User* _user;
  YaRadio* _radio;
  NSString* _apiKey;
  NSString* _password;
}

@property (readonly) Auth* apiKeyAuth;
@property (readonly) Auth* passwordAuth;
@property (readonly) NSHTTPCookie* appCookie;

@property (readonly) User* user;
@property (readonly) YaRadio* radio;

+ (YasoundDataProvider*) main;

+ (NSNumber*) user_id;
+ (NSString*) username;
+ (NSString*) user_apikey;
+ (BOOL) isAuthenticated;




- (int)cancelRequestsForKey:(NSString *)key;

- (void)resetUser;
- (void)reloadUserWithCompletionBlock:(void (^) (User*))block;

- (void)sendGetRequestWithURL:(NSString*)url;
- (void)sendPostRequestWithURL:(NSString*)url;


#pragma mark - signup/login

- (void)signup:(NSString*)email password:(NSString*)pwd username:(NSString*)username withCompletionBlock:(void (^) (User*, NSError*))block;
- (void)login:(NSString*)email password:(NSString*)pwd withCompletionBlock:(void (^) (User*, NSError*))block;
- (void)loginFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token expirationDate:(NSString*)expirationDate email:(NSString*)email withCompletionBlock:(void (^) (User*, NSError*))block;
- (void)loginTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email withCompletionBlock:(void (^) (User*, NSError*))block;

#pragma mark - Account association/dissociation

- (void)associateAccountYasound:(NSString*)email password:(NSString*)pword withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)associateAccountFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token  expirationDate:(NSString*)expirationDate email:(NSString*)email withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)associateAccountTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)dissociateAccount:(NSString*)accountTypeIdentifier withCompletionBlock:(YaRequestCompletionBlock)block;

#pragma mark - APNs token

- (BOOL)sendAPNsDeviceToken:(NSString*)deviceToken isSandbox:(BOOL)sandbox;


- (void)userRadioWithTargetWithCompletionBlock:(void (^) (YaRadio*))block;
- (void)reloadUserRadio;

- (void)friendsWithCompletionBlock:(YaRequestCompletionBlock)block;

- (void)friendsForUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)createRadioWithCompletionBlock:(YaRequestCompletionBlock)block;
- (void)deleteRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)favoriteRadiosForUser:(User*)u withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)radiosForUser:(User*)u withCompletionBlock:(YaRequestCompletionBlock)block;


- (void)radioWithId:(NSNumber*)radioId withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)radiosWithUrl:(NSString*)url withGenre:(NSString*)genre withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)searchRadios:(NSString*)search withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)radioHasBeenShared:(YaRadio*)radio with:(NSString*)shareType withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)setRadio:(YaRadio*)radio asFavorite:(BOOL)favorite withCompletionBlock:(YaRequestCompletionBlock)block;

#pragma  mark - update radio

- (void)updateRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)setPicture:(UIImage*)img forRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

#pragma  mark - update user

- (BOOL)updateUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)setPicture:(UIImage*)img forUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)setMood:(UserMood)mood forSong:(Song*)song withCompletionBlock:(YaRequestCompletionBlock)block;

// follow user
- (void)followUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)unfollowUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block;

// Radio users
- (void)favoriteUsersForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)currentUsersForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

// Wall events
- (void)wallEventsForRadio:(YaRadio*)radio pageSize:(int)pageSize withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)wallEventsForRadio:(YaRadio*)radio pageSize:(int)pageSize olderThanEventWithID:(NSNumber*)lastEventID withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)wallEventsForRadio:(YaRadio*)radio newerThanEventWithID:(NSNumber*)eventID withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)cancelWallEventsRequestsForRadio:(YaRadio*)radio;

- (void)postWallMessage:(NSString*)message toRadio:(YaRadio*)radio withCompletionBLock:(YaRequestCompletionBlock)block;

- (void)moderationDeleteWallMessage:(NSNumber*)messageId;
- (void)moderationReportAbuse:(NSNumber*)messageId;

- (void)currentSongForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)userWithId:(NSNumber*)userId withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)userWithUsername:(NSString*)username withCompletionBlock:(YaRequestCompletionBlock)block;

// Connection to the wall
- (void)enterRadioWall:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)leaveRadioWall:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

- (NSURL*)urlForPicture:(NSString*)picturePath;
- (NSURL*)urlForSongCover:(Song*)song;

- (void)updatePlaylists:(NSData*)data forRadio:(YaRadio*)radio withCompletionBlock:(void (^) (taskID))block;

- (void)radioRecommendationsWithArtistList:(NSData*)data genre:(NSString*)genre withCompletionBlock:(YaRequestCompletionBlock)block; // artist list is built with PlaylistMoulinor buildArtistDataBinary: compressed: target: action:
// returns concatenation of 'selection' and 'similar radios'

- (void)taskStatus:(taskID)task_id withCompletionBlock:(YaRequestCompletionBlock)block;


- (void)monthListeningStatsForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)leaderboardForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;


// Playlist
- (void)playlistsForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)songsForPlaylist:(NSInteger)playlistId withCompletionBlock:(YaRequestCompletionBlock)block;

- (YaRequest*)uploadSong:(NSData*)song forRadioId:(NSNumber*)radio_id title:(NSString*)title album:(NSString*)album artist:(NSString*)artist songId:(NSNumber*)songId withCompletionBlock:(YaRequestCompletionBlock)block andProgressBlock:(YaRequestProgressBlock)progressBlock;

- (void)matchedSongsForPlaylist:(Playlist*)playlist withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)updateSong:(Song*)song withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)deleteSong:(Song*)song withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)deleteAllSongsFromRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)deleteArtist:(NSString*)artist fromRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)deleteAlbum:(NSString*)album fromRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)rejectSong:(Song*)song withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)searchSong:(NSString*)search count:(NSInteger)count offset:(NSInteger)offset withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)addSong:(YasoundSong*)yasoundSong inRadio:(YaRadio*)radio withCompletionBlock:(void (^) (Song*, BOOL, NSError*))block;

- (void)songWithId:(NSNumber*)songId withCompletionBlock:(YaRequestCompletionBlock)block;

// APNs (Apple Push Notification service) preferences
- (void)apnsPreferencesWithCompletionBlock:(YaRequestCompletionBlock)block;
- (void)setApnsPreferences:(APNsPreferences*)prefs withCompletionBlock:(YaRequestCompletionBlock)block;

// Facebook share preferences
- (void)facebookSharePreferencesWithCompletionBlock:(YaRequestCompletionBlock)block;
- (void)setFacebookSharePreferences:(FacebookSharePreferences*)prefs withCompletionBlock:(YaRequestCompletionBlock)block;

// users in the app
- (void)connectedUsersWithCompletionBlock:(YaRequestCompletionBlock)block; // users connected to the app ordered by distance from the sender
- (void)connectedUsersWithLimit:(int)limit skip:(int)skip completionBlock:(YaRequestCompletionBlock)block;


- (void)broadcastMessage:(NSString*)message fromRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

// User Notifications
- (void)userNotificationsWithLimit:(NSInteger)limit offset:(NSInteger)offset andCompletionBlock:(YaRequestCompletionBlock)block;
- (void)updateUserNotification:(UserNotification*)notif withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)deleteUserNotification:(UserNotification*)notif withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)deleteAllUserNotificationsWithCompletionBlock:(YaRequestCompletionBlock)block;
- (void)unreadNotificationCountWithCompletionBlock:(YaRequestCompletionBlock)block;

// Shows
- (void)showsForRadio:(YaRadio*)r withTarget:(id)target action:(SEL)selector;
- (void)showsForRadio:(YaRadio*)r limit:(NSInteger)limit offset:(NSInteger)offset withTarget:(id)target action:(SEL)selector;

- (void)showWithId:(NSString*)showId withTarget:(id)target action:(SEL)selector;
- (void)updateShow:(Show*)show withTarget:(id)target action:(SEL)selector;
- (void)deleteShow:(Show*)show withTarget:(id)target action:(SEL)selector;
- (void)duplicateShow:(Show*)show withTarget:(id)target action:(SEL)selector;
- (void)createShow:(Show*)show inRadio:(YaRadio*)radio withTarget:(id)target action:(SEL)selector;
- (void)createShow:(Show*)show inRadio:(YaRadio*)radio withYasoundSongs:(NSArray*)yasoundSongs withTarget:(id)target action:(SEL)selector;

// Show Songs
- (void)songsForShow:(Show*)show withTarget:(id)target action:(SEL)selector;
- (void)songsForShow:(Show*)show limit:(NSInteger)limit offset:(NSInteger)offset withTarget:(id)target action:(SEL)selector;
- (void)addSong:(YasoundSong*)song inShow:(Show*)show withTarget:(id)target action:(SEL)selector;   // takes YasoundSong as param !!
- (void)removeSong:(Song*)song fromShow:(Show*)show withTarget:(id)target action:(SEL)selector;     // takes Song as param !!

// in-app purchase
- (void)subscriptionsWithTarget:(id)target action:(SEL)action;
- (void)subscriptionComplete:(NSString*)productId withBase64Receipt:(NSString*)appleReceipt target:(id)target action:(SEL)action;
- (void)servicesWithTarget:(id)target action:(SEL)action;

// gifts
- (void)giftsWithCompletionBlock:(YaRequestCompletionBlock)block;

// promo code
- (void)activatePromoCode:(NSString*)code withCompletionBlock:(YaRequestCompletionBlock)block;

// streamer authentication
- (void)streamingAuthenticationTokenWithCompletionBlock:(YaRequestCompletionBlock)block;

// invite friends
- (void)inviteContacts:(NSArray*)contacts withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)inviteFacebookFriends:(NSArray*)friends withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)inviteTwitterFriendsWithTarget:(YaRequestCompletionBlock)block;


- (void)testV2;

- (void)citySuggestionsWithCityName:(NSString*)city andCompletionBlock:(YaRequestCompletionBlock)block;

@end
