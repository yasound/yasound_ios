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

@interface YasoundDataProvider : NSObject
{
  Communicator* _communicator;
  User* _user;
  ApiKey* _apiKey;
  NSString* _password;
}

@property (readonly) Auth* apiKeyAuth;
@property (readonly) Auth* passwordAuth;

+ (YasoundDataProvider*) main;

- (void)login:(NSString*)login password:(NSString*)pwd target:(id)target action:(SEL)selector;

- (void)radiosTarget:(id)target action:(SEL)selector;
- (void)radioWithID:(int)ID target:(id)target action:(SEL)selector;
- (void)radioWithURL:(NSString*)url target:(id)target action:(SEL)selector;

- (void)createRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)wallEventsForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)likersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)connectedUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)songsForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)postNewWallMessage:(WallEvent*)message target:(id)target action:(SEL)selector;

- (NSURL*)urlForPicture:(NSString*)picturePath;


- (void)updatePlaylists:(NSData*)data ForRadio:(Radio*)radio;

@end
