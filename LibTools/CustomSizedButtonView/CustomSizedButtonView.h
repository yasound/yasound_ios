//
//  CustomSizedButtonView.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 27/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomSizedButtonView : UIView

@property (nonatomic, retain) NSString* themeRef;
@property (nonatomic, retain) UIImageView* left;
@property (nonatomic, retain) UIImageView* right;
@property (nonatomic, retain) UIView* center;
@property (nonatomic, retain) UILabel* label;

@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;

@property (nonatomic) BOOL enabled;
@property (nonatomic) CGRect originFrame;

- (id)initWithThemeRef:(NSString*)themeRef title:(NSString*)title;
- (void)setThemeRef:(NSString*)themeRef title:(NSString*)title;


@end
