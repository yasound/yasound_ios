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
    if (_main)
    {
        _main = [[UserSettings alloc] init];
    }
    
    return _main;
}



- (void)setValue:(id)value forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];        
}

- (id)valueForKey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
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


- (void)removeObjectKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}







@end
