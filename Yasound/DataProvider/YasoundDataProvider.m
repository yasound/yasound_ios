//
//  YasoundDataProvider.m
//  Yasound
//
//  Created by matthieu campion on 12/9/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "YasoundDataProvider.h"
#import "UIImage+Resize.h"

#define LOCAL_URL @"http://127.0.0.1:8000"
#define DEV_URL @"https://dev.yasound.com"

#define APP_KEY_COOKIE_NAME @"app_key"
#define APP_KEY_IPHONE @"yasound_iphone_app"

#define MAX_IMAGE_DIMENSION 1024

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
    NSLog(@"use LOCAL SERVER '%@'", baseUrl);
#else
    baseUrl = DEV_URL;
    NSLog(@"use DEV SERVER '%@'", baseUrl);
#endif
    _communicator = [[Communicator alloc] initWithBaseURL:baseUrl];
    _communicator.appCookie = self.appCookie;
    
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

- (void)resetUser
{
  _user = nil;
  _radio = nil;
  _apiKey = nil;
}



// SIGN UP
- (void)signup:(NSString*)email password:(NSString*)pwd username:(NSString*)username target:(id)target action:(SEL)selector
{
  [self resetUser];
  
  User* u = [[User alloc] init];
  u.username = email;
  u.email = email;
  u.name = username;
  u.password = pwd;
  
  NSDictionary* userData = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", u.username, @"username", u.password, @"password", nil];
  
  [_communicator postNewObject:u withURL:@"api/v1/signup" absolute:NO notifyTarget:self byCalling:@selector(didReceiveSignup:withInfo:) withUserData:userData withAuth:nil returnNewObject:NO withAuthForGET:NO];
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
  if (!location && !error)
    error = [NSError errorWithDomain:@"can't create user" code:1 userInfo:nil];
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
    NSLog(@"login error: %@", error.domain);    
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
    [target performSelector:selector withObject:_user withObject:finalInfo];
  }
  
}

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

- (void)receiveLogin:(NSArray*)users withInfo:(NSDictionary*)info
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
  if (clientData)
    [finalInfo setValue:clientData forKey:@"userData"];
  
  if (target && selector)
  {
    [target performSelector:selector withObject:_user withObject:finalInfo];
  }
}


- (void)loginSocialWithAuth:(AuthSocial*)auth target:(id)target action:(SEL)selector
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
  [_communicator getObjectsWithClass:[User class] withURL:@"api/v1/login_social/" absolute:NO notifyTarget:self byCalling:@selector(didReceiveLoginSocial:withInfo:) withUserData:data withAuth:auth];
}

- (void)loginFacebook:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token email:(NSString*)email target:(id)target action:(SEL)selector
{
  AuthSocial* auth = [[AuthSocial alloc] initWithUsername:username accountType:type uid:uid token:token andEmail:email];
  [self loginSocialWithAuth:auth target:target action:selector];
}

- (void)loginTwitter:(NSString*)username type:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret email:(NSString*)email target:(id)target action:(SEL)selector
{
  AuthSocial* auth = [[AuthSocial alloc] initWithUsername:username accountType:type uid:uid token:token tokenSecret:tokenSecret andEmail:email];
  [self loginSocialWithAuth:auth target:target action:selector];
}

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
  
  if (target && selector)
  {
    [target performSelector:selector withObject:_user withObject:finalInfo];
  }
}

- (void)userRadioWithTarget:(id)target action:(SEL)selector
{  
  if (!_user)
  {
    NSDictionary* info = [NSDictionary dictionaryWithObject:[NSError errorWithDomain:@"no logged user" code:1 userInfo:nil] forKey:@"error"];
    if (target && selector)
      [target performSelector:selector withObject:nil withObject:info];
    return;
  }
  
  NSArray* params = [NSArray arrayWithObject:[NSString stringWithFormat:@"creator=%@", _user.id]];
  Auth* auth = self.apiKeyAuth;
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:target, @"clientTarget", NSStringFromSelector(selector), @"clientSelector", nil];
  [_communicator getObjectsWithClass:[Radio class] withParams:params notifyTarget:self byCalling:@selector(didReceiveUserRadios:withInfo:) withUserData:data withAuth:auth];
}

