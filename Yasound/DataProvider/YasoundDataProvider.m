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
  
  NSURL* url = [_communicator urlWithURL:picturePath absolute:NO addTrailingSlash:NO params:nil];
    
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

- (void)reloadUserWithUserData:(id)data withTarget:(id)target action:(SEL)selector
{
    if (!self.user)
        return;
    NSMutableDictionary* userData = [NSMutableDictionary dictionary];
    [userData setValue:target forKey:@"clientTarget"];
    [userData setValue:NSStringFromSelector(selector) forKey:@"clientSelector"];
    [userData setValue:data forKey:@"clientData"];
    NSNumber* userId = self.user.id;
    Auth* auth = self.apiKeyAuth;
    [_communicator getObjectWithClass:[User class] andID:userId notifyTarget:self byCalling:@selector(didReloadUser:withInfo:) withUserData:userData withAuth:auth];
}

- (void)didReloadUser:(User*)user withInfo:(NSDictionary*)info
{
    NSDictionary* userData = [info valueForKey:@"userData"];
    id target = [userData valueForKey:@"clientTarget"];
    SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
    id clientData = [userData valueForKey:@"clientData"];
    
    _user = user;
    
    if (target && selector)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:clientData forKey:@"userData"];
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:_user withObject:dict];
    }
}


//
// APNs device token
//
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
  
  Auth* auth = self.apiKeyAuth;
  NSString* relativeURL = @"/api/v1/ios_push_notif_token";
  [_communicator postNewObject:token withURL:relativeURL absolute:NO notifyTarget:nil byCalling:nil withUserData:nil withAuth:auth returnNewObject:NO withAuthForGET:nil];
  return YES;
}

- (void)sendAPNsDeviceTokenWhenLogged
{
  YasoundAppDelegate* appDelegate =  [UIApplication sharedApplication].delegate;
  [appDelegate sendAPNsTokenString];
}



- (void)userRadioWithTarget:(id)target action:(SEL)selector andData:(NSDictionary*)userData
{
  if (!_user)
  {
    NSDictionary* info = [NSDictionary dictionaryWithObject:[NSError errorWithDomain:@"no logged user" code:1 userInfo:nil] forKey:@"error"];
    if (target && selector)
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:nil withObject:info];
    return;
  }
  
  NSArray* params = [NSArray arrayWithObject:[NSString stringWithFormat:@"creator=%@", _user.id]];
  Auth* auth = self.apiKeyAuth;
  
  NSMutableDictionary* data;
  if (userData)
    data = [NSMutableDictionary dictionaryWithDictionary:userData];
  else
    data = [NSMutableDictionary dictionary];
  [data setValue:target forKey:@"clientTarget"];
  [data setValue:NSStringFromSelector(selector) forKey:@"clientSelector"];
  
  [_communicator getObjectsWithClass:[Radio class] withParams:params notifyTarget:self byCalling:@selector(didReceiveUserRadios:withInfo:) withUserData:data withAuth:auth];
}

- (void)userRadioWithTarget:(id)target action:(SEL)selector
{
  [self userRadioWithTarget:target action:selector andData:nil];
}

- (void)didReceiveUserRadios:(NSArray*)radios withInfo:(NSDictionary*)info
{
  NSMutableDictionary* finalInfo = [NSMutableDictionary dictionaryWithDictionary:info];
  
  Radio* r = nil;
  if (!radios || [radios count] == 0)
  {
      NSString* str = [NSString stringWithFormat:@"no radio for user '%@'", _user.username];
      DLog(@"%@", str);
      
    NSError* err = [NSError errorWithDomain:str code:1 userInfo:nil];
    [finalInfo setValue:err forKey:@"error"];
  }
  else
  {
    r = [radios objectAtIndex:0];
  }
  
  if (r)
  {
    _radio = r;
  }
  
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  
  if (target && selector)
  {
      if ([target respondsToSelector:selector])
          [target performSelector:selector withObject:_radio withObject:finalInfo];
  }
}



- (void)reloadUserRadio
{
  [self userRadioWithTarget:self action:@selector(reloadedUserRadio:withInfo:)];
}

- (void)reloadedUserRadio:(Radio*)r withInfo:(NSDictionary*)info
{
  if (!r)
    return;
  
  _radio = r;
}

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


    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithDictionary:finalInfo];
    [data setValue:target forKey:@"finalTarget"];
    [data setValue:NSStringFromSelector(selector) forKey:@"finalSelector"];
    if (clientData)
    [data setValue:clientData forKey:@"clientData"];

    [self userRadioWithTarget:self action:@selector(didReceiveLoggedUserRadio:withInfo:) andData:data];

    // send Apple Push Notification service device token
    [self sendAPNsDeviceTokenWhenLogged];
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
  NSDictionary* clientData = [userData valueForKey:@"clientData"];
  
  NSMutableDictionary* data = [NSMutableDictionary dictionary];
  [data setValue:target forKey:@"finalTarget"];
  [data setValue:NSStringFromSelector(selector) forKey:@"finalSelector"];
  if (clientData)
    [data setValue:clientData forKey:@"clientData"];
  
  [self userRadioWithTarget:self action:@selector(didReceiveLoggedUserRadio:withInfo:) andData:data];
  
  // send Apple Push Notification service device token
  [self sendAPNsDeviceTokenWhenLogged];
}

