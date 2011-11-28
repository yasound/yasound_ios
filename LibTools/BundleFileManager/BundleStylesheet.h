//
//  BundleStylesheet.h
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BundleFileManager;





@interface BundleFontsheet: NSObject
{
  NSString* _name;
  NSInteger _size;
  UITextAlignment _textAlignement;
  NSString* _text;
  UIColor* _textColor;
  UIColor* _backgroundColor;
  NSString* _weight;
}

@property (nonatomic, retain, readonly) NSString* name;
@property (nonatomic, readonly) NSInteger size;
@property (nonatomic, readonly) UITextAlignment textAlignement;
@property (nonatomic, retain, readonly) NSString* text;
@property (nonatomic, retain, readonly) UIColor* textColor;
@property (nonatomic, retain, readonly) UIColor* backgroundColor;
@property (nonatomic, retain, readonly) NSString* weight;

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


// init a stylesheet using a stylesheet contents (NSDictionary), for a given bundle 
- (id)initWithSheet:(NSDictionary*)sheet bundle:(NSBundle*)bundle error:(NSError **)anError;

// return the first image stored in the dictionnary. useful shortcut when a stylesheet contains a single image.
// use the dictionary property, and appropriate keys, when it's supposed to store several images.
- (UIImage*)image;


// create a button, and assign the appropriate images to the button states
// can be multi-states, if the parsed stylesheet is appropriate
- (UIButton*)makeButton;

// create a label using the parsed font styles
- (UILabel*)makeLabel;
- (void)applyToLabel:(UILabel*)label class:(NSString*)class;

// create UIImageView using the parsed stylesheet
- (UIImageView*)makeImage;

@end