- (void)didReceiveUserRadios:(NSArray*)radios withInfo:(NSDictionary*)info
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
  
  if (r)
  {
    _radio = r;
  }
  
  NSDictionary* userData = [info valueForKey:@"userData"];
  id target = [userData valueForKey:@"clientTarget"];
  SEL selector = NSSelectorFromString([userData valueForKey:@"clientSelector"]);
  
  if (target && selector)
  {
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


- (void)friendsWithTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  [_communicator getObjectsWithClass:[User class] withURL:@"/api/v1/friend" absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}


- (void)radioWithId:(NSNumber*)radioId target:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  [_communicator getObjectWithClass:[Radio class] andID:radioId notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)radiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray array];
  [params addObject:@"ready=true"];
  if (genre)
    [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
  [_communicator getObjectsWithClass:[Radio class] withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)topRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray arrayWithObject:@"order_by=-overall_listening_time"];
  [params addObject:@"ready=true"];
  if (genre)
    [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
  
  [_communicator getObjectsWithClass:[Radio class] withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)selectedRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray array];
  if (genre)
    [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
  
  [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/selected_radio" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)newRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray arrayWithObject:@"order_by=-created"];
  [params addObject:@"ready=true"];
  if (genre)
    [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
  
  [_communicator getObjectsWithClass:[Radio class] withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)friendsRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray array];
  if (genre)
    [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
  
  [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/friend_radio" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)favoriteRadiosWithGenre:(NSString*)genre withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray array];
  if (genre)
    [params addObject:[NSString stringWithFormat:@"genre=%@", genre]];
  
  [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/favorite_radio" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}



- (void)searchRadios:(NSString*)search withTarget:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSMutableArray* params = [NSMutableArray array];
  [params addObject:[NSString stringWithFormat:@"search=%@", search]];

  [_communicator getObjectsWithClass:[Radio class] withURL:@"/api/v1/search_radio" absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
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
  NSLog(@"img %f, %f", img.size.width, img.size.height);
  UIImage* resizedImg = [self resizeImage:img];
  NSLog(@"resized img %f, %f", resizedImg.size.width, resizedImg.size.height);
  Auth* auth = self.apiKeyAuth;
  NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/picture", radio.id];
  [_communicator postData:UIImagePNGRepresentation(resizedImg) withKey:@"picture" toURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}


- (void)setPicture:(UIImage*)img forUser:(User*)user target:(id)target action:(SEL)selector
{
  UIImage* resizedImg = [self resizeImage:img];
  Auth* auth = self.apiKeyAuth;
  NSString* url = [NSString stringWithFormat:@"api/v1/user/%@/picture", user.id];
  [_communicator postData:UIImagePNGRepresentation(resizedImg) withKey:@"picture" toURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

// get wall events
- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize target:(id)target action:(SEL)selector
{
  if (radio == nil)
    return;
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/wall", radioID];
  NSMutableArray* params = [[NSMutableArray alloc] init];
  [params addObject:[NSString stringWithFormat:@"limit=%d", pageSize]];
  [_communicator getObjectsWithClass:[WallEvent class] withURL:relativeUrl absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)wallEventsForRadio:(Radio*)radio pageSize:(int)pageSize afterEventWithID:(NSNumber*)lastEventID target:(id)target action:(SEL)selector
{
  if (!radio || !radio.id)
    return;
  if (!lastEventID)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/wall", radioID];
  NSMutableArray* params = [[NSMutableArray alloc] init];
  [params addObject:[NSString stringWithFormat:@"id__lt=%@", lastEventID]];
  [params addObject:[NSString stringWithFormat:@"limit=%d", pageSize]];
  [_communicator getObjectsWithClass:[WallEvent class] withURL:relativeUrl absolute:NO withParams:params notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
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
  if (radio == nil || !radio.id)
    return;
  Auth* auth = self.apiKeyAuth;
  NSNumber* radioID = radio.id;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/radio/%@/current_song", radioID];
  [_communicator getObjectWithClass:[Song class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
}

- (void)statusForSongId:(NSNumber*)songId target:(id)target action:(SEL)selector
{
  if (!songId)
    return;
  
  Auth* auth = self.apiKeyAuth;
  NSString* relativeUrl = [NSString stringWithFormat:@"api/v1/song/%@/status", songId];
  [_communicator getObjectWithClass:[SongStatus class] withURL:relativeUrl absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
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

- (void)setRadio:(Radio*)radio asFavorite:(BOOL)favorite
{
  if (!radio || !radio.id)
    return;
  
  NSString* favoriteStr;
  if (favorite)
    favoriteStr = @"favorite";
  else
    favoriteStr = @"not_favorite";
  
  NSString* url = [NSString stringWithFormat:@"api/v1/radio/%@/%@", radio.id, favoriteStr];
  Auth* auth = self.apiKeyAuth;
  [_communicator postToURL:url absolute:NO notifyTarget:nil byCalling:nil withUserData:nil withAuth:auth];
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
      [target performSelector:selector withObject:nil withObject:error];
    return;
  }
  
  taskID task_id = response;
  if (!task_id)
  {
    error = [NSError errorWithDomain:@"can't retrieve task ID from request response" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, @"response", nil]];
    if (target && selector)
      [target performSelector:selector withObject:nil withObject:error];
    return;
  }
  
  if (target && selector)
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
  taskStatus status = stringToStatus(response);
  
  if (target && selector)
    [target performSelector:selector withObject:status withObject:error];
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
}


- (void)uploadSong:(NSData*)song songId:(NSNumber*)songId target:(id)target action:(SEL)selector
{
  Auth* auth = self.apiKeyAuth;
  NSString* url = [NSString stringWithFormat:@"api/v1/upload_song/%@/", songId];
  [_communicator postData:song withKey:@"song" toURL:url absolute:NO notifyTarget:target byCalling:selector withUserData:nil withAuth:auth];
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


