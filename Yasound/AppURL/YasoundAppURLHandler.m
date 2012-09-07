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

@interface YasoundAppURLHandler (internal)

- (BOOL)handleNavigationURL:(NSURL*)url;
- (BOOL)gotoSelection;
- (BOOL)gotoFavorites;
- (BOOL)gotoMyRadios;
- (BOOL)gotoLogin;
- (BOOL)gotoTwitterAssociation;
- (BOOL)gotoFacebookAssociation;

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
    
    DLog(@"cannot handle yasound url %@", url);
    return NO;
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
    [self postNotification:NOTIF_GOTO_LOGIN];
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



- (void)postNotification:(NSString*)notifName
{
    NSNumber* animated = [NSNumber numberWithBool:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:animated];
}

@end
