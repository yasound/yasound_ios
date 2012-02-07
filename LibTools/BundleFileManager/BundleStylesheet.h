//
//  BundleStylesheet.h
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BundleFileManager;





@interface BundleFontsheet: NSObject


@property (nonatomic, retain, readonly) NSString* class;

@property (nonatomic, retain, readonly) NSString* name;
@property (nonatomic, readonly) BOOL nameIsSet;

@property (nonatomic, readonly) NSInteger size;
@property (nonatomic, readonly) BOOL sizeIsSet;

@property (nonatomic, readonly) UITextAlignment textAlignement;
@property (nonatomic, readonly) BOOL textAlignmentIsSet;

@property (nonatomic, retain, readonly) NSString* text;
// text property is only for initialization, not for dynamic "apply"

@property (nonatomic, retain, readonly) UIColor* textColor;
@property (nonatomic, readonly) BOOL textColorIsSet;

@property (nonatomic, retain, readonly) UIColor* backgroundColor;
@property (nonatomic, readonly) BOOL backgroundColorIsSet;

@property (nonatomic, retain, readonly) NSString* weight;
@property (nonatomic, readonly) BOOL weightIsSet;

@property (nonatomic, readonly) CGSize shadowOffset;
@property (nonatomic, readonly) NSInteger shadowRadius;
@property (nonatomic, readonly) CGFloat shadowOpacity;
@property (nonatomic, retain, readonly) UIColor* shadowColor;
@property (nonatomic, readonly) BOOL shadowIsSet;


- (id)initWithSheet:(NSDictionary*)sheet forClass:(NSString*)class defaultFontsheet:(BundleFontsheet*)defaultFontsheet bundle:(NSBundle*)bundle error:(NSError **)anError;


@end





@interface BundleStylesheet: NSObject
{
  NSMutableDictionary* _images;
  CGRect _frame;
  UIColor* _color;
 
  NSMutableDictionary* _fontsheets; // dictionnary of  BundleFontsheet*

  NSDictionary* _customProperties;
}


@property (nonatomic, retain, readonly) NSMutableDictionary* images;
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) UIColor* color;
@property (nonatomic, retain, readonly) NSDictionary* fontsheets; //  dictionnary of  BundleFontsheet*
@property (nonatomic, retain, readonly) NSDictionary* customProperties;


+ (BOOL)isRetina;

// init a stylesheet using a stylesheet contents (NSDictionary), for a given bundle 
- (id)initWithSheet:(NSDictionary*)sheet bundle:(NSBundle*)bundle error:(NSError **)anError;

// return the first image stored in the dictionnary. useful shortcut when a stylesheet contains a single image.
// use the dictionary property, and appropriate keys, when it's supposed to store several images.
- (UIImage*)image;


// create a button, and assign the appropriate images to the button states
// can be multi-states, if the parsed stylesheet is appropriate
- (UIButton*)makeButton;

// create a fond, using the parsed font style
- (UIFont*)makeFont;

// create a label using the parsed font styles
- (UILabel*)makeLabel;

// apply a font style to a label.
// 'class' is the font style class. For instance "default", or another class that could have been defined in the stylesheet : class 'selected' for the definition "font.selected"
// if 'class' is nil, the 'default' style is used
// returns NO if the class could not been found in the stylesheet
- (BOOL)applyToLabel:(UILabel*)label class:(NSString*)class;

// create UIImageView using the parsed stylesheet
- (UIImageView*)makeImage;

@end




