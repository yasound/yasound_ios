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

@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;


- (id)initWithThemeRef:(NSString*)themeRef title:(NSString*)title;



@end