- (void)didReceiveLoggedUserRadio:(Radio*)r withInfo:(NSDictionary*)info
{
  NSMutableDictionary* finalInfo = [NSMutableDictionary dictionary];
  
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"finalTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"finalSelector"]);
  NSDictionary* clientData = [userData valueForKey:@"clientData"];
  
  if (clientData)
    [finalInfo setValue:clientData forKey:@"userData"];
  
  if (target && selector)
  {
      if ([target respondsToSelector:selector])
          [target performSelector:selector withObject:_user withObject:finalInfo];
  }  
}






#pragma mark - Yasound Account Association



- (void)associateAccountYasound:(NSString*)email password:(NSString*)pword target:(id)target action:(SEL)selector
{
    Auth* auth = self.apiKeyAuth;

    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
    
    ASIFormDataRequest* req = [_communicator buildPostRequestToURL:@"api/v1/account/association" absolute:NO notifyTarget:self byCalling:@selector(receiveYasoundAssociation:info:) withUserData:data withAuth:auth];

    [req addPostValue:@"yasound" forKey:@"account_type"];
    [req addPostValue:email forKey:@"email"];
    [req addPostValue:pword forKey:@"password"];
    
    [req startAsynchronous];
}


- (void)receiveYasoundAssociation:(NSString*)response info:(NSDictionary*)info
{
    DLog(@"YasoundDataProvider receiveYasoundAssociation : info %@", info);
    
    NSMutableDictionary* finalInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    if (response != nil)
        [finalInfo setObject:response forKey:@"response"];
    
    NSDictionary* userData = [info valueForKey:@"userData"];
    id target = [userData valueForKey:@"clientTarget"];
    SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
    NSDictionary* clientData = [userData valueForKey:@"clientData"];
    if (clientData)
        [finalInfo setValue:clientData forKey:@"userData"];
    
    if (target && selector)
    {
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:finalInfo];
    }
}

- (void)receiveFacebookAssociation:(NSString*)response info:(NSDictionary*)info
{
    DLog(@"YasoundDataProvider receiveFacebookAssociation : info %@  %@", info, response);
    
    NSMutableDictionary* finalInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    if (response != nil)
        [finalInfo setObject:response forKey:@"response"];
    
    NSDictionary* userData = [info valueForKey:@"userData"];
    id target = [userData valueForKey:@"clientTarget"];
    SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
    NSDictionary* clientData = [userData valueForKey:@"clientData"];
    if (clientData)
        [finalInfo setValue:clientData forKey:@"userData"];
    
    if (target && selector)
    {
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:finalInfo];
    }
}

- (void)receiveTwitterAssociation:(NSString*)response info:(NSDictionary*)info
{
    DLog(@"YasoundDataProvider receiveTwitterAssociation : info %@", info);
    
    NSMutableDictionary* finalInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    if (response != nil)
        [finalInfo setObject:response forKey:@"response"];
    
    NSDictionary* userData = [info valueForKey:@"userData"];
    id target = [userData valueForKey:@"clientTarget"];
    SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
    NSDictionary* clientData = [userData valueForKey:@"clientData"];
    if (clientData)
        [finalInfo setValue:clientData forKey:@"userData"];
    
    if (target && selector)
    {
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:finalInfo];
    }
}

- (void)receiveDissociation:(id)obj info:(NSDictionary*)info
{
    DLog(@"YasoundDataProvider receiveDissociation : info %@", info);
    
    NSMutableDictionary* finalInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    NSDictionary* userData = [info valueForKey:@"userData"];
    id target = [userData valueForKey:@"clientTarget"];
    SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
    NSDictionary* clientData = [userData valueForKey:@"clientData"];
    if (clientData)
        [finalInfo setValue:clientData forKey:@"userData"];
    
    if (target && selector)
    {
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:finalInfo];
    }
}



#pragma mark - Facebook Account Association


- (void)associateAccountFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token  expirationDate:(NSString*)expirationDate email:(NSString*)email target:(id)target action:(SEL)selector
{
    Auth* auth = self.apiKeyAuth;
    
    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
    
    ASIFormDataRequest* req = [_communicator buildPostRequestToURL:@"api/v1/account/association" absolute:NO notifyTarget:self byCalling:@selector(receiveFacebookAssociation:info:) withUserData:data withAuth:auth];
    
    [req addPostValue:username forKey:@"username"];
    [req addPostValue:@"facebook" forKey:@"account_type"];
    [req addPostValue:uid forKey:@"uid"];
    [req addPostValue:token forKey:@"token"];
    [req addPostValue:expirationDate forKey:@"expiration_date"];
    [req addPostValue:email forKey:@"email"];
    
    [req startAsynchronous];
}






#pragma mark - Twitter Account Association



