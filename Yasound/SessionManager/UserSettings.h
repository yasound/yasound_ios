//
//  UserSettings.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 06/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

#define USKEYnowPlaying @"NowPlaying"

#define USKEYfacebookAccessTokenKey @"FBAccessTokenKey"
#define USKEYfacebookExpirationDateKey @"FBExpirationDateKey"

#define USKEYtwitterAccountId @"twitterAccountIdentifier"
#define USKEYtwitterOAuthUsername @"oauth_username"
#define USKEYtwitterOAuthUserId @"oauth_userid"
#define USKEYtwitterOAuthScreenname @"oauth_name"
#define USKEYtwitterOAuthToken @"token"

#define USKEYyasoundEmail @"yasound_email"


#define USKEYuserId @"LastConnectedUserID"
#define USKEYuserSessionDictionary @"YasoundSessionManager"
#define USKEYuserSessionAccounts @"YasoundSessionManagerAccounts"
#define USKEYskipRadioCreation @"skipRadioCreationSendToSelection"

#define USKEYuploadLegalWarning @"legalUploadWarning"
#define USKEYuploadAddedWarning @"addedUploadWarning"
#define USKEYuploadList @"SongUploads"

#define USKEYtutorials @"Tutorials"

#define USKEYratingNever @"neverRate"
#define USKEYratingLaunchCount @"launchCount"

#define USKEYcacheMenuDescription @"menuDescriptionV2"
#define USKEYcacheImageRegisterSize @"imageRegisterSize"

#define USKEYuserWantsHd @"userWantsHd"
#define USKEYuserAllowsAccessToContacts @"userAllowsAccessToContacts"

#define USKEYradioSearch @"userRadioSearch"



@interface UserSettings : NSObject

@property (nonatomic, retain) NSMutableDictionary* selectedGenres;

+ (UserSettings*)main;

- (void)setObject:(id)value forKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;
- (NSMutableArray*)mutableArrayForKey:(NSString*)key;
- (NSMutableDictionary*)mutableDictionaryForKey:(NSString*)key;

- (void)setBool:(BOOL)value forKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key error:(BOOL*)error;

- (void)setInteger:(NSInteger)value forKey:(NSString*)key;
- (NSInteger)integerForKey:(NSString*)key error:(BOOL*)error;

- (void)removeObjectForKey:(NSString*)key;

- (void)dump;
- (void)clearSession;


- (NSString*)selectedGenreForUrl:(NSURL*)url;
- (void)setGenre:(NSString*)genre forUrl:(NSURL*)url;

@end
