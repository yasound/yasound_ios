//
//  UserSettings.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 06/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSettings : NSObject

#define USKEYnowPlaying @"NowPlaying"

#define USKEYfacebookAccessTokenKey @"FBAccessTokenKey"
#define USKEYfacebookExpirationDateKey @"FBExpirationDateKey"

#define USKEYtwitterAccountId @"twitterAccountIdentifier"
#define USKEYtwitterOAuthUsername @"oauth_username"
#define USKEYtwitterOAuthUserId @"oauth_userid"
#define USKEYtwitterOAuthScreenname @"oauth_name"
#define USKEYtwitterOAuthToken @"token"


#define USKEYuserId @"LastConnectedUserID"
#define USKEYskipRadioCreation @"skipRadioCreationSendToSelection"

#define USKEYuploadLegalWarning @"legalUploadWarning"
#define USKEYuploadAddedWarning @"addedUploadWarning"
#define USKEYuploadList @"SongUploads"

#define USKEYtutorials @"Tutorials"


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


@end