- (void)associateAccountTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email target:(id)target action:(SEL)selector
{
    Auth* auth = self.apiKeyAuth;
    
    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
    
    ASIFormDataRequest* req = [_communicator buildPostRequestToURL:@"api/v1/account/association" absolute:NO notifyTarget:self byCalling:@selector(receiveTwitterAssociation:info:) withUserData:data withAuth:auth];
    
    [req addPostValue:username forKey:@"username"];
    [req addPostValue:@"twitter" forKey:@"account_type"];
    [req addPostValue:uid forKey:@"uid"];
    [req addPostValue:token forKey:@"token"];
    [req addPostValue:tokenSecret forKey:@"token_secret"];
    [req addPostValue:email forKey:@"email"];
    
    [req startAsynchronous];
}


#pragma mark - Accounts Dissociation

- (void)dissociateAccount:(NSString*)accountTypeIdentifier  target:(id)target action:(SEL)selector
{
    Auth* auth = self.apiKeyAuth;
    
    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
    
    ASIFormDataRequest* req = [_communicator buildPostRequestToURL:@"api/v1/account/dissociation" absolute:NO notifyTarget:self byCalling:@selector(receiveDissociation:info:) withUserData:data withAuth:auth];
    
    [req addPostValue:accountTypeIdentifier forKey:@"account_type"];
    
    [req startAsynchronous];

}














#pragma mark - requests about radios

- (void)radioForUser:(User*)u withTarget:(id)target action:(SEL)selector
{
  if (!u)
  {
    NSDictionary* info = [NSDictionary dictionaryWithObject:[NSError errorWithDomain:@"no user" code:1 userInfo:nil] forKey:@"error"];
    if (target && selector)
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:nil withObject:info];
    return;
  }
  
  NSArray* params = [NSArray arrayWithObject:[NSString stringWithFormat:@"creator=%@", u.id]];
  Auth* auth = self.apiKeyAuth;
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
  [_communicator getObjectsWithClass:[Radio class] withParams:params notifyTarget:self byCalling:@selector(didReceiveRadios:withInfo:) withUserData:data withAuth:auth];
}

- (void)didReceiveRadios:(NSArray*)radios withInfo:(NSDictionary*)info
{
  NSMutableDictionary* finalInfo = [[NSMutableDictionary alloc] init];
  
  Radio* r = nil;
  if (!radios || [radios count] == 0)
  {
    NSError* err = [NSError errorWithDomain:[NSString stringWithFormat:@"no radio for user '%@'", _user.username] code:1 userInfo:nil];
    [finalInfo setValue:err forKey:@"error"];
  }
  else
  {
    r = [radios objectAtIndex:0];
  }
  
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  
  if (target && selector)
  {
      if ([target respondsToSelector:selector])
        [target performSelector:selector withObject:r withObject:finalInfo];
  }
}




- (void)radioWithId:(NSNumber*)radioId target:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  [_communicator getObjectWithClass:[Radio class] andID:radioId notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}


//
// friends
//

- (void)friendsWithTarget:(id)target action:(SEL)selector
{
    [self friendsWithTarget:target action:selector userData:nil];
}


- (void)friendsWithTarget:(id)target action:(SEL)selector userData:(id)userData
{
    Auth* auth = self.apiKeyAuth;
    [_communicator getObjectsWithClass:[User class] withURL:@"/api/v1/friend" absolute:NO notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
}

- (void)friendsForUser:(User*)user withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/user/%@/friends", user.username];
    conf.urlIsAbsolute = NO;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

//
// radios lists
//

- (void)friendsRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
  [self friendsRadiosWithGenre:genre withTarget:target action:selector userData:nil];
}


