//
//  YasoundDataProvider.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YasoundDataProvider.h"
#import "UIImage+Resize.h"
#import "NSObject+SBJson.h"
#import "YasoundAppDelegate.h"
#import "UIDevice+IdentifierAddition.h"
#import "ASIFormDataRequest.h"
#import "ProgrammingObjectParameters.h"
#import "FacebookFriend.h"
#import "Contact.h"

#define LOCAL_URL @"http://127.0.0.1:8000"

#define APP_KEY_COOKIE_NAME @"app_key"
#define APP_KEY_IPHONE @"yasound_iphone_app"

#define MAX_IMAGE_DIMENSION 1024

@implementation TaskInfo

@synthesize status;
@synthesize progress;
@synthesize message;

- (void)loadWithStatus:(taskStatus)s progress:(float)p message:(NSString*)m
{
  self.status = s;
  self.progress = p;
  self.message = m;
}


- (void)loadWithDictionary:(NSDictionary*)desc
{
  if (!desc)
    return;
  taskStatus s = eTaskStatusNone;
  float p = 0;
  NSString* m = nil;
  
  NSString* statusStr = [desc valueForKey:@"status"];
  s = stringToStatus(statusStr);
  NSNumber* progressNumber = (NSNumber*)[desc valueForKey:@"progress"];
  if (progressNumber)
    p = [progressNumber floatValue];
  NSString* msg = [desc valueForKey:@"message"];
  m = msg;
  
  [self loadWithStatus:s progress:p message:m];
}

- (void)loadWithString:(NSString*)desc
{
  if (!desc)
    return;
  NSDictionary* descDict = [desc JSONValue];
  [self loadWithDictionary:descDict];
}


- (id)initWithStatus:(taskStatus)s progress:(float)p message:(NSString*)m
{
  self = [super init];
  if (self)
  {
    self.status = eTaskStatusNone;
    self.progress = 0;
    self.message = nil;
    
    [self loadWithStatus:s progress:p message:m];
  }
  return self;
}


- (id)initWithDictionary:(NSDictionary*)desc
{
  self = [super init];
  if (self)
  {
    self.status = eTaskStatusNone;
    self.progress = 0;
    self.message = nil;
    
    [self loadWithDictionary:desc];
  }
  return self;
}

- (id)initWithString:(NSString*)desc
{
  self = [super init];
  if (self)
  {
    self.status = eTaskStatusNone;
    self.progress = 0;
    self.message = nil;
    
    [self loadWithString:desc];
  }
  return self;
}

+ (TaskInfo*)taskInfoWithStatus:(taskStatus)s progress:(float)p message:(NSString*)m
{
  TaskInfo* info = [[[TaskInfo alloc] initWithStatus:s progress:p message:m] autorelease];
  return info;
}

+ (TaskInfo*)taskInfoWithDictionary:(NSDictionary*)desc
{
  TaskInfo* info = [[[TaskInfo alloc] initWithDictionary:desc] autorelease];
  return info;
}

+ (TaskInfo*)taskInfoWithString:(NSString*)desc
{
  TaskInfo* info = [[[TaskInfo alloc] initWithString:desc] autorelease];
  return info;
}

@end

@interface YasoundDataProvider (internal)

- (void)login:(NSString*)username password:(NSString*)pwd target:(id)target action:(SEL)selector userData:(NSDictionary*)userData;

@end



@implementation YasoundDataProvider

@synthesize user = _user;
@synthesize radio = _radio;

static YasoundDataProvider* _main = nil;

+ (YasoundDataProvider*) main
{
  if (_main == nil)
  {
    _main = [[YasoundDataProvider alloc] init];
  }
  
  return _main;
}


+ (NSNumber*) user_id {
    
    if ([YasoundDataProvider main].user == nil)
        return nil;
    return [YasoundDataProvider main].user.id;
}


+ (NSString*) username {
    
    if ([YasoundDataProvider main].user == nil)
        return nil;
    return [YasoundDataProvider main].user.username;
}


+ (NSString*) user_apikey {
    
    if ([YasoundDataProvider main].user == nil)
        return nil;
    return [YasoundDataProvider main].user.api_key;
}


+ (BOOL) isAuthenticated {
    if ([YasoundDataProvider main].user == nil)
    {
        return NO;
    }
    return YES;
}












- (id)init
{
  self = [super init];
  if (self)
  {
    NSString* baseUrl;
#if USE_YASOUND_LOCAL_SERVER
    baseUrl = LOCAL_URL;
    DLog(@"use LOCAL SERVER '%@'", baseUrl);
#else
      baseUrl = APPDELEGATE.serverURL;
    DLog(@"use PROD SERVER '%@'", baseUrl);
#endif
      
      [YaRequest globalInit];
      [YaRequest setBaseURL:baseUrl];
      
    _communicator = [[Communicator alloc] initWithBaseURL:baseUrl];
    _communicator.appCookie = self.appCookie;
    
      // DEFAULT TIMEOUT
      [ASIHTTPRequest setDefaultTimeOutSeconds:60];

    
    NSMutableDictionary* resourceNames = [Model resourceNames];
    [resourceNames setObject:@"radio" forKey:[Radio class]];
    [resourceNames setObject:@"user" forKey:[User class]];
    [resourceNames setObject:@"wall_event" forKey:[WallEvent class]];
    //        [resourceNames setObject:@"metadata" forKey:[SongMetadata class]];
    [resourceNames setObject:@"song" forKey:[Song class]];
    [resourceNames setObject:@"api_key" forKey:[ApiKey class]];
    [resourceNames setObject:@"radio_user" forKey:[RadioUser class]];
    [resourceNames setObject:@"song_user" forKey:[SongUser class]];
    [resourceNames setObject:@"next_song" forKey:[NextSong class]];
  }
  
  return self;
}

