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
#import "SBJsonStreamWriter.h"

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
      
      NSMutableDictionary* resourceNames = [Model resourceNames];
      [resourceNames setObject:@"radio" forKey:[YaRadio class]];
      [resourceNames setObject:@"user" forKey:[User class]];
      [resourceNames setObject:@"wall_event" forKey:[WallEvent class]];
      [resourceNames setObject:@"song" forKey:[Song class]];
      [resourceNames setObject:@"api_key" forKey:[ApiKey class]];
      [resourceNames setObject:@"radio_user" forKey:[RadioUser class]];
      [resourceNames setObject:@"song_user" forKey:[SongUser class]];
      [resourceNames setObject:@"next_song" forKey:[NextSong class]];
  }
  
  return self;
}


- (void)cancelRequestsForKey:(NSString*)key
{
    [YaRequest cancelWithKey:key];
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
  if (!picturePath)
    return nil;
  
  BOOL absolute = [picturePath hasPrefix:@"http"];
  NSURL* url = [YaRequest urlWithURL:picturePath absolute:absolute addTrailingSlash:NO params:nil];
    
  return url;
}

- (NSURL*)urlForSongCover:(Song*)song
{
  if (!song || !song.id)
    return nil;
  
  AuthApiKey* a = (AuthApiKey*)self.apiKeyAuth;
  NSDictionary* params = a.urlParamsDict;
  
  NSString* base = [NSString stringWithFormat:@"api/v1/song_instance/%@/cover/", song.id];
  NSURL* url = [YaRequest urlWithURL:base absolute:NO addTrailingSlash:NO params:params];
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


- (void)userRadioWithTargetWithCompletionBlock:(void (^) (YaRadio*))block
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
        YaRadio* radio = nil;
        if (error)
            radio = nil;
        else if (status != 200)
            radio = nil;
        else
        {
            Container* radioContainer = [response jsonToContainer:[YaRadio class]];
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



- (void)reloadUserRadio
{
    [self userRadioWithTargetWithCompletionBlock:nil];
}




#pragma mark - signup
// sign up process = signup request + login request

- (void)signup:(NSString*)email password:(NSString*)pwd username:(NSString*)username withCompletionBlock:(void (^) (User*, NSError*))block
{
    [self resetUser];
    
    User* u = [[User alloc] init];
    u.username = username;
    u.name = username;
    u.email = email;
    u.password = pwd;
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/signup";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.payload = [[u JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:^(int status, NSString* response, NSError* error){
        BOOL success = YES;
        if (error)
        {
            DLog(@"signup error: %d - %@", error.code, error.domain);
            success = NO;
        }
        else if (status != 201)
        {
            DLog(@"signup error: response status %d", status);
            success = NO;
        }
     
        if (!success)
        {
            if (block)
                block(nil, error);
            return;
        }
        
        // login
        [self login:u.email password:u.password withCompletionBlock:block];
    }];
}


#pragma mark - Login Yasound


- (void)login:(NSString*)email password:(NSString*)pwd withCompletionBlock:(void (^) (User*, NSError*))block
{
    [self resetUser];
    _password = pwd;

    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/login";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = [[AuthPassword alloc] initWithUsername:email andPassword:_password];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:^(int status, NSString* response, NSError* error){
        User* u = nil;
        if (error)
        {
            DLog(@"login error: %d - %@", error.code, error.domain);
            u = nil;
        }
        else if (status != 200)
        {
            DLog(@"login error: response status %d", status);
            u = nil;
        }
        else
        {
            Container* userContainer = [response jsonToContainer:[User class]];
            if (!userContainer || !userContainer.objects || userContainer.objects.count == 0)
            {
                DLog(@"login error: cannot parse response %@", response);
                u = nil;
            }
            else
            {
                u = [userContainer.objects objectAtIndex:0];
            }
        }
        
        if (u && u.api_key)
        {
            _user = u;
            _apiKey = u.api_key;
        }
        
        if (block)
            block(u, error);
        
        if (u)
            [self userLogged];
    }];

}


#pragma mark - Login Facebook and Twitter

- (void)loginSocialWithAuth:(AuthSocial*)auth withCompletionBlock:(void (^) (User*, NSError*))block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/login_social/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = auth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:^(int status, NSString* response, NSError* error){
        User* u = nil;
        if (error)
        {
            DLog(@"login social error: %d - %@", error.code, error.domain);
            u = nil;
        }
        else if (status != 200)
        {
            DLog(@"login social error: response status %d", status);
            u = nil;
        }
        else
        {
            Container* userContainer = [response jsonToContainer:[User class]];
            if (!userContainer || !userContainer.objects || userContainer.objects.count == 0)
            {
                DLog(@"login social error: cannot parse response %@", response);
                u = nil;
            }
            else
            {
                u = [userContainer.objects objectAtIndex:0];
            }
        }
        
        if (u && u.api_key)
        {
            _user = u;
            _apiKey = u.api_key;
        }
        
        if (block)
            block(u, error);
        
        if (u)
            [self userLogged];
    }];
}

