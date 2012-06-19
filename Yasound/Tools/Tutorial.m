//
//  Tutorial.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Tutorial.h"
#import "UserSettings.h"

@implementation Tutorial


static Tutorial* _main = nil;

+ (Tutorial*)main
{
    if (_main == nil)
    {
        _main = [[Tutorial alloc] init];
    }
    
    return _main;
}


- (id)init
{
    if (self = [super init])
    {
        _fifo = [[NSMutableArray alloc] init];
        [_fifo retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_fifo release];
    [super dealloc];
}   





- (void)show:(NSString*)key everyTime:(BOOL)everyTime
{
    // get tutorials dictionary
    NSMutableDictionary* tutorials = [[UserSettings main] mutableArrayWithKey:USKEYtutorials];
    if (tutorials == nil)
    {
        tutorials = [[NSMutableDictionary alloc] init];
        [[UserSettings main] setObject:tutorials forKey:USKEYtutorials];
    }
    
    // get status flag for the requested tutorial
    NSNumber* tutorialFlag = [tutorials objectForKey:key];
    
    if (tutorialFlag == nil)
    {
        tutorialFlag = [NSNumber numberWithBool:NO];
        [tutorials setObject:tutorialFlag forKey:key];
    }
    
    BOOL flag = [tutorialFlag boolValue];
    
    // it's already been displayed!
    if (flag && !everyTime)
    {
        return;
    }

    // update the status flag to YES
    [tutorials setObject:[NSNumber numberWithBool:YES] forKey:key];
    [[UserSettings main] setObject:tutorials forKey:USKEYtutorials];

    // and display the tutorial
    NSString* titleKey = [NSString stringWithFormat:@"%@_title", key];
    NSString* messageKey = [NSString stringWithFormat:@"%@_message", key];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(titleKey, nil) message:NSLocalizedString(messageKey, nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [_fifo addObject:av];

    if (_fifo.count == 1)
        [av show];
}


#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView release];  
    
    [_fifo removeObjectAtIndex:0];
    if (_fifo.count > 0)
    {
        UIAlertView* av = [_fifo objectAtIndex:0];
        [av show];
    }
}



@end