- (int)cancelRequestsForKey:(NSString*)key
{
    int count = [_communicator cancelRequestsForKey:key];
    return count;
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

- (NSHTTPCookie*)appCookie
{
  NSDictionary* properties = [[[NSMutableDictionary alloc] init] autorelease];
  [properties setValue:APP_KEY_IPHONE forKey:NSHTTPCookieValue];
  [properties setValue:APP_KEY_COOKIE_NAME forKey:NSHTTPCookieName];
  [properties setValue:@"yasound.com" forKey:NSHTTPCookieDomain];
  [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
  [properties setValue:@"/yasound/app_auth" forKey:NSHTTPCookiePath];
  NSHTTPCookie* cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
  
  return cookie;
}

- (NSURL*)urlForPicture:(NSString*)picturePath
{
  if (!_communicator || !picturePath)
    return nil;
  
  BOOL absolute = [picturePath hasPrefix:@"http"];
  NSURL* url = [_communicator urlWithURL:picturePath absolute:absolute addTrailingSlash:NO params:nil];
    
  return url;
}

- (NSURL*)urlForSongCover:(Song*)song
{
  if (!song || !song.id)
    return nil;
  
  AuthApiKey* a = (AuthApiKey*)self.apiKeyAuth;
  NSArray* params = a.urlParams;
  
  NSString* base = [NSString stringWithFormat:@"api/v1/song_instance/%@/cover/", song.id];
  NSURL* url = [_communicator urlWithURL:base absolute:NO addTrailingSlash:NO params:params];
  return url;
}

- (void)resetUser
{
  _user = nil;
  _radio = nil;
  _apiKey = nil;
    _password = nil;
}

- (void)userLogged
{
    [self sendAPNsDeviceTokenWhenLogged];
}

- (void)reloadUserWithCompletionBlock:(void (^) (User*))block
{
    if (self.user == nil || self.user.id == nil)
    {
        if (block)
            block(nil);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"/api/v1/user/%@/", self.user.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:^(int status, NSString* response, NSError* error){
        User* u = nil;
        if (error)
            u = nil;
        else if (status != 200)
            u = nil;
        else
            u = (User*)[response jsonToModel:[User class]];
        
        _user = u;
        if (block)
            block(u);
    }];
}


#pragma mark - APNs device token

- (BOOL)sendAPNsDeviceToken:(NSString*)deviceToken isSandbox:(BOOL)sandbox
{
    if (!self.user || !deviceToken)
        return NO;
    
    APNsDeviceToken* token = [[APNsDeviceToken alloc] init];
    token.device_token = deviceToken;
    if (sandbox)
        [token setSandbox];
    else
        [token setProduction];
    
    NSString* uuid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    token.uuid = uuid;
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/ios_push_notif_token";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = [[token JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"send APNs device token error: %d - %@", error.code, error.domain);
        }
        else if (status != 200)
        {
            DLog(@"send APNs device token error: response status %d", status);
        }
    }];

    return YES;
}

- (void)sendAPNsDeviceTokenWhenLogged
{
  YasoundAppDelegate* appDelegate =  [UIApplication sharedApplication].delegate;
  [appDelegate sendAPNsTokenString];
}


- (void)userRadioWithTargetWithCompletionBlock:(void (^) (Radio*))block
{
    if (!_user)
    {
        if (block)
            block(nil);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/radio/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObjectsAndKeys:[_user.id stringValue], @"creator", @"1", @"limit", nil];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:^(int status, NSString* response, NSError* error){
        Radio* radio = nil;
        if (error)
            radio = nil;
        else if (status != 200)
            radio = nil;
        else
        {
            Container* radioContainer = [response jsonToContainer:[Radio class]];
            if (!radioContainer)
                radio = nil;
            else if (radioContainer.objects.count == 0)
                radio = nil;
            else
                radio = [radioContainer.objects objectAtIndex:0];
        }
        
        // store radio
        if (radio)
            _radio = radio;
        //send it
        if (block)
            block(radio);
    }];
}

//- (void)didReceiveUserRadios:(NSArray*)radios withInfo:(NSDictionary*)info
//{
//  NSMutableDictionary* finalInfo = [NSMutableDictionary dictionaryWithDictionary:info];
//  
//  Radio* r = nil;
//  if (!radios || [radios count] == 0)
//  {
//      NSString* str = [NSString stringWithFormat:@"no radio for user '%@'", _user.username];
//      DLog(@"didReceiveUserRadios : %@", str);
//      
//    NSError* err = [NSError errorWithDomain:str code:1 userInfo:nil];
//    [finalInfo setValue:err forKey:@"error"];
//  }
//  else
//  {
//    r = [radios objectAtIndex:0];
//  }
//  
//  if (r)
//  {
//    _radio = r;
//  }
//  
//  NSDictionary* userData = [info valueForKey:@"userData"];
//  id target = [userData valueForKey:@"clientTarget"];
//  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
//    
//  if (target && selector)
//  {
//      if ([target respondsToSelector:selector])
//          [target performSelector:selector withObject:_radio withObject:finalInfo];
//  }
//}



- (void)reloadUserRadio
{
    [self userRadioWithTargetWithCompletionBlock:nil];
}

//- (void)reloadedUserRadio:(Radio*)r withInfo:(NSDictionary*)info
//{
//  if (!r)
//    return;
//  
//  _radio = r;
//}

//
//
// SIGN UP
//
//
// sign up process = signup request + login request
//

- (void)signup:(NSString*)email password:(NSString*)pwd username:(NSString*)username target:(id)target action:(SEL)selector
{
  [self resetUser];
  
  User* u = [[User alloc] init];
  u.username = username;
  u.name = username;
  u.email = email;
  u.password = pwd;
  
  NSDictionary* userData = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", u.email, @"email", u.password, @"password", nil];
  
  [_communicator postNewObject:u withURL:@"api/v1/signup" absolute:NO notifyTarget:self byCalling:@selector(didReceiveSignup:withInfo:) withUserData:userData withAuth:nil returnNewObject:NO withAuthForGET:NO];
}

