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

+ (BOOL)setTheme:(NSString*)themeName;
+ (Theme*)theme;

- (id)initWithName:(NSString*)bundleName;

- (UIImage*)icon;


@end