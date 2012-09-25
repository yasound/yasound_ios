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
        _main.selectedGenres = [NSMutableDictionary dictionary];
    }
    
    return _main;
}



- (void)setObject:(id)value forKey:(NSString*)key
{
    if (value == nil)
    {
        DLog(@"setObject ERROR : value is nil for Key '%@'", key);
        assert(0);
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];        
}

- (id)objectForKey:(NSString*)key
{
//    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
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

    //LBDEBUG
    if (![nb isKindOfClass:[NSNumber class]])
    {
        DLog(@"UserSettings integerForKey error : NSNumber* nb is class : %@", [nb class]);
        assert(0);
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
    DLog(@"UserSettings dump :");
    DLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    DLog(@"-------------------------------------------");                  
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USKEYuserWantsHd];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dump];
}



- (NSString*)selectedGenreForUrl:(NSURL*)url {
 
    if (url == nil)
        return nil;

    NSString* genre = [self.selectedGenres objectForKey:[url absoluteString]];
    return genre;
}

- (void)setGenre:(NSString*)genre forUrl:(NSURL*)url {
    
    if (url == nil)
        return;
    
    if ([genre isEqualToString:@"style_all"]) {
        [self.selectedGenres removeObjectForKey:[url absoluteString]];
        return;
    }
    
    [self.selectedGenres setObject:genre forKey:[url absoluteString]];
}



@end