- (void)didReceiveSignup:(NSString*)location withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  if (!userData)
    return;
  
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  NSString* email = [userData valueForKey:@"email"];
  NSString* pwd = [userData valueForKey:@"password"];
  
  NSError* error = [info valueForKey:@"error"];
  if (!location && !error)
    error = [NSError errorWithDomain:@"can't create user" code:1 userInfo:nil];
  if (error)
  {
    DLog(@"signup error: %@", error.domain);    
    if (target && selector)
    {
      NSDictionary* finalInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil];
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:nil withObject:finalInfo];
    }
  }
  NSDictionary* loginUserData = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
  
  [self login:email password:pwd target:self action:@selector(didReceiveNewUserLogin:withInfo:) userData:loginUserData];
}

- (void)didReceiveNewUserLogin:(User*)u withInfo:(NSDictionary*)info
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
    DLog(@"login error: %@", error.domain);    
    [finalInfo setValue:error forKey:@"error"];
  }
  
  if (u && u.api_key)
  {
    _user = u;
    _apiKey = u.api_key;
  }
  else
  {
    error = [NSError errorWithDomain:@"user invalid" code:2 userInfo:nil];
    [finalInfo setValue:error forKey:@"error"];
  }
  
  if (target && selector)
  {
      if ([target respondsToSelector:selector])
          [target performSelector:selector withObject:_user withObject:finalInfo];
  }
  
}




#pragma mark - Login Yasound


- (void)login:(NSString*)email password:(NSString*)pwd target:(id)target action:(SEL)selector userData:(NSDictionary*)userData
{
  [self resetUser];
  _password = pwd;
  Auth* a = [[AuthPassword alloc] initWithUsername:email andPassword:_password];
  
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", userData, @"clientData", nil];
  [_communicator getObjectsWithClass:[User class] withURL:@"api/v1/login" absolute:NO notifyTarget:self byCalling:@selector(receiveLogin:withInfo:) withUserData:data withAuth:a];
}

- (void)login:(NSString*)username password:(NSString*)pwd target:(id)target action:(SEL)selector
{
  [self login:username password:pwd target:target action:selector userData:nil];
}

//
// receive logged user (via yasound identification protocol)
//
- (void)receiveLogin:(NSArray*)users withInfo:(NSDictionary*)info
{
    NSMutableDictionary* finalInfo = [NSMutableDictionary dictionaryWithDictionary:info];

    NSDictionary* userData = [info valueForKey:@"userData"];
    id target = [userData valueForKey:@"clientTarget"];
    SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
    NSDictionary* clientData = [userData valueForKey:@"clientData"];


    User* u = nil;
    if (!users || [users count] == 0)
    {
        NSError* err = [NSError errorWithDomain:@"no logged user" code:1 userInfo:nil];
        [finalInfo setValue:err forKey:@"error"];
        [finalInfo setObject:[NSNumber numberWithBool:NO] forKey:@"succeeded"];
        
        // return if error
        if ((target != nil) && (selector != nil))
            if ([target respondsToSelector:selector])
                [target performSelector:selector withObject:nil withObject:finalInfo];
        
        return;
    }


    [finalInfo setObject:[NSNumber numberWithBool:YES] forKey:@"succeeded"];

    u = [users objectAtIndex:0];

    if (u && u.api_key)
    {
    _user = u;
    _apiKey = u.api_key;
    }

    if ([target respondsToSelector:selector])
      [target performSelector:selector withObject:_user withObject:finalInfo];

    
    [self userLogged];
}




#pragma mark - Login Facebook and Twitter

- (void)loginSocialWithAuth:(AuthSocial*)auth target:(id)target action:(SEL)selector
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
  [_communicator getObjectsWithClass:[User class] withURL:@"api/v1/login_social/" absolute:NO notifyTarget:self byCalling:@selector(didReceiveLoginSocial:withInfo:) withUserData:data withAuth:auth];
}

//
// facebook
//
- (void)loginFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token  expirationDate:(NSString*)expirationDate email:(NSString*)email target:(id)target action:(SEL)selector
{
  AuthSocial* auth = [[AuthSocial alloc] initWithUsername:username accountType:type uid:uid token:token  expirationDate:expirationDate andEmail:email];
  [self loginSocialWithAuth:auth target:target action:selector];
}

//
// twitter
//
- (void)loginTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email target:(id)target action:(SEL)selector
{
  AuthSocial* auth = [[AuthSocial alloc] initWithUsername:username accountType:type uid:uid token:token tokenSecret:tokenSecret andEmail:email];
  [self loginSocialWithAuth:auth target:target action:selector];
}


//
// receive logged user (via social identification protocol)
//
- (void)didReceiveLoginSocial:(NSArray*)users withInfo:(NSDictionary*)info
{
  NSMutableDictionary* finalInfo = [[NSMutableDictionary alloc] init];
  
  User* u = nil;
  if (!users || [users count] == 0)
  {
    NSError* err = [NSError errorWithDomain:@"no logged user" code:1 userInfo:nil];
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

  if ([target respondsToSelector:selector])
    [target performSelector:selector withObject:_user withObject:finalInfo];
  

//  [self userRadioWithTarget:self action:@selector(didReceiveLoggedUserRadio:withInfo:) andData:data];
  
  // send Apple Push Notification service device token
  [self userLogged];
    
}

//- (void)didReceiveLoggedUserRadio:(Radio*)r withInfo:(NSDictionary*)info
//{
//  NSMutableDictionary* finalInfo = [NSMutableDictionary dictionary];
//  
//  NSDictionary* userData = [info valueForKey:@"userData"];
//  id target = [userData valueForKey:@"finalTarget"];
//  SEL selector = NSSelectorFromString([userData valueForKey:@"finalSelector"]);
//  NSDictionary* clientData = [userData valueForKey:@"clientData"];
//  
//  if (clientData)
//    [finalInfo setValue:clientData forKey:@"userData"];
//  
//  if (target && selector)
//  {
//      if ([target respondsToSelector:selector])
//          [target performSelector:selector withObject:_user withObject:finalInfo];
//  }  
//}






#pragma mark - Accounts Association

- (void)associateAccountYasound:(NSString*)email password:(NSString*)pword withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/account/association";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObjectsAndKeys:@"yasound", @"account_type", email, @"email", pword, @"password", nil];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)associateAccountFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token  expirationDate:(NSString*)expirationDate email:(NSString*)email withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/account/association";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObjectsAndKeys:@"facebook", @"account_type", username, @"social_username", uid, @"uid", token, @"token", expirationDate, @"expiration_date", email, @"email", nil];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)associateAccountTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/account/association";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObjectsAndKeys:@"twitter", @"account_type", username, @"social_username", uid, @"uid", token, @"token", tokenSecret, @"token_secret", email, @"email", nil];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


