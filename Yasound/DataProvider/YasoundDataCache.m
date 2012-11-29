//
//  YasoundDataCache.m
//  Yasound
//
//  Created by loïc berthelot on 2011/02/20
//  Copyright (c) 2011 Yasound. All rights reserved.
//
#import "YasoundDataCache.h"
#import "DateAdditions.h"
#import "NSObject+SBJSON.h"
#import "PlaylistMoulinor.h"
#import "TimeProfile.h"


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
  }
  
  return self;
}


- (void)dealloc
{
    [_cacheRadios release];
    [_cacheSongs release];
    [_cacheFriends release];
    
    [super dealloc];
}






//
// return local data from cache, using a request key, and a specific genre
//

- (Container*)cachedRadioForKey:(NSString*)key withGenre:(NSString*)genre
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
    Container* data = [requestCacheForGenre objectForKey:@"data"];
    return data;
}




//
// send a request to server, to update local cache
//

- (void)requestRadiosUpdate:(NSURL*)url withGenre:(NSString*)genre target:(id)target action:(SEL)action
{
    YasoundDataCachePendingOp* op = [[YasoundDataCachePendingOp alloc] init];
    [op retain];
    op.object = url;
    op.info = genre;
    op.target = target;
    op.action = action;

    [[YasoundDataProvider main] radiosWithUrl:[url absoluteString] withGenre:genre withTarget:self action:@selector(radioReceived:success:) userData:op];
    return;
}

- (void)radioReceived:(ASIHTTPRequest*)req success:(BOOL)success
{
    YasoundDataCachePendingOp* op = [req userData];;
    assert(op != nil);
    
    id target = op.target;
    SEL action = op.action;
    
    Container* radioContainer = [req responseObjectsWithClass:[Radio class]];
    
    if (radioContainer == nil)
    {
        DLog(@"YasoundDataCache requestRadios : the server returned nil!");
        [target performSelector:action withObject:nil withObject:NO];
        return;
    }
    
    // expiration date for the newly received data
    NSDate* date = [NSDate date];
    NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_RADIOS];
    
    NSURL* url = op.object;
    
    // get/create dico for request
    NSMutableDictionary* requestCache = [_cacheRadios objectForKey:[url absoluteString]];
    if (requestCache == nil)
    {
        requestCache = [[NSMutableDictionary alloc] init];
        [_cacheRadios setObject:requestCache forKey:[url absoluteString]];
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
    
    [requestCacheForGenre setObject:radioContainer forKey:@"data"];
    
    // pending operation cleaning
    [op release];
    
    // return results to pending client
    //DLog(@"YasoundDataCache requestRadios : return server's updated data");
    [target performSelector:action withObject:radioContainer withObject:YES];
    
}






//
// return local cache , if it's available, using a request key and a genre
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(NSArray*)data withInfo:(NSDictionnary*)info
//
- (void)requestRadiosWithUrl:(NSURL*)url withGenre:(NSString*)genre target:(id)target action:(SEL)selector;
{
    Container* data = [self cachedRadioForKey:[url absoluteString] withGenre:genre];
    
    // there is no cached data yet for that request, OR it's expired
    // => request update from server
    if (data == nil)
    {
        [self requestRadiosUpdate:url withGenre:genre target:target action:selector];
        return;
    }
    
    // we got the cached data. Return to client, now.
    [target performSelector:selector withObject:data withObject:YES];
}


- (void)requestRadioRecommendationFirstPageWithUrl:(NSURL*)url genre:(NSString*)genre target:(id)target action:(SEL)selector
{
    Container* data = [self cachedRadioForKey:[url absoluteString] withGenre:genre];
    
    // there is no cached data yet for that request, OR it's expired
    // => request update from server
    if (data == nil)
    {
        // do not exist or it's expired
        YasoundDataCachePendingOp* op = [[YasoundDataCachePendingOp alloc] init];
        [op retain];
        op.target = target;
        op.action = selector;
        op.object = url;
        op.info = genre;
        [[PlaylistMoulinor main] buildArtistDataBinary:YES compressed:YES target:self action:@selector(didBuildArtistData:) userInfo:op];

        return;
    }
    
    // we got the cached data. Return to client, now.
    [target performSelector:selector withObject:data withObject:YES];
}

- (void)didBuildArtistData:(NSDictionary*)info
{
    NSData* data = [info valueForKey:@"result"];
    YasoundDataCachePendingOp* op = [info valueForKey:@"userInfo"];
    NSString* genre = op.info;
    
    [[YasoundDataProvider main] radioRecommendationsWithArtistList:data genre:genre target:self action:@selector(radioReceived:success:) userData:op];
}


//
// empty local cache for a given request.
// for instance, you may want to clear REQUEST_RADIOS_FAVORITES after having added a radio in your favorites
//
- (void)clearRadios:(NSString*)REQUEST
{
    DLog(@"YasoundDataCache::clearRadios for ref '%@'", REQUEST);
    [_cacheRadios removeObjectForKey:REQUEST];
}



- (void)clearRadiosAll
{
    DLog(@"YasoundDataCache::clearRadiosAll"); 
    [_cacheRadios release];
    
    _cacheRadios = [[NSMutableDictionary alloc] init];
    [_cacheRadios retain];
}












