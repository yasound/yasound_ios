//
//  YasoundDataProvider.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YasoundDataProvider.h"


#define USE_LOCAL_SERVER 1

#define LOCAL_URL @"http://127.0.0.1:8000"
#define DEV_URL @"https://dev.yasound.com"

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
#if USE_LOCAL_SERVER
    baseUrl = LOCAL_URL;
    NSLog(@"use LOCAL SERVER '%@'", baseUrl);
#else
    baseUrl = DEV_URL;
    NSLog(@"use DEV SERVER '%@'", baseUrl);
#endif
    _communicator = [[Communicator alloc] initWithBaseURL:baseUrl];
    
    NSMutableDictionary* resourceNames = [Model resourceNames];
    [resourceNames setObject:@"radio" forKey:[Radio class]];
    [resourceNames setObject:@"user" forKey:[User class]];
    [resourceNames setObject:@"wall_event" forKey:[WallEvent class]];
    [resourceNames setObject:@"metadata" forKey:[SongMetadata class]];
    [resourceNames setObject:@"song" forKey:[Song class]];
  }
  
  return self;
}

- (NSURL*)urlForPicture:(NSString*)picturePath
{
  if (!_communicator || !picturePath)
    return nil;

  NSURL* url = [_communicator urlWithURL:picturePath absolute:NO addTrailingSlash:NO params:nil];
  return url;
}

- (void)radiosTarget:(id)target action:(SEL)selector
{
  [_communicator getObjectsWithClass:[Radio class] notifyTarget:target byCalling:selector withUserData:nil withAuth:nil];
}


- (void)radioWithID:(int)ID target:(id)target action:(SEL)selector;
{
  [_communicator getObjectWithClass:[Radio class] andID:[NSNumber numberWithInt:ID] notifyTarget:target byCalling:selector withUserData:nil withAuth:nil];
}

- (void)radioWithURL:(NSString*)url target:(id)target action:(SEL)selector
{
  [_communicator getObjectsWithClass:[WallEvent class] withURL:url absolute:YES notifyTarget:target byCalling:selector withUserData:nil withAuth:nil];
}



- (void)createRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  [_communicator postNewObject:radio notifyTarget:target byCalling:selector withUserData:nil withAuth:nil returnNewObject:YES withAuthForGET:nil];
}



// get wall events
- (void)wallEventsForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/wall", radioID];
  [_communicator getObjectsWithClass:[WallEvent class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:nil];
}

- (void)postNewWallMessage:(WallEvent*)message target:(id)target action:(SEL)selector
{
  [_communicator postNewObject:message notifyTarget:target byCalling:selector withUserData:nil withAuth:nil returnNewObject:NO withAuthForGET:nil];
}






- (void)likersForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/likes", radioID];
  [_communicator getObjectsWithClass:[User class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:nil];
}

- (void)connectedUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/connected_users", radioID];
  [_communicator getObjectsWithClass:[User class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:nil];
}

- (void)songsForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/songs", radioID];
  [_communicator getObjectsWithClass:[WallEvent class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:nil];
}

@end
