//
//  Gift.h
//  Yasound
//
//  Created by mat on 05/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"


#define GIFT_SKU_CREATE_ACCOUNT @"create-account"
#define GIFT_SKU_FACEBOOK_CONNECT @"associate-facebook"
#define GIFT_SKU_TWITTER_CONNECT @"associate-twitter"
#define GIFT_SKU_YASOUND_CONNECT @"associate-email"
#define GIFT_SKU_INVITE_FRIEND @"SKU5"
#define GIFT_SKU_TWITTER_FOLLOW @"follow-yasound-twitter"
#define GIFT_SKU_FACEBOOK_LIKE @"SKU7"
#define GIFT_SKU_SUBSCRIBE_NEWSLETTER @"SKU8"
#define GIFT_SKU_WATCH_TUTORIAL @"watch-tutorial"
#define GIFT_SKU_CREATE_RADIO @"create-radio"
#define GIFT_SKU_UPDATE_PROGRAMMING @"SKU11"
#define GIFT_SKU_UPDATE_PROFIL @"SKU12"
#define GIFT_SKU_GET_NOTIFICATIONS @"SKU13"
#define GIFT_SKU_GET_STATS @"SKU14"



@interface Gift : Model

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* sku;
@property (retain, nonatomic) NSString* description;
@property (retain, nonatomic) NSString* action_url_ios;
@property (retain, nonatomic) NSString* completed_url;
@property (retain, nonatomic) NSString* picture_url;
@property (retain, nonatomic) NSNumber* enabled;
@property (retain, nonatomic) NSDate* last_achievement_date;
@property (retain, nonatomic) NSNumber* count;
@property (retain, nonatomic) NSNumber* max;

- (BOOL)canBeWon;
- (BOOL)hasBeenWon;
- (BOOL)hasBeenFullyWon;

- (NSString*)countProgress;
- (NSString*)formattedDate;

- (void)doAction;

- (void)dump;

@end