#pragma mark - Accounts Dissociation

- (void)dissociateAccount:(NSString*)accountTypeIdentifier withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/account/dissociation";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObject:accountTypeIdentifier forKey:@"account_type"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}















#pragma mark - requests about radios

- (void)radioWithId:(NSNumber*)radioId withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"/api/v1/radio/%@/", radioId];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


#pragma mark - Friends

- (void)friendsWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"/api/v1/friend";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)friendsForUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/user/%@/friends", user.username];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

//
// radios lists
//


- (void)radiosWithUrl:(NSString*)url withGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = url;
    conf.key = @"radios";
    conf.urlIsAbsolute = NO;
    conf.method = @"GET";
    conf.auth = self.apiKeyAuth;
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    if (userData)
        conf.userData = userData;
    if (genre)
    {
        NSArray* params = [NSArray arrayWithObject:[NSString stringWithFormat:@"genre=%@", genre]];
        conf.params = params;
    }
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    
    DLog(@"radiosWithUrl '%@'", req.url);
    
    [req startAsynchronous];
}

- (void)favoriteRadiosForUser:(User*)u withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"/api/v1/user/%@/favorite_radio", u.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)radiosForUser:(User*)u withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/user/%@/radios", u.username];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.groupKey = @"radios";
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}



- (void)createRadioWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"/api/v1/my_radios/";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)deleteRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"/api/v1/my_radios/%@/", radio.uuid];
    config.urlIsAbsolute = NO;
    config.method = @"DELETE";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}



#pragma mark - search radios

- (void)searchRadios:(NSString*)search withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"/api/v1/search/radios";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObject:search forKey:@"q"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

#pragma mark - update radio

