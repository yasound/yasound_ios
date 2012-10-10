//
//  Gift.h
//  Yasound
//
//  Created by mat on 05/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Model.h"

//12  access-statistics           Access tp statistics    View stats  HD  5   Day 1   (aucun-e)
//11  access-notifications        Access to notifications View notifications  HD  5   Day 1   (aucun-e)
//10  complete-profile            Createomplete your profile   Fill in profile HD  7   Day 1   (aucun-e)
//9   update-programming          Update programming on your radios   Je mets à jour ma programmation HD  1   Day 0   7
//8   create-radio                Create a radio  Créer une radio HD  14  Day 1   (aucun-e)
//7   follow-yasound-twitter      Follow Yasound on twitter   Follow Yasound on Twitter   HD  7   Day 1   (aucun-e)
//6   invite-friends              Invite your friends Invite friends  HD  14  Day 0   (aucun-e)
//5   associate-email             Associate your email account    Add email account   HD  7   Day 1   (aucun-e)
//4   associate-twitter           Associate your twitter account  Add twitter account HD  7   Day 1   (aucun-e)
//3   associate-facebook          Associate your facebook account Add facebook account    HD  7   Day 1   (aucun-e)
//2   create-account              Create an account   Create account  HD  14  Day 1   (aucun-e)
//1   watch-tutorial

#define GIFT_SKU_CREATE_ACCOUNT @"create-account"
#define GIFT_SKU_FACEBOOK_CONNECT @"associate-facebook"
#define GIFT_SKU_TWITTER_CONNECT @"associate-twitter"
#define GIFT_SKU_YASOUND_CONNECT @"associate-email"
#define GIFT_SKU_INVITE_FRIEND @"invite-friends"
#define GIFT_SKU_TWITTER_FOLLOW @"follow-yasound-twitter"
#define GIFT_SKU_FACEBOOK_LIKE @"facebook-like-yasound"
#define GIFT_SKU_SUBSCRIBE_NEWSLETTER @"subscribe-newsletter"
#define GIFT_SKU_WATCH_TUTORIAL @"watch-tutorial"
#define GIFT_SKU_CREATE_RADIO @"create-radio"
#define GIFT_SKU_UPDATE_PROGRAMMING @"update-programming"
#define GIFT_SKU_UPDATE_PROFIL @"complete-profile"
#define GIFT_SKU_GET_NOTIFICATIONS @"access-notifications"
#define GIFT_SKU_GET_STATS @"access-statistics"



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
