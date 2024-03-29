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
            DLog(@"Theme BundleFileManager Error : could not find bundle %@!", bundlePath);
            assert(0);
            return nil;
        }
                
        DLog(@"setTheme from bundle %@", bundlePath);
        
        NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile:bundlePath];
        NSDictionary* stylesheet = [dictionary objectForKey:@"stylesheet"];
        
        _theme = [[Theme alloc] initWithStylesheet:stylesheet];
    }
    
    return _theme;
}



- (id)initWithBundleName:(NSString*)bundleName;
{
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    
    if (bundlePath == nil)
    {
        DLog(@"Theme BundleFileManager Error : could not find bundle %@!", bundlePath);
        assert(0);
        return nil;
    }
    
    self = [super initWithPath:bundlePath];
    return self;
}




@end
