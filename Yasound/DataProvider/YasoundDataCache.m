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
#import "NSObject+SBJSON.h"
#import "PlaylistMoulinor.h"



// 300 seconds = 5 min
#define TIMEOUT_RADIOS 60
#define TIMEOUT_CURRENTSONGS 60
#define TIMEOUT_FRIENDS 60
#define TIMEOUT_RECOMMENDATION 3 * 60 * 60

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
      if (_cacheRecommendation)
          [_cacheRecommendation release];
      _cacheRecommendation = nil;
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

- (void)requestRadiosUpdate:(NSURL*)url withGenre:(NSString*)genre target:(id)target action:(SEL)action
{
    YasoundDataCachePendingOp* op = [[YasoundDataCachePendingOp alloc] init];
    [op retain];
    op.object = url;
    op.info = genre;
    op.target = target;
    op.action = action;

    [[YasoundDataProvider main] radiosWithUrl:[url absoluteString] withGenre:genre withTarget:self action:@selector(radioReceived:withInfo:) userData:op];
    return;
}



//
// data provider callback
//
- (void)radioReceived:(NSArray*)radios withInfo:(NSDictionary*)info
{
    //LBDEBUG
    //NSLog(@"%@", info);
    /////////
    
    YasoundDataCachePendingOp* op = [info objectForKey:@"userData"];
    assert(op != nil);
    
    id target = op.target;
    SEL action = op.action;
    
    if (radios == nil)
    {
        DLog(@"YasoundDataCache requestRadios : the server returned nil!");
        [target performSelector:action withObject:nil withObject:info];
        return;
    }

    
    
    
    // expiration date for the newly received data
    NSDate* date = [NSDate date];
    NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_RADIOS];
    
//    NSString* RequestId = op.object;
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
    
    [requestCacheForGenre setObject:radios forKey:@"data"];
    
    // pending operation cleaning
    [op release];
    
    // return results to pending client
    //DLog(@"YasoundDataCache requestRadios : return server's updated data");
    [target performSelector:action withObject:radios withObject:info];
    
}







//
// return local cache , if it's available, using a request key and a genre
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(NSArray*)data withInfo:(NSDictionnary*)info
//
- (void)requestRadiosWithUrl:(NSURL*)url withGenre:(NSString*)genre target:(id)target action:(SEL)selector;
{
    NSArray* data = [self cachedRadioForKey:[url absoluteString] withGenre:genre];
    
    // there is no cached data yet for that request, OR it's expired
    // => request update from server
    if (data == nil)
    {
        [self requestRadiosUpdate:url withGenre:genre target:target action:selector];
        return;
    }
    
    // we got the cached data. Return to client, now.
    NSDictionary* infoDico = nil;
    //DLog(@"YasoundDataCache requestRadios : return local cached data");
    [target performSelector:selector withObject:data withObject:infoDico];
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



#pragma mark - recommendation
- (NSArray*)cacheRecommendationRadios
{
    if (!_cacheRecommendation)
        return nil;
    
    NSDate* timeout = [_cacheRecommendation objectForKey:@"timeout"];
    NSDate* date = [NSDate date];
    if ([date isLaterThanOrEqualTo:timeout])
        return nil; // yes, it's expired
    
    // everything's ok, return cached data
    NSArray* radios = [_cacheRecommendation objectForKey:@"data"];
    return radios;
}

- (void)requestRadioRecommendationWithTarget:(id)target action:(SEL)selector
{
    NSArray* radios = [self cacheRecommendationRadios];
    if (!radios)
    {
        // do not exist or it's expired
        YasoundDataCachePendingOp* op = [[YasoundDataCachePendingOp alloc] init];
        [op retain];
        op.target = target;
        op.action = selector;
        [[PlaylistMoulinor main] buildArtistDataBinary:YES compressed:YES target:self action:@selector(didBuildArtistData:) userInfo:op];
        
        return;
    }
    
    [target performSelector:selector withObject:radios withObject:nil];
}

- (void)didBuildArtistData:(NSDictionary*)info
{
    NSData* data = [info valueForKey:@"result"];
    NSDictionary* userInfo = [info valueForKey:@"userInfo"];
    
    [[YasoundDataProvider main] radioRecommendationsWithArtistList:data target:self action:@selector(receivedRecomandation:success:) userData:userInfo];
}

- (void)receivedRecomandation:(ASIHTTPRequest*)req success:(NSNumber*)success
{
    YasoundDataCachePendingOp* op = [req userData];
    id target = op.target;
    SEL selector = op.action;
    [op release];
    NSArray* radios = [req responseObjectsWithClass:[Radio class]].objects;
    NSDate* date = [NSDate date];
    NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_RECOMMENDATION];
    
    NSDictionary* cache = [NSDictionary dictionaryWithObjectsAndKeys:radios, @"data", timeout, @"timeout", nil];
    if (_cacheRecommendation)
        [_cacheRecommendation release];
    _cacheRecommendation = cache;
    [_cacheRecommendation retain];
    
    [target performSelector:selector withObject:radios withObject:nil];
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
    //DLog(@"YasoundDataCache requestCurrentSongForRadio : return local cached data"); // don't display it all the time, too much of it :)
    [target performSelector:selector withObject:data withObject:infoDico];    
}




