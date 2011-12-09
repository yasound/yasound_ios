//
//  YasoundDataProvider.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YasoundDataProvider.h"
#import "WallEvent.h"

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
  }
  
  return self;
}




// get wall events
- (void)getWallEventsForRadio:(Radio*)radio notifyTarget:(id)target byCalling:(SEL)selector
{
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"radio/%@/wall", radioID];
  [_communicator getObjectsWithClass:[WallEvent class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector];
}

@end
