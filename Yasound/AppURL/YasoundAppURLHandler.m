//
//  YasoundAppURLHandler.m
//  Yasound
//
//  Created by mat on 06/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "YasoundAppURLHandler.h"
#import "RootViewController.h"
#import "YasoundSessionManager.h"
#import "AudioStreamManager.h"

@interface YasoundAppURLHandler (internal)

- (BOOL)handleNavigationURL:(NSURL*)url;
- (BOOL)handleInAppWebURL:(NSURL*)yasoundUrl;

- (BOOL)gotoSelection;
- (BOOL)gotoFavorites;
- (BOOL)gotoMyRadios;
- (BOOL)gotoLogin;
- (BOOL)gotoTwitterAssociation;
- (BOOL)gotoFacebookAssociation;
- (BOOL)gotoCurrentRadio;
- (BOOL)gotoCreateRadio;
- (BOOL)gotoRadioProgramming;
- (BOOL)gotoRadioStats;
- (BOOL)gotoProfile;
- (BOOL)gotoInviteFacebookFriends;
- (BOOL)gotoInviteTwitterFriends;
- (BOOL)gotoInviteContacts;

- (void)postNotification:(NSString*)notifName;

@end


@implementation YasoundAppURLHandler


static YasoundAppURLHandler* _main = nil;

+ (YasoundAppURLHandler*) main
{
    if (_main == nil)
    {
        _main = [[YasoundAppURLHandler alloc] init];
    }
    
    return _main;
}

- (BOOL)handleOpenURL:(NSURL*)url
{
    if (![url.scheme isEqualToString:@"yasound"])
        return NO;
    
    DLog(@"handle 'yasound://' url %@", url);
    
    if ([url.host isEqualToString:@"navigation"])
    {
        return [self handleNavigationURL:url];
    }
    
    
    return [self handleInAppWebURL:url];
}

- (BOOL)handleNavigationURL:(NSURL*)url
{
    NSArray* components = url.pathComponents; // the first component is the first slash
    NSUInteger componentCount = components.count;
    if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"selection"]) // '/' + 'selection'
    {
        BOOL res = [self gotoSelection];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"favorites"]) // '/' + 'favorites'
    {
        BOOL res = [self gotoFavorites];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"my_radios"]) // '/' + 'my_radios'
    {
        BOOL res = [self gotoMyRadios];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"login"]) // '/' + 'login'
    {
        BOOL res = [self gotoLogin];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"current_radio"]) // '/' + 'current_radio'
    {
        BOOL res = [self gotoCurrentRadio];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"create_radio"]) // '/' + 'create_radio'
    {
        BOOL res = [self gotoCreateRadio];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"programming"]) // '/' + 'current_radio'
    {
        BOOL res = [self gotoRadioProgramming];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"stats"]) // '/' + 'stats'
    {
        BOOL res = [self gotoRadioStats];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"twitter_association"]) // '/' + 'twitter_association'
    {
        BOOL res = [self gotoTwitterAssociation];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"facebook_association"]) // '/' + 'facebook_association'
    {
        BOOL res = [self gotoFacebookAssociation];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"profile"]) // '/' + 'profile'
    {
        BOOL res = [self gotoProfile];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"invite_ios_contacts"]) // '/' + 'invite_ios_contacts'
    {
        BOOL res = [self gotoInviteContacts];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"invite_facebook_friends"]) // '/' + 'invite_facebook_friends'
    {
        BOOL res = [self gotoInviteFacebookFriends];
        if (res)
            return YES;
    }
    else if (componentCount == 2 && [[components objectAtIndex:1] isEqualToString:@"invite_twitter_friends"]) // '/' + 'invite_twitter_friends'
    {
        BOOL res = [self gotoInviteTwitterFriends];
        if (res)
            return YES;
    }
    
    
    
    DLog(@"cannot handle yasound navigation url %@", url);
    return NO;
}

- (BOOL)gotoSelection
{
    [self postNotification:NOTIF_GOTO_SELECTION];
    return YES;
}

- (BOOL)gotoFavorites
{
    if (![YasoundSessionManager main].registered)
        return NO;
    [self postNotification:NOTIF_GOTO_FAVORITES];
    return YES;
}

- (BOOL)gotoMyRadios
{
    if (![YasoundSessionManager main].registered)
        return NO;
    [self postNotification:NOTIF_GOTO_MYRADIOS];
    return YES;
}

- (BOOL)gotoLogin
{
    if ([YasoundSessionManager main].registered)
        return NO;
    [self postNotification:NOTIF_PUSH_LOGIN];
    return YES;
}

