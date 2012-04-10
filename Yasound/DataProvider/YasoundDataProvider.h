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

- (void)resetUser;
- (void)reloadUserWithTarget:(id)target action:(SEL)selector;

// Yasound
- (void)signup:(NSString*)email password:(NSString*)pwd username:(NSString*)username target:(id)target action:(SEL)selector;
- (void)login:(NSString*)email password:(NSString*)pwd target:(id)target action:(SEL)selector;

- (void)loginFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token email:(NSString*)email target:(id)target action:(SEL)selector;
- (void)loginTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email target:(id)target action:(SEL)selector;

- (BOOL)sendAPNsDeviceToken:(NSString*)deviceToken isSandbox:(BOOL)sandbox;

- (void)associateAccountYasound:(NSString*)email password:(NSString*)pword target:(id)target action:(SEL)selector;
- (void)associateAccountFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token email:(NSString*)email target:(id)target action:(SEL)selector;
- (void)associateAccountTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email target:(id)target action:(SEL)selector;
- (void)dissociateAccount:(NSString*)accountTypeIdentifier  target:(id)target action:(SEL)selector;



- (void)userRadioWithTarget:(id)target action:(SEL)selector;
- (void)reloadUserRadio;

- (void)friendsWithTarget:(id)target action:(SEL)selector;
- (void)friendsWithTarget:(id)target action:(SEL)selector userData:(id)userData;

- (void)radioForUser:(User*)u withTarget:(id)target action:(SEL)selector;
- (void)radioWithId:(NSNumber*)radioId target:(id)target action:(SEL)selector;

- (void)radiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)topRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)selectedRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)newRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)friendsRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)favoriteRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector;
- (void)favoriteRadiosForUser:(User*)u withTarget:(id)target action:(SEL)selector;

- (void)radiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData;
- (void)topRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData;
- (void)selectedRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData;
- (void)newRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData;
- (void)friendsRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData;
- (void)favoriteRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData;

- (void)searchRadios:(NSString*)search withTarget:(id)target action:(SEL)selector;
- (void)searchRadiosByCreator:(NSString*)search withTarget:(id)target action:(SEL)selector;
- (void)searchRadiosBySong:(NSString*)search withTarget:(id)target action:(SEL)selector;

- (void)radioUserForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)setMood:(UserMood)mood forRadio:(Radio*)radio;
- (void)setRadio:(Radio*)radio asFavorite:(BOOL)favorite;
- (void)radioHasBeenShared:(Radio*)radio;

- (void)updateRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)setPicture:(UIImage*)img forRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)setPicture:(UIImage*)img forUser:(User*)user target:(id)target action:(SEL)selector;

- (void)setMood:(UserMood)mood forSong:(Song*)song;
- (void)songUserForSong:(Song*)song target:(id)target action:(SEL)selector;

- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize target:(id)target action:(SEL)selector;
- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize afterEventWithID:(NSNumber*)lastEventID target:(id)target action:(SEL)selector;

- (void)favoriteUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)likersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)currentUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)currentSongForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)currentSongForRadio:(Radio*)radio target:(id)target action:(SEL)selector userData:(id)userData;

- (void)statusForSongId:(NSNumber*)songId target:(id)target action:(SEL)selector;
- (void)songWithId:(NSNumber*)songId target:(id)target action:(SEL)selector;

- (void)postWallMessage:(NSString*)message toRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)addSongToUserRadio:(Song*)song;

- (void)nextSongsForUserRadioWithTarget:(id)target action:(SEL)selector;

- (void)userWithId:(NSNumber*)userId target:(id)target action:(SEL)selector;


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

- (NSURL*)urlForPicture:(NSString*)picturePath;
- (NSURL*)urlForSongCover:(Song*)song;

- (void)updatePlaylists:(NSData*)data forRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)taskStatus:(taskID)task_id target:(id)target action:(SEL)selector;


- (void)monthListeningStatsWithTarget:(id)target action:(SEL)selector;
- (void)leaderboardWithTarget:(id)target action:(SEL)selector;


// Playlist
- (void)playlistsForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)songsForPlaylist:(NSInteger)playlistId target:(id)target action:(SEL)selector;

- (ASIFormDataRequest*)uploadSong:(NSData*)songData 
             title:(NSString*)title
             album:(NSString*)album
             artist:(NSString*)artist
            songId:(NSNumber*)songId 
            target:(id)target 
            action:(SEL)selector 
  progressDelegate:(id)progressDelegate;

// Get matched songs for a playlist. Returns a NSArray of Song objects
- (void)matchedSongsForPlaylist:(Playlist*)playlist target:(id)target action:(SEL)selector;  // didReceiveMatchedSongs:(NSArray*)matched_songs info:(NSDictionary*)info

- (void)updateSong:(Song*)song target:(id)target action:(SEL)selector; // didUpdateSong:(Song*)song info:(NSDictionary*)info
- (void)deleteSong:(Song*)song target:(id)target action:(SEL)selector; // didDeleteSong:(Song*)song info:(NSDictionary*)info

// Get searched songs. Returns a NSArray of YasoundSong objects
- (void)searchSong:(NSString*)search count:(NSInteger)count offset:(NSInteger)offset target:(id)target action:(SEL)selector; // didReceiveSearchedSongs:(NSArray*)songs info:(NSDictionary*)info

- (void)addSong:(YasoundSong*)yasoundSong target:(id)target action:(SEL)selector;  // didReceiveAddedSong:(Song*)addedSong info:(NSDictionary*)info and info contains a dictionary for key 'status' with 2 NSNumber* (boolean) 'success' (true if the request succeeded) and 'created' (true if a song has been added, false if this song was already in the playlist)


// APNs (Apple Push Notification service) preferences
- (void)apnsPreferencesWithTarget:(id)target action:(SEL)selector;
- (void)setApnsPreferences:(APNsPreferences*)prefs target:(id)target action:(SEL)selector;

@end
