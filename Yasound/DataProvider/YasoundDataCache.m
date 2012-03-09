//
//  YasoundDataCache.m
//  Yasound
//
//  Created by loïc berthelot on 2011/02/20
//  Copyright (c) 2011 Yasound. All rights reserved.
//
#import "YasoundDataCache.h"
#import "DateAdditions.h"
#import "YasoundDataProvider.h"


// 300 seconds = 5 min
#define TIMEOUT_RADIOS 60
#define TIMEOUT_CURRENTSONGS 60
#define TIMEOUT_FRIENDS 60

// 1 hour
#define TIMEOUT_IMAGE (10*60)


#define GENRE_NIL @"GENRE_NIL"


//.................................................................................................
//
// YasoundDataCachePendingOp
//
//.................................................................................................

@implementation YasoundDataCachePendingOp

@synthesize object;
@synthesize info;
@synthesize target;
@synthesize action;

@end







//.................................................................................................
//
// YasoundDataCache
//
//.................................................................................................



@implementation YasoundDataCache


static YasoundDataCache* _main = nil;

+ (YasoundDataCache*) main
{
  if (_main == nil)
  {
    _main = [[YasoundDataCache alloc] init];
  }
  
  return _main;
}


- (id)init
{
  self = [super init];
  if (self)
  {
      _cacheRadios = [[NSMutableDictionary alloc] init];
      [_cacheRadios retain];
      _cacheSongs = [[NSMutableDictionary alloc] init];
      [_cacheSongs retain];
      _cacheFriends = [[NSMutableDictionary alloc] init];
      [_cacheFriends retain];
      
      _cacheImages = [[NSMutableDictionary alloc] init];
      [_cacheImages retain];

      
  }
  
  return self;
}


- (void)dealloc
{
    [_cacheRadios release];
    [_cacheSongs release];
    [_cacheFriends release];
    [_cacheImages release];
    [super dealloc];
}






//
// return local data from cache, using a request key, and a specific genre
//

- (NSArray*)cachedRadioForKey:(NSString*)key withGenre:(NSString*)genre
{
    NSString* _genre = (genre == nil)? GENRE_NIL : genre;
    
    // get cache
    NSDictionary* requestCache = [_cacheRadios objectForKey:key];
    if (requestCache == nil)
        return nil;
    
    NSDictionary* requestCacheForGenre = [requestCache objectForKey:_genre];
    if (requestCacheForGenre == nil)
        return nil;
    
    // cache is here, see if it's expired
    NSDate* timeout = [requestCacheForGenre objectForKey:@"timeout"];
    NSDate* date = [NSDate date];
    if ([date isLaterThanOrEqualTo:timeout])
        return nil; // yes, it's expired
    
    // everything's ok, return cached data
    NSArray* data = [requestCacheForGenre objectForKey:@"data"];
    return data;
}




//
// send a request to server, to update local cache
//

- (void)requestRadiosUpdate:(NSString*)REQUEST withGenre:(NSString*)genre target:(id)target action:(SEL)action
{
    YasoundDataCachePendingOp* op = [[YasoundDataCachePendingOp alloc] init];
    [op retain];
    op.object = REQUEST;
    op.info = genre;
    op.target = target;
    op.action = action;
    

    if ([op.object isEqualToString:REQUEST_RADIOS_ALL])
    {
        [[YasoundDataProvider main] radiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:) userData:op];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_TOP])
    {
        [[YasoundDataProvider main] topRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:)  userData:op];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_SELECTION])
    {
        [[YasoundDataProvider main] selectedRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:) userData:op];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_NEW])
    {
        [[YasoundDataProvider main] newRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:) userData:op];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_FRIENDS])
    {
        [[YasoundDataProvider main] friendsRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:) userData:op];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_FAVORITES])
    {
        [[YasoundDataProvider main] favoriteRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:) userData:op];
        return;
    }
         
}



