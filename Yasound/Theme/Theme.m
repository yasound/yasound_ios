//
//  Theme.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "Theme.h"


@implementation Theme

@synthesize name;
@synthesize description;
@synthesize icon;


static Theme* _theme = nil;

+ (Theme*)theme
{
    if (_theme == nil)
    {
        [Theme setTheme:@"theme_default"];
    }
    
    return _theme;
}



- (id)initWithThemeId:(NSString*)themeId
{
    NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
    NSArray* themes = [resources objectForKey:@"themes"];
    for (NSDictionary* theme in themes)
    {
        NSString* theThemeId = [theme objectForKey:@"id"];
        if ([theThemeId isEqualToString:themeId])
        {
            NSString* bundlePath = [[NSBundle mainBundle] pathForResource:[theme objectForKey:@"bundle"] ofType:@"bundle"];
            
            if (bundlePath == nil)
            {
                NSLog(@"Theme BundleFileManager Error : could not find bundle %@!", bundlePath);
                assert(0);
                return nil;
            }
            
            self = [super initWithPath:bundlePath];
            return self;
        }
    }
    
    return nil;
}



- (id)initWithBundleName:(NSString*)bundleName;
{
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    
    if (bundlePath == nil)
    {
        NSLog(@"Theme BundleFileManager Error : could not find bundle %@!", bundlePath);
        assert(0);
        return nil;
    }
    
    self = [super initWithPath:bundlePath];
    return self;
}



+ (BOOL)setTheme:(NSString*)themeId
{
    if (_theme != nil)
        [_theme release];
    
    
    NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
    NSArray* themes = [resources objectForKey:@"themes"];
    for (NSDictionary* theme in themes)
    {
        NSString* theThemeId = [theme objectForKey:@"id"];
        if ([theThemeId isEqualToString:themeId])
        {
            NSString* bundlePath = [[NSBundle mainBundle] pathForResource:[theme objectForKey:@"bundle"] ofType:@"bundle"];
            
            if (bundlePath == nil)
            {
                NSLog(@"Theme BundleFileManager Error : could not find bundle %@!", bundlePath);
                assert(0);
                return nil;
            }
            
            _theme = [[Theme alloc] initWithPath:bundlePath];
            return YES;
        }
    }
    
    return NO;
}


- (UIImage*)icon
{
    NSString* tmppath = [self pathForResource:@"icon" ofType:@"png" inDirectory:nil];
    UIImage* image = [UIImage imageWithContentsOfFile:tmppath];    
    return image;
}

- (NSString*)name
{
    NSString* themeId = [self objectForInfoDictionaryKey:@"id"];
    NSString* name = NSLocalizedString(themeId, nil);
    return name;
}

- (NSString*)description
{
    NSString* themeId = [self objectForInfoDictionaryKey:@"id"];
    NSString* themeDescriptionKey = [themeId stringByAppendingString:@"_description"];
    NSString* description = NSLocalizedString(themeDescriptionKey, nil);
    return description;
}






@end
