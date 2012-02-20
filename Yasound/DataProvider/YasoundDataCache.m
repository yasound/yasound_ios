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

@synthesize REQUEST;
@synthesize genre;
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
      _cache = [[NSMutableDictionary alloc] init];
      [_cache retain];
      
      _pending = [[NSMutableArray alloc] init];
      [_pending retain];
  }
  
  return self;
}


- (void)dealloc
{
    [_cache release];
    [_pending release];
    [super dealloc];
}






//
// return local data from cache, using a request key, and a specific genre
//

- (NSArray*)cachedDataForKey:(NSString*)key withGenre:(NSString*)genre
{
    NSString* _genre = (genre == nil)? GENRE_NIL : genre;
    
    // get cache
    NSDictionary* requestCache = [_cache objectForKey:key];
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
    op.REQUEST = REQUEST;
    op.genre = genre;
    op.target = target;
    op.action = action;
    
    [_pending addObject:op];
    
    if (_pending.count == 1)
        [self loop];
}


- (void)loop
{
    YasoundDataCachePendingOp* op = [_pending objectAtIndex:0]; 

    if ([op.REQUEST isEqualToString:REQUEST_RADIOS_ALL])
    {
        [[YasoundDataProvider main] radiosWithGenre:op.genre withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.REQUEST isEqualToString:REQUEST_RADIOS_TOP])
    {
        [[YasoundDataProvider main] topRadiosWithGenre:op.genre withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.REQUEST isEqualToString:REQUEST_RADIOS_SELECTION])
    {
        [[YasoundDataProvider main] selectedRadiosWithGenre:op.genre withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.REQUEST isEqualToString:REQUEST_RADIOS_NEW])
    {
        [[YasoundDataProvider main] newRadiosWithGenre:op.genre withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.REQUEST isEqualToString:REQUEST_RADIOS_FRIENDS])
    {
        [[YasoundDataProvider main] friendsRadiosWithGenre:op.genre withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }

    if ([op.REQUEST isEqualToString:REQUEST_RADIOS_FAVORITES])
    {
        [[YasoundDataProvider main] favoriteRadiosWithGenre:op.genre withTarget:self action:@selector(radioReceived:withInfo:)];
        return;
    }
         
}



//
// data provider callback
//
- (void)radioReceived:(NSArray*)radios withInfo:(NSDictionary*)info
{
    YasoundDataCachePendingOp* op = [_pending objectAtIndex:0]; 
    
    // expiration date for the newly received data
    NSDate* date = [NSDate date];
    NSDate* timeout = [date dateByAddingTimeInterval:TIMEOUT_INTERVAL];
    
    // get/create dico for request
    NSMutableDictionary* requestCache = [_cache objectForKey:op.REQUEST];
    if (requestCache == nil)
    {
        requestCache = [[NSMutableDictionary alloc] init];
        [_cache setObject:requestCache forKey:op.REQUEST];
    }
    
    // get/create dico for request/genre
    NSString* _genre = (op.genre == nil)? GENRE_NIL : op.genre;

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
    [_pending removeObjectAtIndex:0];
    
    // return results to pending client
    NSDictionary* infoDico = nil;
    
    NSLog(@"YasoundDataCache : return server's updated data");
    [target performSelector:action withObject:radios withObject:infoDico];
    
    // process the next pending operation, if any
    if (_pending.count > 0)
        [self loop];

}







//
// return local cache , if it's available, using a request key and a genre
// request for an update to server if local cache is not available
//
- (void)requestRadios:(NSString*)REQUEST withGenre:(NSString*)genre target:(id)target action:(SEL)selector
{
    NSArray* data = [self cachedDataForKey:REQUEST withGenre:genre];
    
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
    [_cache removeObjectForKey:REQUEST];
}



- (void)clearAll:(BOOL)yesImSure
{
    // :)
    if (!yesImSure)
        return;
    
    [_cache release];
    
    _cache = [[NSMutableDictionary alloc] init];
    [_cache retain];
}




@end