//
// data provider callback
//
- (void)radioReceived:(NSArray*)radios withInfo:(NSDictionary*)info
{
    YasoundDataCachePendingOp* op = [info objectForKey:@"userData"]; 
    assert(op != nil);
    
    id target = op.target;
    SEL action = op.action;
    
    if (radios == nil)
    {
        NSLog(@"YasoundDataCache requestRadios : the server returned nil!");
        [target performSelector:action withObject:nil withObject:info];
        return;
    }

    
    
    
    // expiration date for the newly received data
    NSDate* date = [NSDate date];
    NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_RADIOS];
    
    // get/create dico for request
    NSMutableDictionary* requestCache = [_cacheRadios objectForKey:[NSNumber numberWithInteger:op.object]];
    if (requestCache == nil)
    {
        requestCache = [[NSMutableDictionary alloc] init];
        [_cacheRadios setObject:requestCache forKey:[NSNumber numberWithInteger:op.object]];
    }
    
    // get/create dico for request/genre
    NSString* _genre = (op.info == nil)? GENRE_NIL : op.info;

    NSMutableDictionary* requestCacheForGenre = [requestCache objectForKey:_genre];
    if (requestCacheForGenre == nil)
    {
        requestCacheForGenre = [[NSMutableDictionary alloc] init];
        [requestCache setObject:requestCacheForGenre forKey:_genre];
    }
    
    // cache data 
    [requestCacheForGenre setObject:timeout forKey:@"timeout"];
    
    [requestCacheForGenre setObject:radios forKey:@"data"];
    
    // pending operation cleaning
    [op release];
//    [_pendingRadios removeObjectAtIndex:0];
    
    // return results to pending client
    NSLog(@"YasoundDataCache requestRadios : return server's updated data");
    [target performSelector:action withObject:radios withObject:info];
}







//
// return local cache , if it's available, using a request key and a genre
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(NSArray*)data withInfo:(NSDictionnary*)info
//
- (void)requestRadios:(NSString*)REQUEST withGenre:(NSString*)genre target:(id)target action:(SEL)selector
{
    NSArray* data = [self cachedRadioForKey:REQUEST withGenre:genre];
    
    // there is no cached data yet for that request, OR it's expired
    // => request update from server
    if (data == nil)
    {
        [self requestRadiosUpdate:REQUEST withGenre:genre target:target action:selector];
        return;
    }

    // we got the cached data. Return to client, now.
    NSDictionary* infoDico = nil;
    NSLog(@"YasoundDataCache requestRadios : return local cached data");
    [target performSelector:selector withObject:data withObject:infoDico];
}




//
// empty local cache for a given request.
// for instance, you may want to clear REQUEST_RADIOS_FAVORITES after having added a radio in your favorites
//
- (void)clearRadios:(NSString*)REQUEST
{
    [_cacheRadios removeObjectForKey:REQUEST];
}



- (void)clearRadiosAll
{
    [_cacheRadios release];
    
    _cacheRadios = [[NSMutableDictionary alloc] init];
    [_cacheRadios retain];
}




















//
// return local data from cache, using a request key, and a specific genre
//

- (Song*)cachedSongForRadio:(Radio*)radio
{
    // get cache
    NSDictionary* requestCache = [_cacheSongs objectForKey:[NSNumber numberWithInteger:radio]];
    if (requestCache == nil)
        return nil;
    
    // cache is here, see if it's expired
    NSDate* timeout = [requestCache objectForKey:@"timeout"];
    NSDate* date = [NSDate date];
    if ([date isLaterThanOrEqualTo:timeout])
        return nil; // yes, it's expired
    
    // everything's ok, return cached data
    Song* data = [requestCache objectForKey:@"data"];
    return data;
}


