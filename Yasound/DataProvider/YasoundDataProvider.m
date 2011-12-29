//
//  YasoundDataProvider.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YasoundDataProvider.h"
#import "ApiKey.h"


#define USE_LOCAL_SERVER 0

#define LOCAL_URL @"http://127.0.0.1:8000"
#define DEV_URL @"https://dev.yasound.com"

#define APP_KEY_COOKIE_NAME @"app_key"
#define APP_KEY_IPHONE @"yasound_iphone_app"

@interface YasoundDataProvider (internal)

- (void)login:(NSString*)username password:(NSString*)pwd target:(id)target action:(SEL)selector userData:(NSDictionary*)userData;

@end



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
    [resourceNames setObject:@"api_key" forKey:[ApiKey class]];
  }
  
  return self;
}

- (Auth*)apiKeyAuth
{
  AuthApiKey* auth = [[AuthApiKey alloc] initWithUsername:_user.username andApiKey:_apiKey];
  return auth;
}

- (Auth*)passwordAuth
{
  AuthPassword* auth = [[AuthPassword alloc] initWithUsername:_user.username andPassword:_password];
  return auth;
}

- (AuthCookie*)appAuth
{
  AuthCookie* auth = [[AuthCookie alloc] initWithUsername:APP_KEY_COOKIE_NAME andCookieValue:APP_KEY_IPHONE];
  return auth;
}

- (NSURL*)urlForPicture:(NSString*)picturePath
{
  if (!_communicator || !picturePath)
    return nil;

  NSURL* url = [_communicator urlWithURL:picturePath absolute:NO addTrailingSlash:NO params:nil];
  return url;
}





// SIGN UP
- (void)signup:(NSString*)username password:(NSString*)pwd email:(NSString*)email target:(id)target action:(SEL)selector
{
  _user = nil;
  _apiKey = nil;
  
  User* user = [[User alloc] init];
  user.username = email;
  user.email = email;
  user.name = username;
  user.password = pwd;
  
  AuthCookie* auth = [self appAuth];
  NSDictionary* userData = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", user.username, @"username", user.password, @"password", nil];
  
  [_communicator postNewObject:user withURL:@"api/v1/signup" absolute:NO notifyTarget:self byCalling:@selector(didReceiveSignup:withInfo:) withUserData:userData withAuth:auth returnNewObject:NO withAuthForGET:NO];
}

- (void)didReceiveSignup:(NSString*)location withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  if (!userData)
    return;
  
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  NSString* username = [userData valueForKey:@"username"];
  NSString* pwd = [userData valueForKey:@"password"];
  
  NSError* error = [info valueForKey:@"error"];
  if (error)
  {
    NSLog(@"signup error: %@", error.domain);    
    if (target && selector)
    {
      NSDictionary* finalInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil];
      [target performSelector:selector withObject:nil withObject:finalInfo];
    }
  }
  NSDictionary* loginUserData = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
  
  [self login:username password:pwd target:self action:@selector(didReceiveNewUserLogin:withInfo:) userData:loginUserData];
}

- (void)didReceiveNewUserLogin:(User*)user withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  if (!userData)
    return;
  
  NSDictionary* finalInfo = [[NSMutableDictionary alloc] init];
  
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  NSError* error = [info valueForKey:@"error"];
  if (error)
  {
    NSLog(@"login error: %@", error.domain);    
    [finalInfo setValue:error forKey:@"error"];
  }
  
  if (user && user.api_key)
  {
    _user = user;
    _apiKey = user.api_key;
  }
  else
  {
    error = [NSError errorWithDomain:@"user invalid" code:2 userInfo:nil];
    [finalInfo setValue:error forKey:@"error"];
  }

  if (target && selector)
  {
    [target performSelector:selector withObject:user withObject:finalInfo];
  }

}

- (void)login:(NSString*)username password:(NSString*)pwd target:(id)target action:(SEL)selector userData:(NSDictionary*)userData
{
  _user = nil;
  _password = pwd;
  Auth* a = [[AuthPassword alloc] initWithUsername:username andPassword:_password];
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", userData, @"clientData", nil];
  [_communicator getObjectsWithClass:[User class] withURL:@"api/v1/login" absolute:NO notifyTarget:self byCalling:@selector(receiveLogin:withInfo:) withUserData:data withAuth:a];
}

- (void)login:(NSString*)username password:(NSString*)pwd target:(id)target action:(SEL)selector
{
  [self login:username password:pwd target:target action:selector userData:nil];
}

- (void)receiveLogin:(NSArray*)users withInfo:(NSDictionary*)info
{
  NSMutableDictionary* finalInfo = [[NSMutableDictionary alloc] init];
  
  User* u = nil;
  if (!users || [users count] == 0)
  {
    NSError* err = [NSError errorWithDomain:@"no logged users" code:1 userInfo:nil];
    [finalInfo setValue:err forKey:@"error"];
  }
  else
  {
    u = [users objectAtIndex:0];
  }
  
  if (u && u.api_key)
  {
    _user = u;
    _apiKey = u.api_key;
  }
  
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  NSDictionary* clientData = [userData valueForKey:@"clientData"];
  if (clientData)
    [finalInfo setValue:clientData forKey:@"userData"];
  
  if (target && selector)
  {
    [target performSelector:selector withObject:_user withObject:finalInfo];
  }
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


- (void)updatePlaylists:(NSData*)data forRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/playlists", radioID];
  NSDictionary* userData = [NSDictionary dictionaryWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", nil];
  [_communicator postData:data withKey:@"playlists_data" toURL:relativeUrl absolute:NO notifyTarget:self byCalling:@selector(receiveUpdatePlaylistsResponse:withInfo:) withUserData:userData withAuth:nil];
  
}

- (void)receiveUpdatePlaylistsResponse:(NSString*)response withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"target"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"selector"]);
  NSError* error = [info valueForKey:@"error"];
  
  if (error)
  {
    [target performSelector:selector withObject:nil withObject:error];
    return;
  }
  
  taskID task_id = response;
  if (!task_id)
  {
    error = [NSError errorWithDomain:@"can't retrieve task ID from request response" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, @"response", nil]];
    [target performSelector:selector withObject:nil withObject:error];
    return;
  }
   
  [target performSelector:selector withObject:task_id withObject:nil];
}

- (void)taskStatus:(taskID)task_id target:(id)target action:(SEL)selector
{
  if (task_id == nil)
    return;
  
  NSString* url = [NSString stringWithFormat:@"api/v1/task/%@", task_id];
  NSDictionary* userData = [NSDictionary dictionaryWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", nil];
  [_communicator getURL:url absolute:NO notifyTarget:self byCalling:@selector(receiveTaskStatus:withInfo:) withUserData:userData withAuth:nil];
}

- (void)receiveTaskStatus:(NSString*)response withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"target"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"selector"]);
  NSError* error = [info valueForKey:@"error"];
  taskStatus status = stringToStatus(response);
  
  [target performSelector:selector withObject:status withObject:error];
}

@end



taskStatus stringToStatus(NSString* str)
{
  taskStatus status = eTaskStatusNone;
  if ([str isEqualToString:@"PENDING"])
    status = eTaskPending;
  else if ([str isEqualToString:@"STARTED"])
    status = eTaskStarted;
    else if ([str isEqualToString:@"RETRY"])
      status = eTaskRetry;
    else if ([str isEqualToString:@"FAILURE"])
      status = eTaskFailure;
    else if ([str isEqualToString:@"SUCCESS"])
      status = eTaskSuccess;
  
  return status;
}
