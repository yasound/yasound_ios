//
//  YasoundDataCache.h
//  Yasound
//
//  Created by loïc berthelot on 2011/02/20
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"


#define REQUEST_RADIOS_ALL @"radiosWithGenre"
#define REQUEST_RADIOS_TOP @"topRadiosWithGenre"
#define REQUEST_RADIOS_SELECTION @"selectedRadiosWithGenre"
#define REQUEST_RADIOS_NEW @"newRadiosWithGenre"
#define REQUEST_RADIOS_FRIENDS @"friendsRadiosWithGenre"
#define REQUEST_RADIOS_FAVORITES @"favoriteRadiosWithGenre"



@interface YasoundDataCachePendingOp : NSObject

@property (nonatomic, retain) id object;
@property (nonatomic, retain) id info;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;
@end








@interface YasoundDataCache : NSObject
{
    NSMutableDictionary* _cacheRadios;
    NSMutableArray* _pendingRadios;

    NSMutableDictionary* _cacheSongs;
    NSMutableArray* _pendingSongs;
}



+ (YasoundDataCache*) main;

//
// empty local cache for a given request.
// for instance, you may want to clear REQUEST_RADIOS_FAVORITES after having added a radio in your favorites
//
- (void)clearRadios:(NSString*)REQUEST;


// be carreful, empty the whole local cache
- (void)clearAll:(BOOL)yesImSure;


//
// return local cache , if it's available, using a request key and a genre
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(NSArray*)data withInfo:(NSDictionnary*)info
//
- (void)requestRadios:(NSString*)REQUEST withGenre:(NSString*)genre target:(id)target action:(SEL)selector;


//
// return local cache , if it's available, using the radio ID
// request for an update to server if local cache is not available or expired
//
// - (void)selector:(Song*)song withInfo:(NSDictionnary*)info
//
- (void)requestCurrentSongForRadio:(Radio*)radio target:(id)target action:(SEL)selector;


@end