//
// return local cache , if it's available, using the radio ID
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(Song*)song withInfo:(NSDictionnary*)info
//
- (void)requestCurrentSongForRadio:(Radio*)radio target:(id)target action:(SEL)selector
{
    Song* data = [self cachedSongForRadio:radio];
    
    // there is no cached data yet for that request, OR it's expired
    // => request update from server
    if (data == nil)
    {
        YasoundDataCachePendingOp* op = [[YasoundDataCachePendingOp alloc] init];
        [op retain];
        op.object = radio;
        op.info = nil;
        op.target = target;
        op.action = selector;
        
        [[YasoundDataProvider main] currentSongForRadio:radio target:self action:@selector(receivedCurrentSong:withInfo:) userData:op];
        return;
    }
    
    // we got the cached data. Return to client, now.
    NSDictionary* infoDico = nil;
    //NSLog(@"YasoundDataCache requestCurrentSongForRadio : return local cached data"); // don't display it all the time, too much of it :)
    [target performSelector:selector withObject:data withObject:infoDico];    
}




- (void)receivedCurrentSong:(Song*)song withInfo:(NSDictionary*)info
{
    YasoundDataCachePendingOp* op = [info objectForKey:@"userData"]; 
    assert(op != nil);
    
    id target = op.target;
    SEL action = op.action;
    
    // the radio may be empty
    if (song == nil)
    {
        NSLog(@"YasoundDataCache requestCurrentSong : the server returned nil!");
        [target performSelector:action withObject:nil withObject:info];
        return;
    }
    

    
    
    // expiration date for the newly received data
    NSDate* date = [NSDate date];
    NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_CURRENTSONGS];
    
    // get/create dico for request
    NSMutableDictionary* requestCache = [_cacheSongs objectForKey:[NSNumber numberWithInteger:op.object]];
    if (requestCache == nil)
    {
        requestCache = [[NSMutableDictionary alloc] init];
        [_cacheSongs setObject:requestCache forKey:[NSNumber numberWithInteger:op.object]];
  //      [_cacheSongs setObject:requestCache forKey:@"prout"];
    }
    
    // cache data 
    [requestCache setObject:timeout forKey:@"timeout"];
    
    [requestCache setObject:song forKey:@"data"];
    
    
    // pending operation cleaning
    [op release];
    //    [_pendingRadios removeObjectAtIndex:0];
    
    // return results to pending client
    NSLog(@"YasoundDataCache requestRadios : return server's updated data");
    [target performSelector:action withObject:song withObject:info];
    
    //    // process the next pending operation, if any
    //    if (_pendingRadios.count > 0)
    //        [self loop];    
}


- (void)clearCurrentSongs
{
    [_cacheSongs release];

    _cacheSongs = [[NSMutableDictionary alloc] init];
    [_cacheSongs retain];
}




















//
// return local data from cache, using a request key, and a specific genre
//

- (NSArray*)cachedFriends
{
    // cache is here, see if it's expired
    NSDate* timeout = [_cacheFriends objectForKey:@"timeout"];
    NSDate* date = [NSDate date];
    if ([date isLaterThanOrEqualTo:timeout])
        return nil; // yes, it's expired
    
    // everything's ok, return cached data
    NSArray* data = [_cacheFriends objectForKey:@"data"];
    return data;
}


//
// return local cache , if it's available, 
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(NSArray*)friends info:(NSDictionnary*)info
//
- (void)requestFriendsWithTarget:(id)target action:(SEL)selector
{
    NSArray* data = [self cachedFriends];
    
    // there is no cached data yet for that request, OR it's expired
    // => request update from server
    if (data == nil)
    {
        YasoundDataCachePendingOp* op = [[YasoundDataCachePendingOp alloc] init];
        [op retain];
        op.object = nil;
        op.info = nil;
        op.target = target;
        op.action = selector;
        
        [[YasoundDataProvider main] friendsWithTarget:self action:@selector(receiveFriends:info:) userData:op];
        return;
    }
    
    // we got the cached data. Return to client, now.
    NSDictionary* infoDico = nil;
    NSLog(@"YasoundDataCache requestFriendsWithTarget : return local cached data");
    [target performSelector:selector withObject:data withObject:infoDico];    
}