- (void)friendsRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray array];
  if (genre)
    [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
  
  [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/friend_radio" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
}



- (void)radiosWithUrl:(NSString*)url withGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData
{
    DLog(@"YasoundDataProvider::radiosWithUrl '%@'", url);
    //assert(url != nil);
    
    Auth* auth = self.apiKeyAuth;
    NSMutableArray* params = [NSMutableArray array];
    if (genre)
        [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
    
    [_communicator getObjectsWithClass:[Radio class] withURL:url absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
}

- (void)favoriteRadiosForUser:(User*)u withTarget:(id)target action:(SEL)selector
{
    Auth* auth = self.apiKeyAuth;
    NSMutableArray* params = [NSMutableArray array];
    
    NSString *url = [NSString stringWithFormat:@"/api/v1/user/%@/favorite_radio", u.id];
    
    [_communicator getObjectsWithClass:[Radio class] withURL:url absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)radiosForUser:(User*)u withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/user/%@/radios", u.username];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    conf.userData = nil;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}



- (void)createRadioWithTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"/api/v1/my_radios/";
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    conf.userData = nil;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)deleteRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"/api/v1/my_radios/%@/", radio.uuid];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"DELETE";
    
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    conf.userData = nil;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}




//


//
// search radios
//

- (void)searchRadios:(NSString*)search withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray array];
  [params addObject:[NSString stringWithFormat:@"search=%@", search]];

  [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/search_radio" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)searchRadiosByCreator:(NSString*)search withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray array];
  [params addObject:[NSString stringWithFormat:@"search=%@", search]];
  
  [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/search_radio_by_user" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)searchRadiosBySong:(NSString*)search withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray array];
  [params addObject:[NSString stringWithFormat:@"search=%@", search]];
  
  [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/search_radio_by_song" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}


- (void)updateRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  [_communicator updateObject:radio notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
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


- (void)setPicture:(UIImage*)img forRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  DLog(@"img %f, %f", img.size.width, img.size.height);
  UIImage* resizedImg = [self resizeImage:img];
  DLog(@"resized img %f, %f", resizedImg.size.width, resizedImg.size.height);
  Auth* auth = self.apiKeyAuth;
  NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/picture", radio.id];
  [_communicator postData:UIImagePNGRepresentation(resizedImg) withKey:@"picture" toURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}



- (void)updateUser:(User*)user target:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/user/%@/", user.id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"PUT";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    
    NSString* stringData = [user JSONRepresentation];
    [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    [req addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [req startAsynchronous];
}

- (void)setPicture:(UIImage*)img forUser:(User*)user target:(id)target action:(SEL)selector
{
  UIImage* resizedImg = [self resizeImage:img];
  Auth* auth = self.apiKeyAuth;
  NSString* url = [NSString stringWithFormat:@"api/v1/user/%@/picture", user.id];
  [_communicator postData:UIImagePNGRepresentation(resizedImg) withKey:@"picture" toURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

// get wall events
- (ASIHTTPRequest*)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize target:(id)target action:(SEL)selector
{
  if (radio == nil)
      return nil;
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/wall", radioID];
    
    NSMutableArray* params = [[NSMutableArray alloc] init];
    
  [params addObject:[NSString stringWithFormat:@"limit=%d", pageSize]];
  ASIHTTPRequest* req = [_communicator getObjectsWithClass:[WallEvent class] withURL:relativeUrl absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
    
    [params release];
    
    return req;
}

- (ASIHTTPRequest*)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize olderThanEventWithID:(NSNumber*)lastEventID target:(id)target action:(SEL)selector
{
  if (!radio || !radio.id)
      return nil;
  if (!lastEventID)
      return nil;
  
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/wall", radioID];
  NSMutableArray* params = [[NSMutableArray alloc] init];
  [params addObject:[NSString stringWithFormat:@"id__lt=%@", lastEventID]];
  [params addObject:[NSString stringWithFormat:@"limit=%d", pageSize]];
  ASIHTTPRequest* req = [_communicator getObjectsWithClass:[WallEvent class] withURL:relativeUrl absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
    
    [params release];
    
    return req;
}

- (ASIHTTPRequest*)wallEventsForRadio:(Radio*)radio newerThanEventWithID:(NSNumber*)eventID target:(id)target action:(SEL)selector
{
    if (!radio || !radio.id)
        return nil;
    if (!eventID)
        return nil;
    
    Auth* auth = self.apiKeyAuth;
    NSNumber* radioID = radio.id;
    NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/wall", radioID];
    NSMutableArray* params = [[NSMutableArray alloc] init];
    [params addObject:[NSString stringWithFormat:@"id__gt=%@", eventID]];
    ASIHTTPRequest* req = [_communicator getObjectsWithClass:[WallEvent class] withURL:relativeUrl absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
    
    [params release];
    
    return req;

}

- (void)postWallMessage:(NSString*)message toRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (!message || !_user || !radio)
    return;
  
  Auth* auth = self.apiKeyAuth;
  
  WallMessagePost* msg = [[WallMessagePost alloc] init];
  msg.user = _user;
  msg.radio = radio;
  msg.type = @"M";
  msg.text = message;
  NSString* relativeURL = @"/api/v1/wall_event";
  [_communicator postNewObject:msg withURL:relativeURL absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth returnNewObject:NO withAuthForGET:nil];
}


- (void)moderationDeleteWallMessage:(NSNumber*)messageId
{
    if (!messageId)
        return;
    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/delete_message/%@", messageId];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"DELETE";
//    conf.callbackTarget = self;
//    conf.callbackAction = @selector(didDeleteSong:);
//    conf.userData = dict;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}


- (void)moderationReportAbuse:(NSNumber*)messageId;
{
    if (!messageId)
        return;

    Auth* auth = self.apiKeyAuth;
    NSString* url = [NSString stringWithFormat:@"api/v1/report_message/%@", messageId];
    
    [_communicator postToURL:url absolute:NO withStringData:nil objectClass:nil notifyTarget:nil byCalling:nil withUserData:nil withAuth:auth returnNewObject:NO withAuthForGET:nil];
}




- (void)enterRadioWall:(Radio*)radio
{
  if (!_user || !radio || !radio.id)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/connect", radio.id];
  [_communicator postToURL:relativeUrl absolute:NO notifyTarget:nil byCalling:nil withUserData:nil withAuth:auth];  
}

- (void)leaveRadioWall:(Radio*)radio
{
  if (!_user || !radio || !radio.id)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/disconnect", radio.id];
  [_communicator postToURL:relativeUrl absolute:NO notifyTarget:nil byCalling:nil withUserData:nil withAuth:auth];  
}


- (void)favoriteUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (!radio || !radio.id)
    return;
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/favorite_user", radioID];
  NSArray* params = [NSArray arrayWithObject:@"limit=0"];
  [_communicator getObjectsWithClass:[User class] withURL:relativeUrl absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}


- (void)likersForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (!radio || !radio.id)
    return;
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/like_user", radioID];
  NSArray* params = [NSArray arrayWithObject:@"limit=0"];
  [_communicator getObjectsWithClass:[User class] withURL:relativeUrl absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)currentUsersForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil || !radio.id)
    return;
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/current_user", radioID];
  NSArray* params = [NSArray arrayWithObject:@"limit=0"];
  [_communicator getObjectsWithClass:[User class] withURL:relativeUrl absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];

}

- (void)currentSongForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  [self currentSongForRadio:radio target:target action:selector userData:nil];
}

- (void)currentSongForRadio:(Radio*)radio target:(id)target action:(SEL)selector userData:(id)userData
{
  if (radio == nil || !radio.id)
    return;
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/current_song", radioID];
  [_communicator getObjectWithClass:[Song class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
}

- (void)statusForSongId:(NSNumber*)songId target:(id)target action:(SEL)selector
{
  if (!songId)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/song/%@/status", songId];
  [_communicator getObjectWithClass:[SongStatus class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)songWithId:(NSNumber*)songId target:(id)target action:(SEL)selector
{
  if (!songId)
    return;
  
  Auth* auth = self.apiKeyAuth;
  [_communicator getObjectWithClass:[Song class] andID:songId notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)nextSongsForUserRadioWithTarget:(id)target action:(SEL)selector
{
  if (!self.radio || !self.radio.id)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = self.radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/next_songs", radioID];
  [_communicator getObjectsWithClass:[NextSong class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)userWithId:(NSNumber*)userId target:(id)target action:(SEL)selector
{
    if (!userId)
        return;
    
    Auth* auth = self.apiKeyAuth;
    [_communicator getObjectWithClass:[User class] andID:userId notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)userWithUsername:(NSString*)username target:(id)target action:(SEL)selector
{
    if (!username)
        return;
    
    Auth* auth = self.apiKeyAuth;
    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/public_user/%@", username];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    conf.userData = nil;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}



- (void)moveNextSong:(NextSong*)nextSong toPosition:(int)position target:(id)target action:(SEL)selector
{
  if (!nextSong || !nextSong.id)
    return;
  
  NSNumber* oldOrder = nextSong.order;
  Auth* auth = self.apiKeyAuth;
  int order = position + 1;
  nextSong.order = [NSNumber numberWithInt:order];
  NSMutableDictionary* userData = [[NSMutableDictionary alloc] init];
  [userData setValue:target forKey:@"clientTarget"];
  [userData setValue:NSStringFromSelector(selector) forKey:@"clientSelector"];
  
  [_communicator updateObject:nextSong notifyTarget:self byCalling:@selector(didUpdateNextSong:withInfo:) withUserData:userData withAuth:auth];
}

- (void)didUpdateNextSong:(NextSong*)nextSong withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  
  NSError* error = [info valueForKey:@"error"];
  if (error)
  {
    if (target && selector)
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:nil withObject:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil]];
    return;
  }
  
  [self nextSongsForUserRadioWithTarget:target action:selector];
}

- (void)deleteNextSong:(NextSong*)nextSong target:(id)target action:(SEL)selector
{
  if (!nextSong || !nextSong.id)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSMutableDictionary* userData = [[NSMutableDictionary alloc] init];
  [userData setValue:target forKey:@"clientTarget"];
  [userData setValue:NSStringFromSelector(selector) forKey:@"clientSelector"];
  [_communicator deleteObject:nextSong notifyTarget:self byCalling:@selector(didDeleteNextSong:withInfo:) withUserData:userData withAuth:auth];
}

- (void)didDeleteNextSong:(NextSong*)nextSong withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  
  NSError* error = [info valueForKey:@"error"];
  if (error)
  {
    if (target && selector)
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:nil withObject:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil]];
    return;
  }
  
  [self nextSongsForUserRadioWithTarget:target action:selector];
}


- (void)addSongToNextSongs:(Song*)song atPosition:(int)position target:(id)target action:(SEL)selector
{
  if (!song || !song.id)
    return;
  
  NextSong* nextSong = [[NextSong alloc] init];
  nextSong.radio = self.radio;
  nextSong.song = song;
  nextSong.order = [NSNumber numberWithInt:position];
  
  Auth* auth = self.apiKeyAuth;
  NSMutableDictionary* userData = [[NSMutableDictionary alloc] init];
  [userData setValue:target forKey:@"clientTarget"];
  [userData setValue:NSStringFromSelector(selector) forKey:@"clientSelector"];
  [_communicator postNewObject:nextSong notifyTarget:self byCalling:@selector(didCreateNextSong:withInfo:) withUserData:userData withAuth:auth returnNewObject:NO withAuthForGET:nil];
}

- (void)didCreateNextSong:(NSString*)location withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  
  NSError* error = [info valueForKey:@"error"];
  if (error)
  {
    if (target && selector)
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:nil withObject:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil]];
    return;
  }
  
  [self nextSongsForUserRadioWithTarget:target action:selector];
}

- (void)addSongToUserRadio:(Song*)song
{
  if (!song || !song.id || !self.radio || !self.radio.id)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSNumber* songID = song.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/favorite_song", self.radio.id];
  NSString* data = [NSString stringWithFormat:@"{\"id\":\"%@\"}", songID];
  
  [_communicator postToURL:relativeUrl absolute:NO withStringData:data objectClass:[Song class] notifyTarget:nil byCalling:nil withUserData:nil withAuth:auth returnNewObject:NO withAuthForGET:nil];
}


- (void)radioUserForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (!radio || !radio.id)
    return;
  NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/radio_user", radio.id];
  Auth* auth = self.apiKeyAuth;
  [_communicator getObjectWithClass:[RadioUser class] withURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)setMood:(UserMood)mood forRadio:(Radio*)radio
{
  if (!radio || !radio.id)
    return;
  
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
  
  NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/%@", radio.id, moodStr];
  Auth* auth = self.apiKeyAuth;
  [_communicator postToURL:url absolute:NO notifyTarget:nil byCalling:nil withUserData:nil withAuth:auth];
}


- (void)followUser:(User*)user target:(id)target action:(SEL)selector
{
    if (!user)
        return;
    
    NSString* url = [NSString stringWithFormat:@"api/v1/user/%@/friends/%@", self.user.username, user.username];
    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = url;
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)unfollowUser:(User*)user target:(id)target action:(SEL)selector
{
    if (!user)
        return;
    
    NSString* url = [NSString stringWithFormat:@"api/v1/user/%@/friends/%@", self.user.username, user.username];
    
    DLog(@"unfollow url : %@", url);
    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = url;
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"DELETE";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}


- (void)setRadio:(Radio*)radio asFavorite:(BOOL)favorite
{
    [self setRadio:radio asFavorite:favorite target:nil action:nil];
}

- (void)setRadio:(Radio*)radio asFavorite:(BOOL)favorite target:(id)target action:(SEL)selector
{
    NSString* favoriteStr;
    if (favorite)
        favoriteStr = @"favorite";
    else
        favoriteStr = @"not_favorite";
    
    NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/%@", radio.id, favoriteStr];

    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = url;
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)radioHasBeenShared:(Radio*)radio with:(NSString*)shareType
{
  if (!radio || !radio.id)
    return;
    
    Auth* auth = self.apiKeyAuth;
    NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/shared", radio.id];
    NSString* data = [NSString stringWithFormat:@"{\"type\":\"%@\"}", shareType];
    
    [_communicator postToURL:url absolute:NO withStringData:data objectClass:nil notifyTarget:nil byCalling:nil withUserData:nil withAuth:auth returnNewObject:NO withAuthForGET:nil];
}


- (void)setMood:(UserMood)mood forSong:(Song*)song
{
  if (!song || !song.id)
    return;
  
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
  
  NSString* url = [NSString stringWithFormat:@"api/v1/song/%@/%@", song.id, moodStr];
  Auth* auth = self.apiKeyAuth;
  [_communicator postToURL:url absolute:NO notifyTarget:nil byCalling:nil withUserData:nil withAuth:auth];
}

- (void)songUserForSong:(Song*)song target:(id)target action:(SEL)selector
{
  if (!song || !song.id)
    return;
  NSString* url = [NSString stringWithFormat:@"api/v1/song/%@/song_user", song.id];
  Auth* auth = self.apiKeyAuth;
  [_communicator getObjectWithClass:[SongUser class] withURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}


- (void)updatePlaylists:(NSData*)data forRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/playlists_update", radioID];
  NSDictionary* userData = [NSDictionary dictionaryWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", nil];
  [_communicator postData:data withKey:@"playlists_data" toURL:relativeUrl absolute:NO notifyTarget:self byCalling:@selector(receiveUpdatePlaylistsResponse:withInfo:) withUserData:userData withAuth:auth];
  
}

- (void)receiveUpdatePlaylistsResponse:(NSString*)response withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"target"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"selector"]);
  NSError* error = [info valueForKey:@"error"];
  
  if (error)
  {
    if (target && selector)
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:nil withObject:error];
    return;
  }
  
  taskID task_id = response;
  if (!task_id)
  {
    error = [NSError errorWithDomain:@"can't retrieve task ID from request response" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, @"response", nil]];
    if (target && selector)
        if ([target respondsToSelector:selector])
            [target performSelector:selector withObject:nil withObject:error];
    return;
  }
  
  if (target && selector)
      if ([target respondsToSelector:selector])
          [target performSelector:selector withObject:task_id withObject:nil];
}

- (void)taskStatus:(taskID)task_id target:(id)target action:(SEL)selector
{
  if (task_id == nil)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSString* url = [NSString stringWithFormat:@"api/v1/task/%@", task_id];
  NSDictionary* userData = [NSDictionary dictionaryWithObjectsAndKeys:target, @"target", NSStringFromSelector(selector), @"selector", nil];
  [_communicator getURL:url absolute:NO notifyTarget:self byCalling:@selector(receiveTaskStatus:withInfo:) withUserData:userData withAuth:auth];
}



- (void)receiveTaskStatus:(NSString*)response withInfo:(NSDictionary*)info
{
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"target"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"selector"]);
  NSError* error = [info valueForKey:@"error"];
  
  TaskInfo* taskInfo = [TaskInfo taskInfoWithString:response];
  
  if (target && selector)
      if ([target respondsToSelector:selector])
          [target performSelector:selector withObject:taskInfo withObject:error];
}


- (void)similarRadiosWithArtistList:(NSData*)data target:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/similar_radios_from_artist_list/"];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIFormDataRequest* req = [_communicator buildFormDataRequestWithConfig:conf];
    [req addData:data forKey:@"artists_data"];
    [req startAsynchronous];
}

