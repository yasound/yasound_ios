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
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"plist"];
                
        if (bundlePath == nil)
        {
            NSLog(@"Theme BundleFileManager Error : could not find bundle %@!", bundlePath);
            assert(0);
            return nil;
        }
                
        NSLog(@"setTheme from bundle %@", bundlePath);
        
        NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile:bundlePath];
        NSDictionary* stylesheet = [dictionary objectForKey:@"stylesheet"];
        
        _theme = [[Theme alloc] initWithStylesheet:stylesheet];
    }
    
    return _theme;
}



//- (id)initWithThemeId:(NSString*)themeId
//{
//    NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
//    NSArray* themes = [resources objectForKey:@"themes"];
//    for (NSDictionary* theme in themes)
//    {
//        NSString* theThemeId = [theme objectForKey:@"id"];
//        if ([theThemeId isEqualToString:themeId])
//        {
//            NSString* bundlePath = [[NSBundle mainBundle] pathForResource:[theme objectForKey:@"bundle"] ofType:@"bundle"];
//            
//            if (bundlePath == nil)
//            {
//                NSLog(@"Theme BundleFileManager Error : could not find bundle %@!", bundlePath);
//                assert(0);
//                return nil;
//            }
//            
//            self = [super initWithPath:bundlePath];
//            return self;
//        }
//    }
//    
//    return nil;
//}



//- (id)initWithBundleName:(NSString*)bundleName;
//{
//    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
//    
//    if (bundlePath == nil)
//    {
//        NSLog(@"Theme BundleFileManager Error : could not find bundle %@!", bundlePath);
//        assert(0);
//        return nil;
//    }
//    
//    self = [super initWithPath:bundlePath];
//    return self;
//}








@end