- (void)receiveFriends:(NSArray*)friends info:(NSDictionary*)info
{
    YasoundDataCachePendingOp* op = [info objectForKey:@"userData"]; 
    assert(op != nil);

    id target = op.target;
    SEL action = op.action;

    if (friends == nil)
    {
        NSLog(@"YasoundDataCache requestFriendsWithTarget : the server returned nil!");
        [target performSelector:action withObject:nil withObject:info];
        return;
    }
        
    
    
    // expiration date for the newly received data
    NSDate* date = [NSDate date];
    NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_FRIENDS];
    
    // cache data 
    [_cacheFriends setObject:timeout forKey:@"timeout"];
    
    [_cacheFriends setObject:friends forKey:@"data"];
    
    
    // pending operation cleaning
    [op release];
    
    // return results to pending client
    NSLog(@"YasoundDataCache requestFriendsWithTarget : return server's updated data");
    [target performSelector:action withObject:friends withObject:info];
}



- (void)clearFriends
{
    [_cacheFriends release];
    _cacheFriends = [[NSMutableDictionary alloc] init];
    [_cacheFriends retain];
}












static UIImage* gDummyImage = nil;

- (UIImage*)requestImage:(NSURL*)url target:(id)target action:(SEL)selector
{
    NSString* key = [url absoluteString];
    
    // is there a cache for this image?
    YasoundDataCacheImage* cache = [_cacheImages objectForKey:key];

    UIImage* image = nil;
    BOOL imageNeedsUpdate = NO;
    
    // there is not a cache, yet
    if (cache == nil)
    {
        imageNeedsUpdate = YES;

        cache = [[YasoundDataCacheImage alloc] initWithUrl:url];
        [_cacheImages setObject:cache forKey:key];        
        
        // set its timeout timer
        cache.timer = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_IMAGE target:self selector:@selector(onImageTimeout:) userInfo:key repeats:NO];
    }
    
    // there is a cache, reset its timeout timer
    else
    {
        cache.timeout = NO;
        [cache.timer invalidate];
        cache.timer = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_IMAGE target:self selector:@selector(onImageTimeout:) userInfo:key repeats:NO];
    }        
    
    
    // cache image is not downloaded yet
    if (cache.image == nil) 
    {
        // let the target know when it's downloaded
        [cache addTarget:target action:selector];

        if (gDummyImage == nil)
            gDummyImage = [UIImage imageNamed:@"avatarDummy.png"];
        
        // meanwhile, give the target the dummy image
        image = gDummyImage;
    }
    
    // it's downloaded already, give it to the target
    else
        image = cache.image;
    
    
    // request the image to the server
    if (imageNeedsUpdate)
        [cache start];
    
    
    return image;
}



// this target doesn't want to receive the downloaded image anymore.
// it's necessary for the TableViews' cells for instance : the cells are reused for different objects, without having been released and reallocated.
// Therefore, we have to break the link manually, in order to avoid weird behavior (wrong images appearing in the wrong cells...)
- (void)releaseImageRequest:(NSURL*)url forTarget:(id)target
{
    NSString* key = [url absoluteString];
    
    YasoundDataCacheImage* cache = [_cacheImages objectForKey:key];
    if (cache == nil)
        return;
    
    // image is downloaded already
    if (cache.image != nil)
        return;
    
    // image is still downloading. Clear it's targets list
    [cache removeTarget:target];
}




// image timeout is triggered
- (void)onImageTimeout:(NSTimer*)timer
{
    NSString* key = timer.userInfo;
    
    // is this image still in the cache?
    YasoundDataCacheImage* cache = [_cacheImages objectForKey:key];
    if (cache == nil)
        return;
    
    // yes. flag the timeout. The Garbage Collector will know, then.
    cache.timeout = YES;    
}




@end