- (void)loginFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token expirationDate:(NSString*)expirationDate email:(NSString*)email withCompletionBlock:(void (^) (User*, NSError*))block
{
    AuthSocial* auth = [[AuthSocial alloc] initWithUsername:username accountType:type uid:uid token:token expirationDate:expirationDate andEmail:email];
    [self loginSocialWithAuth:auth withCompletionBlock:block];
}

- (void)loginTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email withCompletionBlock:(void (^) (User*, NSError*))block
{
    AuthSocial* auth = [[AuthSocial alloc] initWithUsername:username accountType:type uid:uid token:token tokenSecret:tokenSecret andEmail:email];
    [self loginSocialWithAuth:auth withCompletionBlock:block];
}




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
    if (!radioId)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"/api/v1/radio/%@/", radioId];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)radioWithUuid:(NSString*)radioUuid withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!radioUuid)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"/api/v1/public_radio/%@/", radioUuid];
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

- (void)radiosWithUrl:(NSString*)url withGenre:(NSString*)genre withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = url;
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.groupKey = @"radios";
    
    if (genre)
        config.params = [NSDictionary dictionaryWithObject:genre forKey:@"genre"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
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

- (void)deleteRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)updateRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)setPicture:(UIImage*)img forRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (NSString*)wallEventsRequestgroupKeyForRadio:(YaRadio*)radio
{
    if (!radio || !radio.id)
        return nil;
    NSString* key = [NSString stringWithFormat:@"%@-%@", @"get_wall_events_group_key", radio.id];
    return key;
}

- (void)cancelWallEventsRequestsForRadio:(YaRadio*)radio
{
    NSString* key = [self wallEventsRequestgroupKeyForRadio:radio];
    if (!key)
        return;
    [YaRequest cancelWithKey:key];
}

- (void)wallEventsForRadio:(YaRadio*)radio olderThanEventWithID:(NSNumber*)lastEventID newerThanEventWithID:(NSNumber*)firstEventID pageSizeNumber:(NSNumber*)pageSize withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)wallEventsForRadio:(YaRadio*)radio pageSize:(int)pageSize withCompletionBlock:(YaRequestCompletionBlock)block
{
    [self wallEventsForRadio:radio olderThanEventWithID:nil newerThanEventWithID:nil pageSizeNumber:[NSNumber numberWithInt:pageSize] withCompletionBlock:block];
}

- (void)wallEventsForRadio:(YaRadio*)radio pageSize:(int)pageSize olderThanEventWithID:(NSNumber*)lastEventID withCompletionBlock:(YaRequestCompletionBlock)block
{
    [self wallEventsForRadio:radio olderThanEventWithID:lastEventID newerThanEventWithID:nil pageSizeNumber:[NSNumber numberWithInt:pageSize] withCompletionBlock:block];
}

- (void)wallEventsForRadio:(YaRadio*)radio newerThanEventWithID:(NSNumber*)eventID withCompletionBlock:(YaRequestCompletionBlock)block
{
    [self wallEventsForRadio:radio olderThanEventWithID:nil newerThanEventWithID:eventID pageSizeNumber:nil withCompletionBlock:block];
}

- (void)postWallMessage:(NSString*)message toRadio:(YaRadio*)radio withCompletionBLock:(YaRequestCompletionBlock)block
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

- (void)enterRadioWall:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)leaveRadioWall:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)favoriteUsersForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)currentUsersForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)currentSongForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)setRadio:(YaRadio*)radio asFavorite:(BOOL)favorite withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)radioHasBeenShared:(YaRadio*)radio with:(NSString*)shareType withCompletionBlock:(YaRequestCompletionBlock)block
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


- (void)setMood:(UserMood)mood forSong:(Song*)song andRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!song || !radio)
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
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/likes/", radio.uuid];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
  
    NSMutableDictionary* jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:moodStr forKey:@"mood"];
    [jsonObject setObject:song.last_play_time forKey:@"last_play_time"];
    NSString* jsonString = jsonObject.JSONRepresentation;
    config.payload = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)updatePlaylists:(NSData*)data forRadio:(YaRadio*)radio withCompletionBlock:(void (^) (taskID))block
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


