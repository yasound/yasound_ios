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

+ (NSNumber*) user_id;
+ (NSString*) username;
+ (NSString*) user_apikey;
+ (BOOL) isAuthenticated;




- (int)cancelRequestsForTarget:(id)target;
- (int)cancelRequestsForKey:(NSString *)key;

- (void)resetUser;
- (void)reloadUserWithUserData:(id)data withTarget:(id)target action:(SEL)selector;

- (void)sendGetRequestWithURL:(NSString*)url;
- (void)sendPostRequestWithURL:(NSString*)url;


// login and accounts
- (void)signup:(NSString*)email password:(NSString*)pwd username:(NSString*)username target:(id)target action:(SEL)selector;
- (void)login:(NSString*)email password:(NSString*)pwd target:(id)target action:(SEL)selector;

- (void)loginFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token expirationDate:(NSString*)expirationDate email:(NSString*)email target:(id)target action:(SEL)selector;
- (void)loginTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email target:(id)target action:(SEL)selector;

- (BOOL)sendAPNsDeviceToken:(NSString*)deviceToken isSandbox:(BOOL)sandbox;

- (void)associateAccountYasound:(NSString*)email password:(NSString*)pword target:(id)target action:(SEL)selector;
- (void)associateAccountFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token  expirationDate:(NSString*)expirationDate email:(NSString*)email target:(id)target action:(SEL)selector;
- (void)associateAccountTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email target:(id)target action:(SEL)selector;
- (void)dissociateAccount:(NSString*)accountTypeIdentifier  target:(id)target action:(SEL)selector;



- (void)userRadioWithTarget:(id)target action:(SEL)selector;
- (void)reloadUserRadio;

- (void)friendsWithTarget:(id)target action:(SEL)selector;
- (void)friendsWithTarget:(id)target action:(SEL)selector userData:(id)userData;

- (void)friendsForUser:(User*)user withTarget:(id)target action:(SEL)selector;

- (void)createRadioWithTarget:(id)target action:(SEL)selector;
- (void)deleteRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)favoriteRadiosForUser:(User*)u withTarget:(id)target action:(SEL)selector;

- (void)radiosForUser:(User*)u withTarget:(id)target action:(SEL)selector;


- (void)radioWithId:(NSNumber*)radioId withCompletionBlock:(YaRequestCompletionBlock)block;




- (void)radiosWithUrl:(NSString*)url withGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData;

- (void)searchRadios:(NSString*)search withTarget:(id)target action:(SEL)selector;

- (void)radioHasBeenShared:(Radio*)radio with:(NSString*)shareType;

- (void)setRadio:(Radio*)radio asFavorite:(BOOL)favorite;
- (void)setRadio:(Radio*)radio asFavorite:(BOOL)favorite target:(id)target action:(SEL)selector;

- (void)updateRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)setPicture:(UIImage*)img forRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (BOOL)updateUser:(User*)user target:(id)target action:(SEL)selector; // - (void)didUpdateUser:(ASIHTTPRequest*)req success:(BOOL)success
- (void)setPicture:(UIImage*)img forUser:(User*)user target:(id)target action:(SEL)selector;

- (void)setMood:(UserMood)mood forSong:(Song*)song withCompletionBlock:(YaRequestCompletionBlock)block;

// follow user
- (void)followUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)unfollowUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block;

// Radio users
- (void)favoriteUsersForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)currentUsersForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

// Wall events
- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize olderThanEventWithID:(NSNumber*)lastEventID withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)wallEventsForRadio:(Radio*)radio newerThanEventWithID:(NSNumber*)eventID withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)cancelWallEventsRequestsForRadio:(Radio*)radio;

- (void)postWallMessage:(NSString*)message toRadio:(Radio*)radio withCompletionBLock:(YaRequestCompletionBlock)block;

- (void)moderationDeleteWallMessage:(NSNumber*)messageId;
- (void)moderationReportAbuse:(NSNumber*)messageId;

- (void)currentSongForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)userWithId:(NSNumber*)userId target:(id)target action:(SEL)selector;
- (void)userWithUsername:(NSString*)username target:(id)target action:(SEL)selector;

// Connection to the wall
- (void)enterRadioWall:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)leaveRadioWall:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

- (NSURL*)urlForPicture:(NSString*)picturePath;
- (NSURL*)urlForSongCover:(Song*)song;

- (void)updatePlaylists:(NSData*)data forRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)radioRecommendationsWithArtistList:(NSData*)data genre:(NSString*)genre target:(id)target action:(SEL)selector userData:(id)userData; // artist list is built with PlaylistMoulinor buildArtistDataBinary: compressed: target: action:
// returns concatenation of 'selection' and 'similar radios'

- (void)taskStatus:(taskID)task_id target:(id)target action:(SEL)selector;


- (void)monthListeningStatsForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;
- (void)leaderboardForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;