- (void)connectedUsersWithLimitNumber:(NSNumber*)limit skipNumber:(NSNumber*)skip target:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/connected_users/"];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    NSMutableArray* params = [NSMutableArray array];
    if (limit)
        [params addObject:[NSString stringWithFormat:@"limit=%@", limit]];
    if (skip)
        [params addObject:[NSString stringWithFormat:@"skip=%@", skip]];
    if (params.count > 0)
        conf.params = params;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)connectedUsersWithTarget:(id)target action:(SEL)selector
{
    [self connectedUsersWithLimitNumber:nil skipNumber:nil target:target action:selector];
}

- (void)connectedUsersWithLimit:(int)limit skip:(int)skip target:(id)target action:(SEL)selector
{
    [self connectedUsersWithLimitNumber:[NSNumber numberWithInt:limit] skipNumber:[NSNumber numberWithInt:skip] target:target action:selector];
}


// 
// Radio listening stats
//
- (void)monthListeningStatsWithTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSString* url = @"/api/v1/listening_stats/";
  NSMutableArray* params = [[NSMutableArray alloc] init];
  [params addObject:[NSString stringWithFormat:@"radio=%@", self.radio.id]];
  
  [_communicator getObjectsWithClass:[RadioListeningStat class] withURL:url absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
    
    [params release];    
}

