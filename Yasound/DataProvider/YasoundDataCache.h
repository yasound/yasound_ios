//
//  YasoundDataCache.h
//  Yasound
//
//  Created by loïc berthelot on 2011/02/20
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"
#import "YasoundDataCacheImage.h"
#import "YasoundDataProvider.h"

typedef void (^YasoundDataCacheResultBlock)(id);




@interface YasoundDataCachePendingOp : NSObject

@property (nonatomic, retain) id object;
@property (nonatomic, retain) id info;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;
@end




@interface YasoundDataCache : NSObject
{
    NSMutableDictionary* _cacheRadios;
    NSMutableDictionary* _cacheSongs;
    NSMutableDictionary* _cacheFriends;
}







+ (YasoundDataCache*) main;

//
// empty local cache for a given request.
// for instance, you may want to clear REQUEST_RADIOS_FAVORITES after having added a radio in your favorites
//
- (void)clearRadios:(NSString*)REQUEST;


// be carreful, empty the whole local cache
- (void)clearRadiosAll;
- (void)clearCurrentSongs;
- (void)clearFriends;


//
// return local cache , if it's available, using a request key and a genre
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(Container*)data success:(BOOL)success
//
- (void)requestRadiosWithUrl:(NSURL*)url withGenre:(NSString*)genre target:(id)target action:(SEL)selector;

//
// return local cache , if it's available
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(Container*)data success:(BOOL)success
//
- (void)requestRadioRecommendationFirstPageWithUrl:(NSURL*)url genre:(NSString*)genre target:(id)target action:(SEL)selector;

//
// return local cache , if it's available, using the radio ID
// request for an update to server if local cache is not available or expired
//
- (void)requestCurrentSongForRadio:(Radio*)radio withCompletionBlock:(YasoundDataCacheResultBlock)block;

- (void)requestFriendsWithCompletionBlock:(YasoundDataCacheResultBlock)block;


- (UIImage*)requestImage:(NSURL*)url target:(id)target action:(SEL)selector;
- (void)releaseImageRequest:(NSURL*)url forTarget:(id)target;




#define URL_RADIOS_FAVORITES @"/api/v1/favorite_radio"
#define URL_RADIOS_SELECTION @"/api/v1/selected_radio"
#define URL_RADIOS_TOP @"/api/v1/most_active_radio"
#define URL_LEGAL @"legal/eula.html"




@end
