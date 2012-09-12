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
    NSDictionary* _cacheRecommendation;
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
// - (void)selector:(NSArray*)data withInfo:(NSDictionnary*)info
//
- (void)requestRadiosWithUrl:(NSURL*)url withGenre:(NSString*)genre target:(id)target action:(SEL)selector;

//
// return local cache , if it's available
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(NSArray*)radios withInfo:(NSDictionnary*)info
//
- (void)requestRadioRecommendationWithTarget:(id)target action:(SEL)selector;

//
// return local cache , if it's available, using the radio ID
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(Song*)song withInfo:(NSDictionnary*)info
//
- (void)requestCurrentSongForRadio:(Radio*)radio target:(id)target action:(SEL)selector;


- (void)requestFriendsWithTarget:(id)target action:(SEL)selector;


- (UIImage*)requestImage:(NSURL*)url target:(id)target action:(SEL)selector;
- (void)releaseImageRequest:(NSURL*)url forTarget:(id)target;



// return the most recent menu description, or the default menu description if no other one has been downloaded yet
//- (NSArray*)menu;

// replace the current menu description in the user settings (does not overwrite the default menu description)
//- (void)setMenu:(NSString*)JSONdescription;



#define URL_RADIOS_FAVORITES @"/api/v1/favorite_radio"
#define URL_RADIOS_SELECTION @"/api/v1/selected_radio"
#define URL_RADIOS_TOP @"/api/v1/most_active_radio"
#define URL_LEGAL @"legal/eula.html"


//#define MENU_ENTRY_ID_SELECTION @"radioSelection"
//#define MENU_ENTRY_ID_FAVORITES @"radioMyFavorites"
//#define MENU_ENTRY_ID_TOP @"radioTop"
//
//// return the dictionary description of the current menu, from its given type (for instance, "
//- (NSDictionary*)menuEntry:(NSString*)entryId;
////
////
//#define MENU_ENTRY_PARAM_URL @"url"
////#define MENU_ENTRY_PARAM_GENRE_SELECTION @"genre_selection"
////#define MENU_ENTRY_PARAM_RADIO_ID @"radio_id"
////
//- (id)entryParameter:(NSString*)param forEntry:(NSDictionary*)entry;


@end