- (void)receivedCurrentSong:(Song*)song withInfo:(NSDictionary*)info
{
    YasoundDataCachePendingOp* op = [info objectForKey:@"userData"]; 
    assert(op != nil);
    
    id target = op.target;
    SEL action = op.action;
    Radio* radio = op.object;
    
    // the radio may be empty
    if (song == nil)
    {
        DLog(@"YasoundDataCache requestCurrentSong : the server returned nil!");
        [target performSelector:action withObject:nil withObject:info];
        return;
    }
    

    
    
    // expiration date for the newly received data
    NSDate* date = [NSDate date];
    NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_CURRENTSONGS];
    
    // get/create dico for request
    NSMutableDictionary* requestCache = [_cacheSongs objectForKey:radio.id];
    if (requestCache == nil)
    {
        requestCache = [[NSMutableDictionary alloc] init];
        [_cacheSongs setObject:requestCache forKey:radio.id];
    }
    
    // cache data 
    [requestCache setObject:timeout forKey:@"timeout"];
    
    [requestCache setObject:song forKey:@"data"];
    
    
    // pending operation cleaning
    [op release];
    //    [_pendingRadios removeObjectAtIndex:0];
    
    // return results to pending client
    //DLog(@"YasoundDataCache requestRadios : return server's updated data");
    [target performSelector:action withObject:song withObject:info];
    
    //    // process the next pending operation, if any
    //    if (_pendingRadios.count > 0)
    //        [self loop];    
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

    // set the last_access date
    [cache updateTimestamp];
    
    
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
    else
        image = cache.image;
    
    
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













//............................................................................................................................................
//
// MENU
//

//// return the most recent menu description, or the default menu description if no other one has been downloaded yet
//- (NSArray*)menu
//{
//    NSArray* descr = [[UserSettings main] objectForKey:USKEYcacheMenuDescription];
//
//    if (descr != nil)
//        return descr;
//    
//    // no menu description yet, get the default one from the resources
//    
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"menu" ofType: @"json"];
//
//    NSString* descrStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    descr = [descrStr JSONValue];
//    
//    [[UserSettings main] setObject:descr forKey:USKEYcacheMenuDescription];
//
//    return descr;
//}




// replace the current menu description in the user settings (does not overwrite the default menu description)
//- (void)setMenu:(NSString*)JSONdescription
//{
//    NSArray* descr = [JSONdescription JSONValue];
//    
//    DLog(@"YasoundDataCache::setMenu %@", descr);
//
//    [[UserSettings main] setObject:descr forKey:USKEYcacheMenuDescription];
//}


// return the dictionary description of the current menu, from its given ID (for instance, "radioSelection")
//- (NSDictionary*)menuEntry:(NSString*)entryId
//{
//    NSArray* menu = [self menu];
//    
//    for (NSDictionary* section in menu)
//    {
//        NSArray* entries = [section objectForKey:@"entries"];
//        
//        for (NSDictionary* entry in entries)
//        {
//            DLog(@"%@", entry);
//            NSString* curId = [entry objectForKey:@"id"];
//            
//            if ([curId isEqualToString:entryId])
//                return entry;
//        }
//    }
//    
//    DLog(@"YasoundDataCache::menuEntry Error : could not find any entry for id '%@'", entryId);
//    DLog(@"debug menu : %@", menu);
//    
//    return nil;
//}
//
//
//- (id)entryParameter:(NSString*)param forEntry:(NSDictionary*)entry
//{
//    NSDictionary* params = [entry objectForKey:@"params"];
//    if (params == nil)
//    {
//        DLog(@"YasoundDataCache::entryParameter : no params, can not get param '%@'", param);
//        return nil;
//    }
//    
//    NSString* result = [params objectForKey:param];
//    if (result == nil)
//    {
//        DLog(@"YasoundDataCache::entryParameter : param '%@' is nil", param);
//        return nil;
//    }
//    
//    return result;
//}




@end