- (void)leaderboardWithTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSString* url = @"/api/v1/leaderboard/";
  [_communicator getObjectsWithClass:[LeaderBoardEntry class] withURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

// Playlists
- (void)playlistsForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
  NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/all_playlist/", radio.id];
  Auth* auth = self.apiKeyAuth;
  [_communicator getObjectsWithClass:[Playlist class] withURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
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
        DLog(@"MEUH!");
        assert(0);
        return nil;
    }
    
    //LBDEBUG
    if (![radio_id isKindOfClass:[NSNumber class]])
    {
        DLog(@"MEUH!");
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

- (void)updateSong:(Song*)song target:(id)target action:(SEL)selector
{
    if (!song)
        return;
  
  Auth* auth = self.apiKeyAuth;
  NSString* url = [NSString stringWithFormat:@"api/v1/edit_song/%@", song.id];
    

    //LBDEBUG
//    DLog(@"edit url '%@'", url);
//    if ([url isEqualToString:@"api/v1/edit_song/0"])
//    {
//        DLog(@"OK");
//        DLog(@"song.id  0x%p", song.id);
//        DLog(@"%d", [song.id integerValue]);
//        assert(0);
//    }
    //////////////
        
  [_communicator updateObject:song withURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)deleteSong:(Song*)song target:(id)target action:(SEL)selector userData:(id)data
{
    if (!song)
        return;
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:target forKey:@"clientTarget"];
    [dict setValue:NSStringFromSelector(selector) forKey:@"clientSelector"];
    [dict setValue:song forKey:@"song"];
    [dict setValue:data forKey:@"clientData"];
    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/delete_song/%@", song.id];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"DELETE";
    conf.callbackTarget = self;
    conf.callbackAction = @selector(didDeleteSong:);
    conf.userData = dict;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)didDeleteSong:(ASIHTTPRequest*)req
{
    int resCode = req.responseStatusCode;
    NSDictionary* response = [req responseDict];
    BOOL success = resCode == 200 && response != nil;
    
    NSDictionary* dict = (NSDictionary*)[req userData];
    id target = [dict valueForKey:@"clientTarget"];
    SEL action = NSSelectorFromString([dict valueForKey:@"clientSelector"]);
    id data = [dict valueForKey:@"clientData"];
    Song* song = (Song*)[dict valueForKey:@"song"];
    
    if (target && action)
    {
        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        [info setValue:data forKey:@"userData"];
        [info setValue:[NSNumber numberWithBool:success] forKey:@"success"];
        if ([target respondsToSelector:action])
            [target performSelector:action withObject:song withObject:info];
    }
}


- (void)deleteAllSongsFromRadio:(Radio*)radio target:(id)target action:(SEL)action
{
    if (!radio)
        return;
    
    Auth* auth = self.apiKeyAuth;
    
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

- (void)addSong:(YasoundSong*)yasoundSong target:(id)target action:(SEL)selector
{
  if (!yasoundSong)
    return;
  Auth* auth = self.apiKeyAuth;
  int playlistIndex = 0;
  NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/playlist/%d/add_song/%@", _radio.id, playlistIndex, yasoundSong.id];
  
  NSMutableDictionary* userData = [NSMutableDictionary dictionary];
  [userData setValue:target forKey:@"finalTarget"];
  [userData setValue:NSStringFromSelector(selector) forKey:@"finalSelector"];
  
  [_communicator postToURL:url absolute:NO notifyTarget:self byCalling:@selector(didAddSong:info:) withUserData:userData withAuth:auth];
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


- (void)apnsPreferencesWithTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSString* relativeURL = @"/api/v1/notifications_preferences";
  [_communicator getObjectWithClass:[APNsPreferences class] withURL:relativeURL absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)setApnsPreferences:(APNsPreferences*)prefs target:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSString* relativeURL = @"/api/v1/set_notifications_preferences";
  [_communicator postNewObject:prefs withURL:relativeURL absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth returnNewObject:NO withAuthForGET:nil];
}

- (void)facebookSharePreferencesWithTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"api/v1/facebook_share_preferences";
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}

- (void)setFacebookSharePreferences:(FacebookSharePreferences*)prefs target:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"api/v1/set_facebook_share_preferences";
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    
    NSString* stringData = [prefs JSONRepresentation];
    [req appendPostData:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req startAsynchronous];
}


#pragma mark - Menu Descriptions

- (void)menuDescriptionWithTarget:(id)target action:(SEL)selector
{
    [self menuDescriptionWithTarget:target action:selector userData:nil];
}

- (void)menuDescriptionWithTarget:(id)target action:(SEL)selector  userData:(id)data
{    
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"api/v1/app_menu";
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    conf.userData = data;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}


#pragma mark - User Notifications   

- (void)broadcastMessage:(NSString*)message fromRadio:(Radio*)radio withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/radio/%@/broadcast_message/", radio.uuid];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    conf.callbackTarget = target;
    conf.callbackAction = selector;

    ASIFormDataRequest* req =  [_communicator buildFormDataRequestWithConfig:conf];
//    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];

    [req addPostValue:message forKey:@"message"];

    [req startAsynchronous];
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


- (void)subscriptionComplete:(NSString*)productId target:(id)target action:(SEL)action
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v1/premium/subscriptions/%@", productId];
    conf.urlIsAbsolute = NO;
    conf.auth = self.apiKeyAuth;
    conf.method = @"POST";
    conf.callbackTarget = target;
    conf.callbackAction = action;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}