- (void)updateRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"/api/v1/radio/%@/", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"PUT";
    config.auth = self.apiKeyAuth;
    config.payload = [[radio JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


-(UIImage*)resizeImage:(UIImage*)img
{
  CGFloat w = img.size.width;
  CGFloat h = img.size.height;
  if (w >= h)
  {
    float ratio = MAX_IMAGE_DIMENSION / w;
    w = MAX_IMAGE_DIMENSION;
    h *= ratio;
  }
  else
  {
    float ratio = MAX_IMAGE_DIMENSION / h;
    h = MAX_IMAGE_DIMENSION;
    w *= ratio;
  }
  CGSize size = CGSizeMake(w, h);
  UIImage* newImg = [img resizedImage:size interpolationQuality:kCGInterpolationDefault];
  return newImg;
}

- (void)setPicture:(UIImage*)img forRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    DLog(@"img %f, %f", img.size.width, img.size.height);
    UIImage* resizedImg = [self resizeImage:img];
    DLog(@"resized img %f, %f", resizedImg.size.width, resizedImg.size.height);
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/picture", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.fileData = [NSDictionary dictionaryWithObject:UIImagePNGRepresentation(resizedImg) forKey:@"picture"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (BOOL)updateUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (user == nil)
    {
        DLog(@"YasoundDataProvider:updateUser user is nil!");
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return NO;
    }
    
    //LBDEBUG
    if (![user.id isKindOfClass:[NSNumber class]])
    {
        [self updateUserIsNotNumber:user];
        assert(0);
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return NO;
    }

    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/user/%@/", user.id];
    config.urlIsAbsolute = NO;
    config.method = @"PUT";
    config.auth = self.apiKeyAuth;
    config.payload = [[user JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
    return YES;
}

//- (BOOL)updateUser:(User*)user target:(id)target action:(SEL)selector
//{
//    if (user == nil)
//    {
//        DLog(@"YasoundDataProvider:updateUser user is nil!");
//        return NO;
//    }
//    
//    //LBDEBUG
//    if (![user.id isKindOfClass:[NSNumber class]])
//    {
//        [self updateUserIsNotNumber:user];
//        assert(0);
//        return NO;
//    }
//    
//    
//    RequestConfig* conf = [[RequestConfig alloc] init];
//    conf.url = [NSString stringWithFormat:@"api/v1/user/%@/", user.id];
//    conf.urlIsAbsolute = NO;
//    conf.auth = self.apiKeyAuth;
//    conf.method = @"PUT";
//    conf.callbackTarget = target;
//    conf.callbackAction = selector;
//    
//    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
//    
//    NSString* stringData = [user JSONRepresentation];
//    [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
//    [req addRequestHeader:@"Content-Type" value:@"application/json"];
//    
//    [req startAsynchronous];
//    return YES;
//}


- (void)updateUserIsNotNumber:(User*)user {
    
    DLog(@"ERROR updateUserIsNotNumber");

    if ([user.id isKindOfClass:[NSString class]])
        [self updateUserIsString:user];
    else if ([user.id isKindOfClass:[NSDate class]])
        [self updateUserIsDate:user];
    else
        [self updateUserIsSomethingElse:user];
}

- (void)updateUserIsString:(User*)user {
    DLog(@"ERROR updateUserIsString");
    DLog(@"%@", user.name);
}
- (void)updateUserIsDate:(User*)user {
    DLog(@"ERROR updateUserIsDate");
    DLog(@"%@", user.name);
}
- (void)updateUserIsSomethingElse:(User*)user {
    DLog(@"ERROR updateUserIsSomethingElse");
    DLog(@"%@", [user.id class]);
    DLog(@"%@", user.name);
}

//////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////

//- (void)setPicture:(UIImage*)img forUser:(User*)user target:(id)target action:(SEL)selector
//{
//  UIImage* resizedImg = [self resizeImage:img];
//  Auth* auth = self.apiKeyAuth;
//  NSString* url = [NSString stringWithFormat:@"api/v1/user/%@/picture", user.id];
//  [_communicator postData:UIImagePNGRepresentation(resizedImg) withKey:@"picture" toURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
//}

- (void)setPicture:(UIImage*)img forUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!user || !user.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    DLog(@"img %f, %f", img.size.width, img.size.height);
    UIImage* resizedImg = [self resizeImage:img];
    DLog(@"resized img %f, %f", resizedImg.size.width, resizedImg.size.height);
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/user/%@/picture", user.id];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.fileData = [NSDictionary dictionaryWithObject:UIImagePNGRepresentation(resizedImg) forKey:@"picture"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

#pragma mark - Wall events

- (NSString*)wallEventsRequestgroupKeyForRadio:(Radio*)radio
{
    if (!radio || !radio.id)
        return nil;
    NSString* key = [NSString stringWithFormat:@"%@-%@", @"get_wall_events_group_key", radio.id];
    return key;
}

- (void)cancelWallEventsRequestsForRadio:(Radio*)radio
{
    NSString* key = [self wallEventsRequestgroupKeyForRadio:radio];
    if (!key)
        return;
    [YaRequest cancelWithKey:key];
}

- (void)wallEventsForRadio:(Radio*)radio olderThanEventWithID:(NSNumber*)lastEventID newerThanEventWithID:(NSNumber*)firstEventID pageSizeNumber:(NSNumber*)pageSize withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (pageSize)
        [params setValue:[pageSize stringValue] forKey:@"limit"];
    if (lastEventID)
        [params setValue:[lastEventID stringValue] forKey:@"id__lt"];
    if (firstEventID)
        [params setValue:[firstEventID stringValue] forKey:@"id__gt"];
    
    NSString* groupKey = [self wallEventsRequestgroupKeyForRadio:radio];
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/wall", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.params = params;
    if (groupKey)
        config.groupKey = groupKey;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize withCompletionBlock:(YaRequestCompletionBlock)block
{
    [self wallEventsForRadio:radio olderThanEventWithID:nil newerThanEventWithID:nil pageSizeNumber:[NSNumber numberWithInt:pageSize] withCompletionBlock:block];
}

- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize olderThanEventWithID:(NSNumber*)lastEventID withCompletionBlock:(YaRequestCompletionBlock)block
{
    [self wallEventsForRadio:radio olderThanEventWithID:lastEventID newerThanEventWithID:nil pageSizeNumber:[NSNumber numberWithInt:pageSize] withCompletionBlock:block];
}

- (void)wallEventsForRadio:(Radio*)radio newerThanEventWithID:(NSNumber*)eventID withCompletionBlock:(YaRequestCompletionBlock)block
{
    [self wallEventsForRadio:radio olderThanEventWithID:nil newerThanEventWithID:eventID pageSizeNumber:nil withCompletionBlock:block];
}

- (void)postWallMessage:(NSString*)message toRadio:(Radio*)radio withCompletionBLock:(YaRequestCompletionBlock)block
{
    if (!message || !_user || !radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    WallMessagePost* msg = [[WallMessagePost alloc] init];
    msg.user = _user;
    msg.radio = radio;
    msg.type = @"M";
    msg.text = message;
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"/api/v1/wall_event";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = [[msg JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)moderationDeleteWallMessage:(NSNumber*)messageId
{
    if (!messageId)
    {
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/delete_message/%@", messageId];
    config.urlIsAbsolute = NO;
    config.method = @"DELETE";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:nil];
}

- (void)moderationReportAbuse:(NSNumber*)messageId;
{
    if (!messageId)
        return;
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/report_message/%@", messageId];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:^(int status, NSString* response, NSError* error){
        DLog(@"response: %@", response);
    }];
}



#pragma mark - connection to the wall

- (void)enterRadioWall:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!_user || !radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
        
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/connect", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)leaveRadioWall:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!_user || !radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/disconnect", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

#pragma radio users

- (void)favoriteUsersForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (radio == nil || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/favorite_user", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObject:@"0" forKey:@"limit"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)currentUsersForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (radio == nil || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/current_user", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObject:@"200" forKey:@"limit"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)currentSongForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (radio == nil || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/current_song", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)userWithId:(NSNumber*)userId withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (userId == nil)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/user/%@/", userId];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)userWithUsername:(NSString*)username withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (username == nil)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/public_user/%@", username];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

#pragma mark - follow user

- (void)followUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/user/%@/friends/%@", self.user.username, user.username];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)unfollowUser:(User*)user withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/user/%@/friends/%@", self.user.username, user.username];
    config.urlIsAbsolute = NO;
    config.method = @"DELETE";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)setRadio:(Radio*)radio asFavorite:(BOOL)favorite withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!radio || !radio.id)
    {
        block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    NSString* favoriteStr;
    if (favorite)
        favoriteStr = @"favorite";
    else
        favoriteStr = @"not_favorite";
    
    NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/%@", radio.id, favoriteStr];
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = url;
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];

}

- (void)radioHasBeenShared:(Radio*)radio with:(NSString*)shareType withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/shared", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = [[NSString stringWithFormat:@"{\"type\":\"%@\"}", shareType] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


