//
//  YasoundDataProvider.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YasoundDataProvider.h"


#define LOCAL_SERVER 1

#define LOCAL_URL @"http://127.0.0.1:8000/api/v1"
#define DEV_URL @"http://127.0.0.1:8000/api/v1" // #FIXME: set real url

@implementation YasoundDataProvider

static YasoundDataProvider* _main = nil;

+ (YasoundDataProvider*) main
{
  if (_main == nil)
  {
    _main = [[YasoundDataProvider alloc] init];
  }
  
  return _main;
}


- (id)init
{
  self = [super init];
  if (self)
  {
    NSString* baseUrl;
#if LOCAL_SERVER
    baseUrl = LOCAL_URL;
#else
    baseUrl = DEV_URL;
#endif
    _communicator = [[Communicator alloc] initWithBaseURL:baseUrl];
    
    [_communicator mapResourcePath:@"radio" toObject:[Radio class]];
    [_communicator mapResourcePath:@"user" toObject:[User class]];
    [_communicator mapResourcePath:@"wall_event" toObject:[WallEvent class]];
    [_communicator mapResourcePath:@"metadata" toObject:[SongMetadata class]];
  }
  
  return self;
}




- (void)radioWithID:(int)ID target:(id)target action:(SEL)selector;
{
  [_communicator getObjectWithClass:[Radio class] andID:[NSNumber numberWithInt:ID] notifyTarget:target byCalling:selector];
}

- (void)radioWithURL:(NSString*)url target:(id)target action:(SEL)selector
{
  [_communicator getObjectsWithClass:[WallEvent class] withURL:url absolute:YES notifyTarget:target byCalling:selector];
}

// get wall events
- (void)wallEventsForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"radio/%@/wall", radioID];
  [_communicator getObjectsWithClass:[WallEvent class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector];
}

- (void)postNewWallMessage:(WallEvent*)message target:(id)target action:(SEL)selector
{
  [_communicator postNewObject:message notifyTarget:target byCalling:selector];
}






- (void)likersForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"radio/%@/likes", radioID];
  [_communicator getObjectsWithClass:[User class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector];
}

- (void)connectedUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"radio/%@/connected_users", radioID];
  [_communicator getObjectsWithClass:[User class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector];
}

- (void)postNewSongMetadata:(SongMetadata*)metadata target:(id)target action:(SEL)selector
{
  [_communicator postNewObject:metadata notifyTarget:target byCalling:selector];
}

@end