#pragma mark - city suggestions
- (void)citySuggestionsWithCityName:(NSString*)city target:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = @"http://nominatim.openstreetmap.org/search";
    conf.urlIsAbsolute = YES;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    NSMutableArray* params = [NSMutableArray array];
    [params addObject:@"format=json"];
    [params addObject:[NSString stringWithFormat:@"q=%@", city]];
    conf.params = params;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}







- (void)leaderboardForRadio:(Radio*)radio withTarget:(id)target action:(SEL)selector
{
    RequestConfig* conf = [[RequestConfig alloc] init];
    conf.url = [NSString stringWithFormat:@"api/v2/radio/%@/leaderboard", radio.uuid];
    conf.urlIsAbsolute = NO;
    conf.method = @"GET";
    conf.callbackTarget = target;
    conf.callbackAction = selector;
    
    ASIHTTPRequest* req = [_communicator buildRequestWithConfig:conf];
    [req startAsynchronous];
}




//................................................................................................................................
//
// DEPRECATED
//


- (void)radiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
    [self radiosWithGenre_deprecated:genre withTarget:target action:selector userData:nil];
}

- (void)topRadiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
    [self topRadiosWithGenre_deprecated:genre withTarget:target action:selector userData:nil];
}

- (void)selectedRadiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
    [self selectedRadiosWithGenre_deprecated:genre withTarget:target action:selector userData:nil];
}

