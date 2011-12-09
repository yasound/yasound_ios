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
        [Theme setTheme:@"default"];
    }
    
    return _theme;
}



- (id)initWithName:(NSString*)bundleName
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



+ (BOOL)setTheme:(NSString*)themeName
{
    if (_theme != nil)
        [_theme release];

    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:themeName ofType:@"bundle"];

    if (bundlePath == nil)
    {
        NSLog(@"Theme BundleFileManager Error : could not find bundle %@!", bundlePath);
        assert(0);
        return nil;
    }

    _theme = [[Theme alloc] initWithPath:bundlePath];
}


- (UIImage*)icon
{
    NSString* tmppath = [self pathForResource:@"icon" ofType:@"png" inDirectory:nil];
    UIImage* image = [UIImage imageWithContentsOfFile:tmppath];    
    return image;
}






@end