- (void)setMood:(UserMood)mood forSong:(Song*)song withCompletionBlock:(YaRequestCompletionBlock)block
{
  if (!song || !song.id)
  {
      if (block)
          block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
      return;
  }
  
  NSString* moodStr;
  switch (mood) 
  {
    case eMoodLike:
      moodStr = @"liker";
      break;
      
    case eMoodNeutral:
      moodStr = @"neutral";
      break;
      
    case eMoodDislike:
      moodStr = @"disliker";
      break;
      
    case eMoodInvalid:
    default:
      return;
  }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/song/%@/%@", song.id, moodStr];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)updatePlaylists:(NSData*)data forRadio:(Radio*)radio withCompletionBlock:(void (^) (taskID))block
{
    if (!radio || !radio.id)
    {
        if (block)
            block(nil);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/playlists_update", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.fileData = [NSDictionary dictionaryWithObject:data forKey:@"playlists_data"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:^(int status, NSString* response, NSError* error){
        BOOL success = YES;
        if (error)
        {
            DLog(@"update playlists error: %d - %@", error.code, error.domain);
            success = NO;
        }
        else if (status != 200)
        {
            DLog(@"update playlist error: response status %d", status);
            success = NO;
        }
        else if (response == nil)
        {
            DLog(@"update playlist error: response nil");
            success = NO;
        }
        if (!success)
        {
            if (block)
                block(nil);
            return;
        }
        taskID task_id = response;
        if (block)
            block(task_id);
    }];
}

- (void)taskStatus:(taskID)task_id withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/task/%@", task_id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


- (void)radioRecommendationsWithArtistList:(NSData*)data genre:(NSString*)genre target:(id)target action:(SEL)selector userData:(id)userData
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/radio_recommendations/"];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    conf.userData = userData;
    
    if (genre != nil)
    {
        NSArray* params = [NSArray arrayWithObject:[NSString stringWithFormat:@"genre=%@", genre]];
        conf.params = params;
    }
    
    ASIFormDataRequest* req = [_communicator buildFormDataRequestWithConfig:conf];
    [req addData:data forKey:@"artists_data"];
    [req startAsynchronous];
}


#pragma mark - users in the app

- (void)connectedUsersWithLimitNumber:(NSNumber*)limit skipNumber:(NSNumber*)skip completionBlock:(YaRequestCompletionBlock)block
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (limit)
        [params setValue:[limit stringValue] forKey:@"limit"];
    if (skip)
        [params setValue:[skip stringValue] forKey:@"skip"];
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/connected_users/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.params = params;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)connectedUsersWithCompletionBlock:(YaRequestCompletionBlock)block
{
    [self connectedUsersWithLimitNumber:nil skipNumber:nil completionBlock:block];
}

- (void)connectedUsersWithLimit:(int)limit skip:(int)skip completionBlock:(YaRequestCompletionBlock)block
{
    [self connectedUsersWithLimitNumber:[NSNumber numberWithInt:limit] skipNumber:[NSNumber numberWithInt:skip] completionBlock:block];
}

#pragma mark - Radio stats

- (void)monthListeningStatsForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"/api/v1/listening_stats/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.params = [NSDictionary dictionaryWithObject:[radio.id stringValue] forKey:@"radio"];
    config.auth = self.apiKeyAuth;

    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)leaderboardForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v2/radio/%@/leaderboard", radio.uuid];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


#pragma mark - playlists

- (void)playlistsForRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/all_playlist/", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)songsForPlaylist:(NSInteger)playlistId target:(id)target action:(SEL)selector
{
  NSString* url = [NSString stringWithFormat:@"api/v1/song/"];
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [[NSMutableArray alloc] init];
  [params addObject:[NSString stringWithFormat:@"playlist=%@", playlistId]];
  
  [_communicator getObjectsWithClass:[Song class] withURL:url absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
    
    [params release];
    
}


- (ASIFormDataRequest*)uploadSong:(NSData*)song forRadioId:(Radio*)radio_id title:(NSString*)title album:(NSString*)album artist:(NSString*)artist songId:(NSNumber*)songId target:(id)target action:(SEL)selector progressDelegate:(id)progressDelegate
{
    if ((song == nil) || (radio_id == nil))
    {
        assert(0);
        return nil;
    }
    
    //LBDEBUG
    if (![radio_id isKindOfClass:[NSNumber class]])
    {
        assert(0);
        return nil;
    }
    
  Auth* auth = self.apiKeyAuth;
  NSString* url = [NSString stringWithFormat:@"api/v1/upload_song/%@/", songId];
    
  
  NSMutableDictionary* jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:radio_id forKey:@"radio_id"];
    [jsonObject setObject:title forKey:@"title"];
  [jsonObject setObject:album forKey:@"album"];
  [jsonObject setObject:artist forKey:@"artist"];   
  NSString* jsonString = jsonObject.JSONRepresentation;
    
  return [_communicator postData:song withKey:@"song" toURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth withProgress:progressDelegate withAdditionalJsonData:jsonString];
}

