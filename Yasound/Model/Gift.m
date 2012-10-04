//
//  Gift.m
//  Yasound
//
//  Created by mat on 05/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "Gift.h"
#import "YasoundDataProvider.h"
#import "RootViewController.h"
#import <MediaPlayer/MediaPlayer.h>



@implementation Gift

- (BOOL)canBeWon
{
    if (![self.enabled boolValue])
        return NO;
    
    BOOL fullyWon = [self hasBeenFullyWon];
    return !fullyWon;
}

- (BOOL)hasBeenWon
{
    BOOL won = [self.count integerValue] > 0;
    return won;
}

- (BOOL)hasBeenFullyWon
{
    BOOL fullyWon = [self.count integerValue] >= [self.max integerValue];
    return fullyWon;
}

- (NSString*)countProgress
{
    NSString* s = [NSString stringWithFormat:@"%d/%d", [self.count integerValue], [self.max integerValue]];
    return s;
}

- (NSString*)formattedDate
{
    // date formatting
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    NSDate* now = [NSDate date];
    NSDateComponents* todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:now];
    NSDateComponents* refComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self.last_achievement_date];
    
    if (todayComponents.year == refComponents.year && todayComponents.month == refComponents.month && todayComponents.day == refComponents.day)
    {
        // today: show time
        [dateFormat setDateFormat:@"HH:mm"];
    }
    else
    {
        // not today: show date
        [dateFormat setDateFormat:@"dd/MM"];
    }
    
    NSString* dateString = [dateFormat stringFromDate:self.last_achievement_date];
    return dateString;
}




- (void)dump {

    NSString* str = [NSString stringWithFormat:@"Gift '%@'\n", self.name];
    
    str = [str stringByAppendingString:[NSString stringWithFormat:@"sku '%@'\n", self.sku]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"description '%@'\n", self.description]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"action_url_ios '%@'\n", self.action_url_ios]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"completed_url '%@'\n", self.completed_url]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"picture_url '%@'\n", self.picture_url]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"enabled '%@'\n", self.enabled]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"last_achievement_date '%@'\n", self.last_achievement_date]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"count '%@'\n", self.count]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"max '%@'\n", self.max]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"canBeWon '%d'\n", [self canBeWon]]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"hasBeenWon '%d'\n", [self hasBeenWon]]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"hasBeenFullyWon '%d'\n", [self hasBeenFullyWon]]];
    
    DLog(@"%@", str);
}





- (void)doAction
{
    if (!self.action_url_ios)
        return;

    [self dump];
    
    if ([self.sku isEqualToString:GIFT_SKU_CREATE_ACCOUNT]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PUSH_LOGIN object:nil];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_FACEBOOK_CONNECT]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_FACEBOOK_ASSOCIATION object:nil];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_TWITTER_CONNECT]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_TWITTER_ASSOCIATION object:nil];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_YASOUND_CONNECT]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_YASOUND_ASSOCIATION object:nil];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_INVITE_FRIEND]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_FRIENDS object:nil];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_TWITTER_FOLLOW]) {
        
    }
    else if ([self.sku isEqualToString:GIFT_SKU_FACEBOOK_LIKE]) {
        
    }
    else if ([self.sku isEqualToString:GIFT_SKU_SUBSCRIBE_NEWSLETTER]) {
        
    }
    else if ([self.sku isEqualToString:GIFT_SKU_WATCH_TUTORIAL]) {
        
        NSURL* url = [NSURL URLWithString:self.action_url_ios];
        MPMoviePlayerViewController* playerv = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [self presentMoviePlayerViewControllerAnimated:playerv];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_CREATE_RADIO]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MYRADIOS object:nil];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_UPDATE_PROGRAMMING]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MYRADIOS object:nil];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_UPDATE_PROFIL]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_EDIT_PROFIL object:nil];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_GET_NOTIFICATIONS]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_NOTIFICATIONS object:nil];
    }
    else if ([self.sku isEqualToString:GIFT_SKU_GET_STATS]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_MYRADIOS object:nil];
    }


//    NSURL* url = [NSURL URLWithString:self.action_url_ios];
//    [[UIApplication sharedApplication] openURL:url];
    
//    if (self.completed_url)
//        [[YasoundDataProvider main] sendGetRequestWithURL:self.completed_url];
}

@end
