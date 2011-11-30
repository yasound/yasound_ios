//
//  Theme.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Theme.h"


@implementation Theme


static Theme* _theme = nil;

+ (Theme*)theme
{
    if (_theme == nil)
    {
        _theme = [[Theme alloc] init];

        NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
        
        // stylesheet
        _theme.stylesheet = [resources objectForKey:@"stylesheet"];
        if (_main.stylesheet == nil)
            NSLog(@"BundleFileManager Warning : could not find any stylesheet");
        
        
        NSString* bundlePath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GameBundlePath"]; 
        gameBundlePath = [[NSBundle mainBundle] pathForResource:gameBundlePath ofType:@"bundle"];
        
        if (gameBundlePath == nil)
        {
            NSLog(@"BundleFileManager Error : could not find the key 'GameBundlePath' from the info plist file!");
            assert(1);
            return nil;
        }
        
        _gameBundle = [[BundleFileManager alloc] initWithPath:gameBundlePath];
        
        // stylesheet
        _gameBundle.stylesheet = [_gameBundle objectForInfoDictionaryKey:@"stylesheet"];
        if (_gameBundle.stylesheet == nil)
            NSLog(@"GFM gameBundle Warning : could not find any stylesheet");
        
        
    }
    
    return nil;
}



+ (void)setTheme:(NSString*)themeName
{
    if (_theme != nil)
    {
        
    }
}






@end
