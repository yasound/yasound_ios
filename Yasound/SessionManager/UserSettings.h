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
#define USKEYuserId @"LastConnectedUserID"
#define USKEYskipRadioCreation @"skipRadioCreationSendToSelection"


+ (UserSettings*)main;

- (void)setValue:(id)value forKey:(NSString*)key;
- (id)valueForKey:(NSString*)key;

- (void)setBool:(BOOL)value forKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key error:(BOOL*)error;

- (void)setInteger:(NSInteger)value forKey:(NSString*)key;
- (NSInteger)integerForKey:(NSString*)key error:(BOOL*)error;

- (void)removeObjectKey:(NSString*)key;


@end