// Playlist
- (void)playlistsForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)songsForPlaylist:(NSInteger)playlistId target:(id)target action:(SEL)selector;

- (ASIFormDataRequest*)uploadSong:(NSData*)song forRadioId:(Radio*)radio_id title:(NSString*)title album:(NSString*)album artist:(NSString*)artist songId:(NSNumber*)songId target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate;

// Get matched songs for a playlist. Returns a NSArray of Song objects
- (void)matchedSongsForPlaylist:(Playlist*)playlist target:(id)target action:(SEL)selector;  // didReceiveMatchedSongs:(NSArray*)matched_songs info:(NSDictionary*)info

- (void)updateSong:(Song*)song target:(id)target action:(SEL)selector; // didUpdateSong:(Song*)song info:(NSDictionary*)info
- (void)deleteSong:(Song*)song target:(id)target action:(SEL)selector userData:(id)data;    // didDeleteSong:(Song*)song info:(NSDictionary*)info
                                                                                            // info dictionary contains: 
                                                                                            // - data for key @"userData"
                                                                                            // - a NSNumber (boolean) for key @"success"

- (void)deleteAllSongsFromRadio:(Radio*)radio target:(id)target action:(SEL)action;
- (void)deleteArtist:(NSString*)artist fromRadio:(Radio*)radio target:(id)target action:(SEL)action;
- (void)deleteAlbum:(NSString*)album fromRadio:(Radio*)radio target:(id)target action:(SEL)action;

- (void)rejectSong:(Song*)song target:(id)target action:(SEL)selector; // didRejectSong:(ASIHTTPRequest*)req succeeded:(NSNumber*)success


// Get searched songs. Returns a NSArray of YasoundSong objects
- (void)searchSong:(NSString*)search count:(NSInteger)count offset:(NSInteger)offset target:(id)target action:(SEL)selector; // didReceiveSearchedSongs:(NSArray*)songs info:(NSDictionary*)info

- (void)addSong:(YasoundSong*)yasoundSong inRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)addSong:(YasoundSong*)yasoundSong target:(id)target action:(SEL)selector;  // didReceiveAddedSong:(Song*)addedSong info:(NSDictionary*)info and info contains a dictionary for key 'status' with 2 NSNumber* (boolean) 'success' (true if the request succeeded) and 'created' (true if a song has been added, false if this song was already in the playlist)


// APNs (Apple Push Notification service) preferences
- (void)apnsPreferencesWithCompletionBlock:(YaRequestCompletionBlock)block;
- (void)setApnsPreferences:(APNsPreferences*)prefs withCompletionBlock:(YaRequestCompletionBlock)block;

// Facebook share preferences
- (void)facebookSharePreferencesWithCompletionBlock:(YaRequestCompletionBlock)block;
- (void)setFacebookSharePreferences:(FacebookSharePreferences*)prefs withCompletionBlock:(YaRequestCompletionBlock)block;

// users in the app
- (void)connectedUsersWithCompletionBlock:(YaRequestCompletionBlock)block; // users connected to the app ordered by distance from the sender
- (void)connectedUsersWithLimit:(int)limit skip:(int)skip completionBlock:(YaRequestCompletionBlock)block;

// User Notifications
- (void)broadcastMessage:(NSString*)message fromRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block;

- (void)userNotificationsWithTarget:(id)target action:(SEL)selector limit:(NSInteger)limit offset:(NSInteger)offset;
- (void)userNotificationWithId:(NSString*)notifId target:(id)target action:(SEL)selector;
- (void)updateUserNotification:(UserNotification*)notif target:(id)target action:(SEL)selector;
- (void)deleteUserNotification:(UserNotification*)notif target:(id)target action:(SEL)selector;
- (void)deleteAllUserNotificationsWithTarget:(id)target action:(SEL)selector;
- (void)unreadNotificationCountWithTarget:(id)target action:(SEL)selector;


// Shows
- (void)showsForRadio:(Radio*)r withTarget:(id)target action:(SEL)selector;
- (void)showsForRadio:(Radio*)r limit:(NSInteger)limit offset:(NSInteger)offset withTarget:(id)target action:(SEL)selector;

- (void)showWithId:(NSString*)showId withTarget:(id)target action:(SEL)selector;
- (void)updateShow:(Show*)show withTarget:(id)target action:(SEL)selector;
- (void)deleteShow:(Show*)show withTarget:(id)target action:(SEL)selector;
- (void)duplicateShow:(Show*)show withTarget:(id)target action:(SEL)selector;
- (void)createShow:(Show*)show inRadio:(Radio*)radio withTarget:(id)target action:(SEL)selector;
- (void)createShow:(Show*)show inRadio:(Radio*)radio withYasoundSongs:(NSArray*)yasoundSongs withTarget:(id)target action:(SEL)selector;

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