- (void)matchedSongsForPlaylist:(Playlist*)playlist target:(id)target action:(SEL)selector
{
  if (!playlist)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSString* url = [NSString stringWithFormat:@"api/v1/playlist/%@/matched_song", playlist.id];
  [_communicator getObjectsWithClass:[Song class] withURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)updateSong:(Song*)song withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!song || !song.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/edit_song/%@", song.id];
    config.urlIsAbsolute = NO;
    config.method = @"PUT";
    config.auth = self.apiKeyAuth;
    config.payload = [[song JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)deleteSong:(Song*)song withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!song || !song.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/delete_song/%@", song.id];
    config.urlIsAbsolute = NO;
    config.method = @"DELETE";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


- (void)deleteAllSongsFromRadio:(Radio*)radio target:(id)target action:(SEL)action
{
    if (!radio)
        return;
    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/radio/%@/programming/", radio.id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"DELETE";
    
    conf.callbackTarget = target;
    conf.callbackAction = action;
    conf.userData = nil;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}


- (void)deleteArtist:(NSString*)artist fromRadio:(Radio*)radio target:(id)target action:(SEL)action
{
    if (!artist || !radio)
        return;
    
    Auth* auth = self.apiKeyAuth;
    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/radio/%@/programming/artists/", radio.id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    
    conf.callbackTarget = target;
    conf.callbackAction = action;
    conf.userData = nil;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];

    ProgrammingObjectParameters* params = [[ProgrammingObjectParameters alloc] init];
    params.action = @"delete";
    params.name = artist;
    
    NSString* stringData = [params JSONRepresentation];
    [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req startAsynchronous];
}


- (void)deleteAlbum:(NSString*)album fromRadio:(Radio*)radio target:(id)target action:(SEL)action
{
    if (!album || !radio)
        return;
    
    Auth* auth = self.apiKeyAuth;
    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/radio/%@/programming/albums/", radio.id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    
    conf.callbackTarget = target;
    conf.callbackAction = action;
    conf.userData = nil;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    
    ProgrammingObjectParameters* params = [[ProgrammingObjectParameters alloc] init];
    params.action = @"delete";
    params.name = album;
    
    NSString* stringData = [params JSONRepresentation];
    [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req startAsynchronous];
}







- (void)rejectSong:(Song*)song target:(id)target action:(SEL)selector
{
    if (!song || !song.id)
        return;
    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/reject_song/%@", song.id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    //DLog(@"rejectSong '%@'", conf.url);
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)searchSong:(NSString*)search count:(NSInteger)count offset:(NSInteger)offset target:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSString* url = @"api/v1/search_song";
  NSMutableArray* params = [[NSMutableArray alloc] init];
  [params addObject:[NSString stringWithFormat:@"search=%@", search]];
  [params addObject:[NSString stringWithFormat:@"song_count=%d", count]];
  [params addObject:[NSString stringWithFormat:@"song_offset=%d", offset]];
  [_communicator getObjectsWithClass:[YasoundSong class] withURL:url absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
    
    [params release];
    
}

- (void)addSong:(YasoundSong*)yasoundSong inRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
    if (!yasoundSong)
        return;
    Auth* auth = self.apiKeyAuth;
    int playlistIndex = 0;
    NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/playlist/%d/add_song/%@", radio.id, playlistIndex, yasoundSong.id];
    
    NSMutableDictionary* userData = [NSMutableDictionary dictionary];
    [userData setValue:target forKey:@"finalTarget"];
    [userData setValue:NSStringFromSelector(selector) forKey:@"finalSelector"];
    
    [_communicator postToURL:url absolute:NO notifyTarget:self byCalling:@selector(didAddSong:info:) withUserData:userData withAuth:auth];
}

- (void)addSong:(YasoundSong*)yasoundSong target:(id)target action:(SEL)selector
{
    [self addSong:yasoundSong inRadio:_radio target:target action:selector];
}

- (void)didAddSong:(NSString*)res info:(NSDictionary*)info
{
  NSDictionary* dict = [res JSONValue];
  NSNumber* songInstanceID = [dict valueForKey:@"song_instance_id"];
  
  NSMutableDictionary* status = [NSMutableDictionary dictionary];
  [status setValue:[dict valueForKey:@"success"] forKey:@"success"];
  [status setValue:[dict valueForKey:@"created"] forKey:@"created"];
  
  if (!songInstanceID)
  {
    NSDictionary* userData = [info valueForKey:@"userData"];
    id target = [userData valueForKey:@"finalTarget"];
    SEL selector = NSSelectorFromString([userData valueForKey:@"finalSelector"]);
    
    if (target && selector)
    {
      NSMutableDictionary* finalInfo = [NSMutableDictionary dictionary];
      [finalInfo setValue:[info valueForKey:@"error"] forKey:@"error"];
      [finalInfo setValue:status forKey:@"status"];
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:nil withObject:finalInfo];
    }
    return;
  }
  
  NSMutableDictionary* userData = [NSMutableDictionary dictionaryWithDictionary:[info valueForKey:@"userData"]];
  [userData setValue:status forKey:@"status"];
  
  Auth* auth = self.apiKeyAuth;
  [_communicator getObjectWithClass:[Song class] andID:songInstanceID notifyTarget:self byCalling:@selector(didReceiveAddedSong:info:) withUserData:userData withAuth:auth];
}

- (void)didReceiveAddedSong:(Song*)addedSong info:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"finalTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"finalSelector"]);
  NSDictionary* status = [userData valueForKey:@"status"];
  
  if (target && selector)
  {
    NSMutableDictionary* finalInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    [finalInfo setValue:status forKey:@"status"];
      if ([target respondsToSelector:selector])
          [target performSelector:selector withObject:addedSong withObject:finalInfo];
  }
}

#pragma mark - notifications preferences

- (void)apnsPreferencesWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"/api/v1/notifications_preferences";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)setApnsPreferences:(APNsPreferences*)prefs withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"/api/v1/set_notifications_preferences";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = [[prefs JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


#pragma mark - facebook share preferences

- (void)facebookSharePreferencesWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/facebook_share_preferences";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)setFacebookSharePreferences:(FacebookSharePreferences*)prefs withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/set_facebook_share_preferences";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = [[prefs JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

#pragma mark - User Notifications   

- (void)broadcastMessage:(NSString*)message fromRadio:(Radio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/broadcast_message/", radio.uuid];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObject:message forKey:@"message"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}



- (void)userNotificationsWithTarget:(id)target action:(SEL)selector limit:(NSInteger)limit offset:(NSInteger)offset
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"api/v1/notifications/";
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    conf.params = [NSArray arrayWithObjects:[NSString stringWithFormat:@"limit=%d", limit], [NSString stringWithFormat:@"offset=%d", offset], nil];
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];

    [req startAsynchronous];
}





- (void)userNotificationWithId:(NSString*)notifId target:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/notification/%@", notifId];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)updateUserNotification:(UserNotification*)notif target:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/update_notification/%@", notif._id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"PUT";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    
    NSString* stringData = [notif JSONRepresentation];
    [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req startAsynchronous];
}

- (void)deleteUserNotification:(UserNotification*)notif target:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/delete_notification/%@", notif._id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"DELETE";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)deleteAllUserNotificationsWithTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"api/v1/delete_all_notifications/";
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"DELETE";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)unreadNotificationCountWithTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"api/v1/notifications/unread_count";
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}


#pragma mark - shows