- (void)radioRecommendationsWithArtistList:(NSData*)data genre:(NSString*)genre withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/radio_recommendations/";
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    if (genre)
        config.params = [NSDictionary dictionaryWithObject:genre forKey:@"genre"];
    
    config.fileData = [NSDictionary dictionaryWithObject:data forKey:@"artists_data"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
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

- (void)monthListeningStatsForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)leaderboardForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)playlistsForRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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

- (void)songsForPlaylist:(NSInteger)playlistId withCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/song/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", playlistId] forKey:@"playlist"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (YaRequest*)uploadSong:(NSData*)song forRadioId:(NSNumber*)radio_id title:(NSString*)title album:(NSString*)album artist:(NSString*)artist songId:(NSNumber*)songId withCompletionBlock:(YaRequestCompletionBlock)block andProgressBlock:(YaRequestProgressBlock)progressBlock
{
    if ((song == nil) || (radio_id == nil))
    {
        assert(0);
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return nil;
    }
    
    //LBDEBUG
    if (![radio_id isKindOfClass:[NSNumber class]])
    {
        assert(0);
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return nil;
    }
    
    NSMutableDictionary* jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:radio_id forKey:@"radio_id"];
    [jsonObject setObject:title forKey:@"title"];
    [jsonObject setObject:album forKey:@"album"];
    [jsonObject setObject:artist forKey:@"artist"];
    NSString* jsonString = jsonObject.JSONRepresentation;

    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/upload_song/%@/", songId];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObject:jsonString forKey:@"data"];
    config.fileData = [NSDictionary dictionaryWithObject:song forKey:@"song"];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block progressBlock:progressBlock];
    return req;
}

- (void)matchedSongsForPlaylist:(Playlist*)playlist withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!playlist || !playlist.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/playlist/%@/matched_song", playlist.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
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

- (void)deleteAllSongsFromRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/programming/", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"DELETE";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];

}

- (void)deleteArtist:(NSString*)artist fromRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!artist || !radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    ProgrammingObjectParameters* params = [[ProgrammingObjectParameters alloc] init];
    params.action = @"delete";
    params.name = artist;
    
    NSString* stringData = [params JSONRepresentation];
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/programming/artists/", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)deleteAlbum:(NSString*)album fromRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!album || !radio || !radio.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    ProgrammingObjectParameters* params = [[ProgrammingObjectParameters alloc] init];
    params.action = @"delete";
    params.name = album;
    
    NSString* stringData = [params JSONRepresentation];
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/programming/albums/", radio.id];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];

}


- (void)rejectSong:(Song*)song withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!song || !song.id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/reject_song/%@", song.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)searchSong:(NSString*)search count:(NSInteger)count offset:(NSInteger)offset withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!search)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/search_song";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObjectsAndKeys:search, @"search", [NSString stringWithFormat:@"%d", count], @"song_count", [NSString stringWithFormat:@"%d", offset], @"song_offset", nil];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


- (void)addSong:(YasoundSong*)yasoundSong inRadio:(YaRadio*)radio withCompletionBlock:(void (^) (Song*, BOOL, NSError*))block
{
    if (!yasoundSong || !yasoundSong.id || !radio || !radio.id)
    {
        if (block)
            block(nil, NO, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    int playlistIndex = 0;
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/playlist/%d/add_song/%@", radio.id, playlistIndex, yasoundSong.id];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:^(int status, NSString* response, NSError* error){
        if (error || status != 200)
        {
            if (block)
                block(nil, NO, error);
            return;
        }
        NSDictionary* respDict = [response jsonToDictionary];
        NSNumber* songInstanceID = [respDict valueForKey:@"song_instance_id"];
        BOOL success = [[respDict valueForKey:@"success"] boolValue];
        BOOL created = [[respDict valueForKey:@"created"] boolValue];
        if (!success)
        {
            if (block)
                block(nil, NO, nil);
            return;
        }
        
        [self songWithId:songInstanceID withCompletionBlock:^(int status, NSString* response, NSError* error){
            if (error || status != 200)
            {
                if (block)
                    block(nil, NO, error);
                return;
            }
            Song* s = (Song*)[response jsonToModel:[Song class]];
            if (!s)
            {
                if (block)
                    block(nil, NO, nil);
                return;
            }
            
            if (block)
                block(s, created, nil);
        }];
        
    }];
}

- (void)songWithId:(NSNumber*)songId withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!songId)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/song/%@/", songId];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
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

- (void)broadcastMessage:(NSString*)message fromRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
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


