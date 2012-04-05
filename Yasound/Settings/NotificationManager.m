//
//  NotificationManager.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 05/04/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "NotificationManager.h"

@implementation NotificationManager

@synthesize notifications;





static NotificationManager* _main = nil;

+ (NotificationManager*)main
{
    if (_main == nil)
    {
        _main = [[NotificationManager alloc] init];
    }
    
    return _main;
}



- (id)init
{
    if (self = [super init])
    {
        NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
        NSDictionary* input = [resources objectForKey:@"notifications"];

        self.notifications = [[NSUserDefaults standardUserDefaults] objectForKey:@"Notifications"];
        if (self.notifications == nil)
        {
            self.notifications = [[NSMutableDictionary alloc] init];
        }

        NSArray* identifiers = [input allKeys];
        for (NSString* identifier in identifiers)
        {
            NSNumber* value = [self.notifications objectForKey:identifier];
            if (value == nil)
            {
                NSNumber* defaultValue = [input objectForKey:identifier]; 
                [self.notifications setObject:defaultValue forKey:identifier];
            }
        }
        
        [self save];
    }
    
    return self;

}





- (BOOL)get:(NSString*)notifIdentifier
{
    return [[self.notifications objectForKey:notifIdentifier] boolValue];
}



- (void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:self.notifications forKey:@"Notifications"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