- (void)showsForRadio:(Radio*)r withTarget:(id)target action:(SEL)selector
{
    [self showsForRadio:r limit:0 offset:0 withTarget:target action:selector];
}

- (void)showsForRadio:(Radio*)r limit:(NSInteger)limit offset:(NSInteger)offset withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/radio/%@/shows/", r.uuid];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    if (limit != 0 && offset != 0)
    {
        NSMutableArray* params = [NSMutableArray array];
        if (limit != 0)
            [params addObject:[NSString stringWithFormat:@"limit=%d", limit]];
        if (offset != 0)
            [params addObject:[NSString stringWithFormat:@"offset=%d", offset]];
        conf.params = params;
    }
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)showWithId:(NSString*)showId withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/show/%@/", showId];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)updateShow:(Show*)show withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/show/%@", show._id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"PUT";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    
    NSString* stringData = [show JSONRepresentation];
    [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req startAsynchronous];
}

- (void)deleteShow:(Show*)show withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/show/%@", show._id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"DELETE";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)createShow:(Show*)show inRadio:(Radio*)radio withTarget:(id)target action:(SEL)selector
{
    [self createShow:show inRadio:radio withYasoundSongs:nil withTarget:target action:selector];
}

- (void)createShow:(Show*)show inRadio:(Radio*)radio withYasoundSongs:(NSArray*)yasoundSongs withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/radio/%@/create_show", radio.uuid];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    
    // be sure show._id is null
    show._id = nil;

    NSMutableDictionary* data = [show proxyForJson];
    if (yasoundSongs)
    {
        NSMutableArray* yasoundSongIds = [NSMutableArray array];
        for (YasoundSong* y in yasoundSongs)
        {
            [yasoundSongIds addObject:y.id];
        }
        [data setValue:yasoundSongIds forKey:@"song_ids"];
    }
    
    NSString* stringData = [data JSONRepresentation];
    [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req startAsynchronous];
}

- (void)duplicateShow:(Show*)show withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/show/%@/duplicate", show._id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}


- (void)songsForShow:(Show*)show withTarget:(id)target action:(SEL)selector
{
    [self songsForShow:show limit:0 offset:0 withTarget:target action:selector];
}

- (void)songsForShow:(Show*)show limit:(NSInteger)limit offset:(NSInteger)offset withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/show/%@/songs/", show._id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    if (limit != 0 && offset != 0)
    {
        NSMutableArray* params = [NSMutableArray array];
        if (limit != 0)
            [params addObject:[NSString stringWithFormat:@"limit=%d", limit]];
        if (offset != 0)
            [params addObject:[NSString stringWithFormat:@"offset=%d", offset]];
        conf.params = params;
    }
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)addSong:(YasoundSong*)song inShow:(Show*)show withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/show/%@/add_song/%@/", show._id, song.id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)removeSong:(Song*)song fromShow:(Show*)show withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/show/%@/remove_song/%@/", show._id, song.id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}





#pragma mark - in-app purchase

- (void)servicesWithTarget:(id)target action:(SEL)action
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"api/v1/premium/services/";
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = action;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    
    //LBDEBUG
    //DLog(@"servicesWithTarget url '%@'", req.url);
    
    [req startAsynchronous];
}


- (void)subscriptionsWithTarget:(id)target action:(SEL)action
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"api/v1/premium/subscriptions/";
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = action;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}


- (void)subscriptionComplete:(NSString*)productId withBase64Receipt:(NSString*)appleReceipt target:(id)target action:(SEL)action
{
    
    NSString* url = [NSString stringWithFormat:@"api/v1/premium/subscriptions/%@", productId];

    ASIFormDataRequest* req = [_communicator buildPostRequestToURL:url absolute:NO notifyTarget:target byCalling:action withUserData:nil withAuth:self.apiKeyAuth];
    
    [req addPostValue:appleReceipt forKey:@"receipt"];
    [req addPostValue:self.user.username forKey:@"username"];
    
    [req startAsynchronous];
}



#pragma mark - gifts

- (void)giftsWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/premium/gifts/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

#pragma mark - promo code

- (void)activatePromoCode:(NSString*)code withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/premium/activate_promocode/";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObject:code forKey:@"code"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

#pragma mark - streaming authentication token

- (void)streamingAuthenticationTokenWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/streamer_auth_token/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}



#pragma mark - city suggestions

- (void)citySuggestionsWithCityName:(NSString*)city andCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"http://nominatim.openstreetmap.org/search";
    config.urlIsAbsolute = YES;
    config.method = @"GET";
    config.params = [NSDictionary dictionaryWithObjectsAndKeys:@"json", @"format", city, @"q", nil];
    config.external = YES;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

#pragma mark - friends invitation

- (void)inviteContacts:(NSArray*)contacts withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/invite_ios_contacts";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = [[contacts JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)inviteFacebookFriends:(NSArray*)friends withCompletionBlock:(YaRequestCompletionBlock)block
{
    NSMutableArray* facebook_ids = [NSMutableArray array];
    for (FacebookFriend* f in friends)
    {
        [facebook_ids addObject:f.id];
    }
    NSString* dataStr = [facebook_ids JSONRepresentation];
    NSData* data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/invite_facebook_friends";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = data;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)inviteTwitterFriendsWithTarget:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/invite_twitter_friends";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}





//................................................................................................................................
//
// DEPRECATED
//


- (void)sendGetRequestWithURL:(NSString*)url
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = url;
    conf.urlIsAbsolute = NO;
    conf.method = @"GET";
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)sendPostRequestWithURL:(NSString*)url
{
  Auth* auth = self.apiKeyAuth;

  //NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];

  ASIFormDataRequest* req = [_communicator buildPostRequestToURL:url absolute:NO notifyTarget:self byCalling:@selector(receiveYasoundAssociation:info:) withUserData:nil withAuth:auth];

  [req startAsynchronous];
}


//
// DEPRECATED
//
//................................................................................................................................









@end



taskStatus stringToStatus(NSString* str)
{
  DLog(@"Task status: %@", str);
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