//
// return local data from cache, using a request key, and a specific genre
//

- (Song*)cachedSongForRadio:(Radio*)radio
{
    if (!radio || !radio.id)
        return nil;
    
    // get cache
    NSDictionary* requestCache = [_cacheSongs objectForKey:[radio.id stringValue]];
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
- (void)requestCurrentSongForRadio:(Radio*)radio withCompletionBlock:(YasoundDataCacheResultBlock)block
{
    Song* data = [self cachedSongForRadio:radio];
    if (data)
    {
        if (block)
            block(data);
        return;
    }
    
    // there is no cached data yet for that request, OR it's expired
    // => request update from server
    [[YasoundDataProvider main] currentSongForRadio:radio withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"YasoundDataCache requestCurrentSong error: %d - %@", error.code, error.domain);
            if (block)
                block(nil);
            return;
        }
        if (status != 200)
        {
            DLog(@"YasoundDataCache requestCurrentSong error: response status %d", status);
            if (block)
                block(nil);
            return;
        }
        Song* song = (Song*)[response jsonToModel:[Song class]];
        if (!song)
        {
            DLog(@"YasoundDataCache requestCurrentSong error: cannot parse response: %@", response);
            if (block)
                block(nil);
            return;
        }
        
        // expiration date for the newly received data
        NSDate* date = [NSDate date];
        NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_CURRENTSONGS];
        
        // get/create dico for request
        NSMutableDictionary* requestCache = [_cacheSongs objectForKey:[radio.id stringValue]];
        if (requestCache == nil)
        {
            requestCache = [[NSMutableDictionary alloc] init];
            [_cacheSongs setObject:requestCache forKey:[radio.id stringValue]];
        }
        
        // cache data
        [requestCache setObject:timeout forKey:@"timeout"];
        
        [requestCache setObject:song forKey:@"data"];
        
        // send song to caller
        if (block)
            block(song);
    }];
}


- (void)clearCurrentSongs
{
    DLog(@"YasoundDataCache::clearCurrentSongs");
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
    //DLog(@"YasoundDataCache requestFriendsWithTarget : return local cached data");
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
        DLog(@"YasoundDataCache requestFriendsWithTarget : the server returned nil!");
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
    //DLog(@"YasoundDataCache requestFriendsWithTarget : return server's updated data");
    [target performSelector:action withObject:friends withObject:info];
}



- (void)clearFriends
{
    DLog(@"YasoundDataCache::clearFriends");

    [_cacheFriends release];
    _cacheFriends = [[NSMutableDictionary alloc] init];
    [_cacheFriends retain];
}












static UIImage* gDummyImage = nil;

- (UIImage*)requestImage:(NSURL*)url target:(id)target action:(SEL)selector
{
    NSString* key = [url absoluteString];
    
    
    // is there a cache for this image?
    YasoundDataCacheImage* cache = [[YasoundDataCacheImageManager main].memoryCacheImages objectForKey:key];

    
    UIImage* image = nil;
    BOOL imageNeedsUpdate = NO;
    
    // there is not a cache, yet
    if (cache == nil)
    {
        // init the cache. The image may be imported from the disk, if it's been stored already
        cache = [[YasoundDataCacheImage alloc] initWithUrl:url];
        [[YasoundDataCacheImageManager main].memoryCacheImages setObject:cache forKey:key];        
    }

#ifdef DEBUG_PROFILE
    //LBDEBUG ICI
    [[TimeProfile main] begin:@"requestImage2"];
#endif

    // set the last_access date
    [cache updateTimestamp];
    
#ifdef DEBUG_PROFILE
    //LBDEBUG ICI
    [[TimeProfile main] end:@"requestImage2"];
    [[TimeProfile main] logAverageInterval:@"requestImage2" inMilliseconds:YES];
#endif

    
    // cache image is not downloaded yet (or was not store on disk)
    if (cache.image == nil) 
    {
        // let the target know when it's downloaded
        [cache addTarget:target action:selector];
        
        // last try was unsuccessful, retry.
        if (cache.isDownloading)
            imageNeedsUpdate = NO;
        else
            imageNeedsUpdate = YES;

        image  = [UIImage imageNamed:@"commonAvatarDummy.png"];
    }
    
    // it's downloaded already, give it to the target
    else {
        image = cache.image;
    }
    
    
    // request the image to the server
    if (imageNeedsUpdate)
        [cache start];
    
    
    //LBDEBUG
//    [[YasoundDataCacheImageManager main] dump];
    
    
    return image;
}





// this target doesn't want to receive the downloaded image anymore.
// it's necessary for the TableViews' cells for instance : the cells are reused for different objects, without having been released and reallocated.
// Therefore, we have to break the link manually, in order to avoid weird behavior (wrong images appearing in the wrong cells...)
- (void)releaseImageRequest:(NSURL*)url forTarget:(id)target
{
    NSString* key = [url absoluteString];
    
    YasoundDataCacheImage* cache = [[YasoundDataCacheImageManager main].memoryCacheImages objectForKey:key];
    if (cache == nil)
        return;
    
    // image is downloaded already
    if (cache.image != nil)
        return;
    
    // image is still downloading. Clear it's targets list
    [cache removeTarget:target];
}










@end


