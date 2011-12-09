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

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* description;
@property (nonatomic, readonly) UIImage* icon;


+ (BOOL)setTheme:(NSString*)themeId;
+ (Theme*)theme;


- (id)initWithThemeId:(NSString*)themeId;
- (id)initWithBundleName:(NSString*)bundleName;



@end