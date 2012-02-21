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
#define TIMEOUT_INTERVAL 300

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
      
      _pendingRadios = [[NSMutableArray alloc] init];
      [_pendingRadios retain];
      
      _cacheSongs = [[NSMutableDictionary alloc] init];
      [_cacheSongs retain];
      
      _pendingSongs = [[NSMutableArray alloc] init];
      [_pendingSongs retain];
      
  }
  
  return self;
}


- (void)dealloc
{
    [_cacheRadios release];
    [_pendingRadios release];
    [_cacheSongs release];
    [_pendingSongs release];
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
    op.object = REQUEST;
    op.info = genre;
    op.target = target;
    op.action = action;
    
    [_pendingRadios addObject:op];
    
    if (_pendingRadios.count == 1)
        [self loop];
}


- (void)loop
{
    YasoundDataCachePendingOp* op = [_pendingRadios objectAtIndex:0]; 

    if ([op.object isEqualToString:REQUEST_RADIOS_ALL])
    {
        [[YasoundDataProvider main] radiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_TOP])
    {
        [[YasoundDataProvider main] topRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_SELECTION])
    {
        [[YasoundDataProvider main] selectedRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_NEW])
    {
        [[YasoundDataProvider main] newRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_FRIENDS])
    {
        [[YasoundDataProvider main] friendsRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.object isEqualToString:REQUEST_RADIOS_FAVORITES])
    {
        [[YasoundDataProvider main] favoriteRadiosWithGenre:op.info withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }
         
}



//
// data provider callback
//
- (void)radioReceived:(NSArray*)radios withInfo:(NSDictionary*)info
{
    YasoundDataCachePendingOp* op = [_pendingRadios objectAtIndex:0]; 
    
    // expiration date for the newly received data
    NSDate* date = [NSDate date];
    NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_INTERVAL];
    
    // get/create dico for request
    NSMutableDictionary* requestCache = [_cacheRadios objectForKey:op.object];
    if (requestCache == nil)
    {
        requestCache = [[NSMutableDictionary alloc] init];
        [_cacheRadios setObject:requestCache forKey:op.object];
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
    
    id target = op.target;
    SEL action = op.action;
    
    // pending operation cleaning
    [op release];
    [_pendingRadios removeObjectAtIndex:0];
    
    // return results to pending client
    NSDictionary* infoDico = nil;
    
    NSLog(@"YasoundDataCache : return server's updated data");
    [target performSelector:action withObject:radios withObject:infoDico];
    
    // process the next pending operation, if any
    if (_pendingRadios.count > 0)
        [self loop];

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
    NSLog(@"YasoundDataCache : return local cached data");
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



- (void)clearAll:(BOOL)yesImSure
{
    // :)
    if (!yesImSure)
        return;
    
    [_cacheRadios release];
    
    _cacheRadios = [[NSMutableDictionary alloc] init];
    [_cacheRadios retain];
}












//
//
//
//- (void)receivedCurrentSong:(Song*)song withInfo:(NSDictionary*)info
//{
//    if (!song)
//        return;
//    
//    self.radioSubtitle1.text = song.artist;
//    self.radioSubtitle2.text = song.name;
//}
//
//
////
//// return local cache , if it's available, using the radio ID
//// request for an update to server if local cache is not available or expired
////
//// - (void)selector:(Song*)song withInfo:(NSDictionnary*)info
////
//- (void)requestCurrentSongForRadio:(Radio*)radio target:(id)target action:(SEL)selector
//{
//    Song* data = [self cachedSongForRadio:radio];
//    
//    // there is no cached data yet for that request, OR it's expired
//    // => request update from server
//    if (data == nil)
//    {
//        YasoundDataCachePendingOp* op = [[YasoundDataCachePendingOp alloc] init];
//        op.object = radio;
//        op.info = nil;
//        op.target = target;
//        op.action = selector;
//        
//        [_pendingSongs addObject:op];
//
//        
//        [[YasoundDataProvider main] currentSongForRadio:self.radio target:self action:@selector(receivedCurrentSong:withInfo:)];
//        return;
//    }
//    
//    // we got the cached data. Return to client, now.
//    NSDictionary* infoDico = nil;
//    NSLog(@"YasoundDataCache : return local cached data");
//    [target performSelector:selector withObject:data withObject:infoDico];    
//}
//
//



@end


