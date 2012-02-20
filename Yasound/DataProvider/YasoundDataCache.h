//
//  YasoundDataCache.h
//  Yasound
//
//  Created by loïc berthelot on 2011/02/20
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>



#define REQUEST_RADIOS_ALL @"radiosWithGenre"
#define REQUEST_RADIOS_TOP @"topRadiosWithGenre"
#define REQUEST_RADIOS_SELECTION @"selectedRadiosWithGenre"
#define REQUEST_RADIOS_NEW @"newRadiosWithGenre"
#define REQUEST_RADIOS_FRIENDS @"friendsRadiosWithGenre"
#define REQUEST_RADIOS_FAVORITES @"favoriteRadiosWithGenre"



@interface YasoundDataCachePendingOp : NSObject

@property (nonatomic, retain) NSString* REQUEST;
@property (nonatomic, retain) NSString* genre;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;
@end




@interface YasoundDataCache : NSObject
{
    NSMutableDictionary* _cache;
    
    NSMutableArray* _pending;
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
// request for an update to server if local cache is not available
//
- (void)requestRadios:(NSString*)REQUEST withGenre:(NSString*)genre target:(id)target action:(SEL)selector;


@end
