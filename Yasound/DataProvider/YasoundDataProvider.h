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

@interface YasoundDataProvider : NSObject
{
  Communicator* _communicator;
}

+ (YasoundDataProvider*) main;

- (void)radiosTarget:(id)target action:(SEL)selector;

- (void)radioWithID:(int)ID target:(id)target action:(SEL)selector;
- (void)radioWithURL:(NSString*)url target:(id)target action:(SEL)selector;

- (void)wallEventsForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)likersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;
- (void)connectedUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)songsForRadio:(Radio*)radio target:(id)target action:(SEL)selector;

- (void)postNewWallMessage:(WallEvent*)message target:(id)target action:(SEL)selector;

- (void)postNewSongMetadata:(SongMetadata*)metadata target:(id)target action:(SEL)selector;

@end
