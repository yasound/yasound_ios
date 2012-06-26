//
//  UserSettings.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 06/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//


#import "UserSettings.h"

@implementation UserSettings


static UserSettings* _main;


+ (UserSettings*)main
{
    if (_main == nil)
    {
        _main = [[UserSettings alloc] init];
    }
    
    return _main;
}



- (void)setObject:(id)value forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];        
}

- (id)objectForKey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

- (NSMutableArray*)mutableArrayForKey:(NSString*)key
{
    return [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:key]];
}

- (NSMutableDictionary*)mutableDictionaryForKey:(NSString*)key
{
    return [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:key]];
}



- (void)setBool:(BOOL)value forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];        
}

- (BOOL)boolForKey:(NSString*)key error:(BOOL*)error
{
    NSNumber* nb = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    if (nb == nil)
    {
        if (error != nil)
            *error = YES;
        return NO;
    }
    
    if (error != nil)
        *error = NO;
    return [nb boolValue];
}


- (void)setInteger:(NSInteger)value forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:value] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];        
}

- (NSInteger)integerForKey:(NSString*)key error:(BOOL*)error
{
    NSNumber* nb = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    if (nb == nil)
    {
        if (error != nil)
            *error = YES;
        return 0;
    }
    
    if (error != nil)
        *error = NO;
    return [nb integerValue];
}


- (void)removeObjectForKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}




- (void)dump
{
    NSLog(@"UserSettings dump :");
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    NSLog(@"-------------------------------------------");                  
}



- (void)clearSession
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYnowPlaying];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYfacebookAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYfacebookExpirationDateKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYtwitterAccountId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYtwitterOAuthUsername];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYtwitterOAuthUserId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYtwitterOAuthScreenname];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYtwitterOAuthToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYyasoundEmail];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYuserId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYuserSessionDictionary];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYuserSessionAccounts];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYuploadLegalWarning];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYuploadAddedWarning];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYuploadList];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYtutorials];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYcacheMenuDescription];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dump];
}




@end