- (BOOL)gotoTwitterAssociation
{
    if (![YasoundSessionManager main].registered)
        return [self gotoLogin];
    [self postNotification:NOTIF_GOTO_TWITTER_ASSOCIATION];
    return YES;
}

- (BOOL)gotoFacebookAssociation
{
    if (![YasoundSessionManager main].registered)
        return [self gotoLogin];
    [self postNotification:NOTIF_GOTO_FACEBOOK_ASSOCIATION];
    return YES;
}

- (BOOL)gotoCurrentRadio
{
    if ([AudioStreamManager main].currentRadio)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO object:[AudioStreamManager main].currentRadio];
        return YES;
    }
    return [self gotoSelection];
}

- (BOOL)gotoCreateRadio
{
    if (![YasoundSessionManager main].registered)
        return [self gotoLogin];
    [self postNotification:NOTIF_GOTO_CREATE_RADIO];
    return YES;
}

- (BOOL)gotoRadioProgramming
{
    if (![YasoundSessionManager main].registered)
        return [self gotoLogin];
    
    [[YasoundDataProvider main] radiosForUser:[YasoundDataProvider main].user withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"gotoRadioProgramming: radios for user error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"gotoRadioProgramming: radios for user error: response status %d", status);
            return;
        }
        Container* radioContainer = [response jsonToContainer:[Radio class]];
        if (!radioContainer || !radioContainer.objects)
        {
            DLog(@"gotoRadioProgramming: radios for user error: cannot parse response %@", response);
            return;
        }
        
        NSArray* radios = radioContainer.objects;
        if (radios.count > 0)
        {
            Radio* radio = [radios objectAtIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO_PROGRAMMING object:radio];
        }
    }];
    
    return YES;
}

- (BOOL)gotoRadioStats
{
    if (![YasoundSessionManager main].registered)
        return [self gotoLogin];
    
    [[YasoundDataProvider main] radiosForUser:[YasoundDataProvider main].user withCompletionBlock:^(int status, NSString* response, NSError* error){
        if (error)
        {
            DLog(@"gotoRadioStats: radios for user error: %d - %@", error.code, error. domain);
            return;
        }
        if (status != 200)
        {
            DLog(@"gotoRadioStats: radios for user error: response status %d", status);
            return;
        }
        Container* radioContainer = [response jsonToContainer:[Radio class]];
        if (!radioContainer || !radioContainer.objects)
        {
            DLog(@"gotoRadioStats: radios for user error: cannot parse response %@", response);
            return;
        }
        
        NSArray* radios = radioContainer.objects;
        if (radios.count > 0)
        {
            Radio* radio = [radios objectAtIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_RADIO_STATS object:radio];
        }
    }];
    
    return YES;
}


- (BOOL)gotoProfile
{
    if (![YasoundSessionManager main].registered)
        return [self gotoLogin];
    [self postNotification:NOTIF_GOTO_EDIT_PROFIL];
    return YES;
}

- (BOOL)gotoInviteFacebookFriends
{
    if (![YasoundSessionManager main].registered)
        return [self gotoLogin];
    if (![[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_FACEBOOK])
        return [self gotoFacebookAssociation];
    
    [self postNotification:NOTIF_INVITE_FACEBOOK];
    return YES;
}

- (BOOL)gotoInviteTwitterFriends
{
    if (![YasoundSessionManager main].registered)
        return [self gotoLogin];
    if (![[YasoundSessionManager main] isAccountAssociated:LOGIN_TYPE_TWITTER])
        return [self gotoTwitterAssociation];
    
    [self postNotification:NOTIF_INVITE_TWITTER];
    return YES;
}

- (BOOL)gotoInviteContacts
{
    if (![YasoundSessionManager main].registered)
        return [self gotoLogin];
    
    [self postNotification:NOTIF_INVITE_CONTACTS];
    return YES;
}




- (void)postNotification:(NSString*)notifName
{
    NSNumber* animated = [NSNumber numberWithBool:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:animated];
}




- (BOOL)handleInAppWebURL:(NSURL*)yasoundUrl
{
    NSString* yasoundUrlStr = yasoundUrl.absoluteString;
    NSString* httpUrlStr = [yasoundUrlStr stringByReplacingOccurrencesOfString:@"yasound://" withString:@"http://"];
    NSURL* httpUrl = [NSURL URLWithString:httpUrlStr];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GOTO_WEB_PAGE_VIEW object:httpUrl];
    [httpUrl release];
    return YES;
}

@end