- (void)newRadiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
    [self newRadiosWithGenre_deprecated:genre withTarget:target action:selector userData:nil];
}


- (void)favoriteRadiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
    [self favoriteRadiosWithGenre_deprecated:genre withTarget:target action:selector userData:nil];
}

//
- (void)radiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData
{
    {
        Auth* auth = self.apiKeyAuth;
        NSMutableArray* params = [NSMutableArray array];
        [params addObject:@"ready=true"];
        if (genre)
            [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
        [_communicator getObjectsWithClass:[Radio class] withParams:params notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
    }
}
- (void)topRadiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData
{
    Auth* auth = self.apiKeyAuth;
    NSMutableArray* params = [NSMutableArray array];
    if (genre)
        [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
    
    [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/top_radio" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
}

- (void)selectedRadiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData
{
    Auth* auth = self.apiKeyAuth;
    NSMutableArray* params = [NSMutableArray array];
    if (genre)
        [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
    
    [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/selected_radio" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
}

- (void)newRadiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData
{
    Auth* auth = self.apiKeyAuth;
    NSMutableArray* params = [NSMutableArray arrayWithObject:@"order_by=-created"];
    [params addObject:@"ready=true"];
    if (genre)
        [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
    
    [_communicator getObjectsWithClass:[Radio class] withParams:params notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
}
- (void)favoriteRadiosWithGenre_deprecated:(NSString*)genre withTarget:(id)target action:(SEL)selector userData:(id)userData
{
    Auth* auth = self.apiKeyAuth;
    NSMutableArray* params = [NSMutableArray array];
    if (genre)
        [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
    
    [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/favorite_radio" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:userData withAuth:auth];
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


