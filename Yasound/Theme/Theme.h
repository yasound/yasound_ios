//
//  Theme.h
//  Yasound
//
//  Created by Loic Berthelot on 11/7/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BundleFileManager.h"


@interface Theme : BundleFileManager

+ (Theme*)theme;

+ (void)setTheme:(NSString*)themeName;


@end