- (void)userNotificationsWithLimit:(NSInteger)limit offset:(NSInteger)offset andCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/notifications/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", limit], @"limit", [NSString stringWithFormat:@"%d", offset], @"offset", nil];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)updateUserNotification:(UserNotification*)notif withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!notif || !notif._id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }

    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/update_notification/%@", notif._id];
    config.urlIsAbsolute = NO;
    config.method = @"PUT";
    config.auth = self.apiKeyAuth;
    config.payload = [[notif JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)deleteUserNotification:(UserNotification*)notif withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!notif || !notif._id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/delete_notification/%@", notif._id];
    config.urlIsAbsolute = NO;
    config.method = @"DELETE";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)deleteAllUserNotificationsWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/delete_all_notifications/";
    config.urlIsAbsolute = NO;
    config.method = @"DELETE";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)unreadNotificationCountWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/notifications/unread_count";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}


#pragma mark - shows

- (void)showsForRadio:(YaRadio*)r withCompletionBlock:(YaRequestCompletionBlock)block
{
    [self showsForRadio:r limit:nil offset:nil withCompletionBlock:block];
}
- (void)showsForRadio:(YaRadio*)r limit:(NSNumber*)limit offset:(NSNumber*)offset withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!r || !r.uuid)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/shows/", r.uuid];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    if (limit != nil && offset != nil)
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        if (limit != nil)
            [params setValue:[limit stringValue] forKey:@"limit"];
        if (offset != nil)
            [params setValue:[offset stringValue] forKey:@"offset"];
        config.params = params;
    }
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)showWithId:(NSString*)showId withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!showId)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/show/%@/", showId];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;

    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)updateShow:(Show*)show withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!show || !show._id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/show/%@", show._id];
    config.urlIsAbsolute = NO;
    config.method = @"PUT";
    config.auth = self.apiKeyAuth;
    config.payload = [[show JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)deleteShow:(Show*)show withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!show || !show._id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/show/%@", show._id];
    config.urlIsAbsolute = NO;
    config.method = @"DELETE";
    config.auth = self.apiKeyAuth;
    config.payload = [[show JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)duplicateShow:(Show*)show  withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!show || !show._id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/show/%@/duplicate", show._id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)createShow:(Show*)show inRadio:(YaRadio*)radio withCompletionBlock:(YaRequestCompletionBlock)block
{
    [self createShow:show inRadio:radio withYasoundSongs:nil withCompletionBlock:block];
}

- (void)createShow:(Show*)show inRadio:(YaRadio*)radio withYasoundSongs:(NSArray*)yasoundSongs withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!show || !show._id || !radio || !radio.uuid)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
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
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/radio/%@/create_show", radio.uuid];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.payload = [[data JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)songsForShow:(Show*)show withCompletionBlock:(YaRequestCompletionBlock)block
{
    [self songsForShow:show limit:nil offset:nil withCompletionBlock:block];
}

- (void)songsForShow:(Show*)show limit:(NSNumber*)limit offset:(NSNumber*)offset withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!show || !show._id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/show/%@/songs/", show._id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    if (limit != nil && offset != nil)
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        if (limit != nil)
            [params setValue:[limit stringValue] forKey:@"limit"];
        if (offset != nil)
            [params setValue:[offset stringValue] forKey:@"offset"];
    }
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)addSong:(YasoundSong*)song inShow:(Show*)show withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!song || !song.id || !show || !show._id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/show/%@/add_song/%@/", show._id, song.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)removeSong:(Song*)song fromShow:(Show*)show withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!song || !song.id || !show || !show._id)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/show/%@/remove_song/%@/", show._id, song.id];
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];

}





#pragma mark - in-app purchase

- (void)servicesWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/premium/services/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)subscriptionsWithCompletionBlock:(YaRequestCompletionBlock)block
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = @"api/v1/premium/subscriptions/";
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
}

- (void)subscriptionComplete:(NSString*)productId withBase64Receipt:(NSString*)appleReceipt withCompletionBlock:(YaRequestCompletionBlock)block
{
    if (!productId)
    {
        if (block)
            block(0, nil, [NSError errorWithDomain:@"cannot create request: bad paramameters" code:0 userInfo:nil]);
        return;
    }
    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = [NSString stringWithFormat:@"api/v1/premium/subscriptions/%@", productId];
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    config.params = [NSDictionary dictionaryWithObjectsAndKeys:appleReceipt, @"receipt", self.user.username, @"username", nil];
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:block];
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




- (void)sendGetRequestWithURL:(NSString*)url
{
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = url;
    config.urlIsAbsolute = NO;
    config.method = @"GET";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:nil];
}

- (void)sendPostRequestWithURL:(NSString*)url
{    
    YaRequestConfig* config = [YaRequestConfig requestConfig];
    config.url = url;
    config.urlIsAbsolute = NO;
    config.method = @"POST";
    config.auth = self.apiKeyAuth;
    
    YaRequest* req = [YaRequest requestWithConfig:config];
    [req start:nil];
}




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


