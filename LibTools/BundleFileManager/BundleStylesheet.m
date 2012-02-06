//
//  BundleStylesheet.m
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import "BundleStylesheet.h"
#import "BundleFileManager.h"
#import <QuartzCore/QuartzCore.h>

//..................................................................................
//  
//  BundleFontsheet
//

#pragma mark - BundleFontsheet


@implementation BundleFontsheet

@synthesize class = _class;
@synthesize name = _name;
@synthesize nameIsSet = _nameIsSet;
@synthesize size = _size;
@synthesize sizeIsSet = _sizeIsSet;
@synthesize textAlignement = _textAlignement;
@synthesize textAlignmentIsSet = _textAlignmentIsSet;
@synthesize text = _text;
@synthesize textColor = _textColor;
@synthesize textColorIsSet = _textColorIsSet;
@synthesize backgroundColor = _backgroundColor;
@synthesize backgroundColorIsSet = _backgroundColorIsSet;
@synthesize weight = _weight;
@synthesize weightIsSet = _weightIsSet;

@synthesize shadowOffset = _shadowOffset;
@synthesize shadowRadius = _shadowRadius;
@synthesize shadowOpacity = _shadowOpacity;
@synthesize shadowColor = _shadowColor;
@synthesize shadowIsSet = _shadowIsSet;



+ (UITextAlignment)alignementFromString:(NSString*)str
{
  if ([str isEqualToString:@"left"])
    return UITextAlignmentLeft;

  if ([str isEqualToString:@"right"])
    return UITextAlignmentRight;

  if ([str isEqualToString:@"center"])
    return UITextAlignmentCenter;

  // default
  return UITextAlignmentLeft;
}






- (id)initWithSheet:(NSDictionary*)sheet forClass:(NSString*)class defaultFontsheet:(BundleFontsheet*)defaultFontsheet bundle:(NSBundle*)bundle error:(NSError **)anError
{
  self = [super init];
  

  _nameIsSet = NO;
  _sizeIsSet = NO;
  _textAlignmentIsSet = NO;
  _textColorIsSet = NO;
  _backgroundColorIsSet = NO;
  _weightIsSet = NO;
    _shadowIsSet = NO;


  // default init
  if (([class isEqualToString:@"default"]) || (defaultFontsheet == nil))
  {
    _size = 12;
    _textAlignement = UITextAlignmentLeft;
    _text = [[NSString alloc] initWithString:@""];
    _textColor = [UIColor blackColor];
    _backgroundColor = [UIColor clearColor];
    _weight = [[NSString alloc] initWithString:@"normal"];
  }
  else
  {
    _size = defaultFontsheet.size;
    _textAlignement = defaultFontsheet.textAlignement;
    _textColor = defaultFontsheet.textColor;
    _backgroundColor = defaultFontsheet.backgroundColor;
    _weight = [[NSString alloc] initWithString:defaultFontsheet.weight];
  }

  NSString* fontName = [sheet valueForKey:@"name"];
  if (fontName != nil)
  {
    _name = [[NSString alloc] initWithString:fontName];
    _nameIsSet = YES;
  }

  NSNumber* fontSize = [sheet valueForKey:@"size"];
  if (fontSize != nil)
  {
    _size = [fontSize integerValue];
    _sizeIsSet = YES;
  }
    
  NSString* fontText = [sheet valueForKey:@"text"];
  if (fontText != nil)
  {
    _text = [[NSString alloc] initWithString:fontText];
  }
  
  NSString* textColor = [sheet valueForKey:@"textColor"];
  if (textColor != nil)
  {
    _textColor = [BundleStylesheet colorFromString:[textColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    _textColorIsSet = YES;
  }

  NSString* backgroundColor = [sheet valueForKey:@"backgroundColor"];
  if (backgroundColor != nil)
  {
    _backgroundColor = [BundleStylesheet colorFromString:backgroundColor];
    _backgroundColorIsSet = YES;
  }
  
  NSString* fontWeight = [sheet valueForKey:@"weight"];
  if (fontWeight != nil)
  {
    _weight = fontWeight;
    _weightIsSet = YES;
  }
  
  NSString* alignement = [sheet valueForKey:@"textAlignement"];
  if (alignement != nil)
  {
    _textAlignement = [BundleFontsheet alignementFromString:alignement];
    _textAlignmentIsSet = YES;
  }
    
    NSString* shadowOffset = [sheet valueForKey:@"shadowOffset"];
    if (shadowOffset != nil)
    {
        _shadowIsSet = YES;

        NSArray* array =[shadowOffset componentsSeparatedByString:@", "];
        _shadowOffset.width = 0;
        _shadowOffset.height = 0;
        if (array.count > 0)
        {
            NSString* tmp = [array objectAtIndex:0];
            _shadowOffset.width = [tmp floatValue];
        }
        if (array.count > 1)
        {
            NSString* tmp = [array objectAtIndex:1];
            _shadowOffset.height = [tmp floatValue];
        }

        _shadowRadius = 1;
        NSNumber* shadowRadius = [sheet valueForKey:@"shadowRadius"];
        if (shadowRadius != nil )
            _shadowRadius = [shadowRadius integerValue];
        
        _shadowOpacity = 0.5;
        NSNumber* shadowOpacity = [sheet valueForKey:@"shadowOpacity"];
        if (shadowOpacity != nil )
            _shadowOpacity = [shadowOpacity floatValue];
        
        _shadowColor = [UIColor blackColor];
        NSString* shadowColor = [sheet valueForKey:@"shadowColor"];
        if (shadowColor != nil)
        {
            _shadowColor = [BundleStylesheet colorFromString:[shadowColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }

    }


  return self;
}

@end


    
















//..................................................................................
//  
//  BundleStylesheet
//

#pragma mark - BundleStylesheet
    

@implementation BundleStylesheet

@synthesize images = _images;
@synthesize frame = _frame;
@synthesize color = _color;
@synthesize fontsheets = _fontsheets;
@synthesize customProperties = _customProperties;



static NSMutableDictionary* gFonts = nil;
static NSNumber* _isRetina = nil;



- (id)init
{
  self = [super init];
  
  if (gFonts == nil)
    gFonts = [[NSMutableDictionary alloc] init];
    
    if (_isRetina == nil)
    {
        BOOL isRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2);
        isRetina &= (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
        _isRetina = [NSNumber numberWithBool:isRetina];
    }
  
  _images = [[NSMutableDictionary alloc] init];
  _frame = CGRectMake(0, 0, 0, 0);
  _fontsheets = [[NSMutableDictionary alloc] init];
  _customProperties = nil;

  
  return self;
}






+ (UIColor*)colorFromRgbString:(NSString*)str
{
  NSInteger length = [str length];
  
  // find '('
  NSRange range = NSMakeRange(0, length);
  NSRange begin = [str rangeOfString:@"(" options:NSLiteralSearch range:range];
  if (begin.location == NSNotFound)
    return [UIColor blackColor];
  
  // find ','
  begin.location += begin.length;
  range = NSMakeRange(begin.location, length - begin.location);
  NSRange end = [str rangeOfString:@"," options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
    return [UIColor blackColor];
  
  // extract r
  NSString* rstr = [str substringWithRange:NSMakeRange(begin.location, end.location - begin.location)];
  
  // find ','
  begin.location = end.location + end.length;
  range = NSMakeRange(begin.location, length - begin.location);
  end = [str rangeOfString:@"," options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
    return [UIColor blackColor];
  
  // extract g
  NSString* gstr = [str substringWithRange:NSMakeRange(begin.location, end.location - begin.location)];
  
  BOOL isAlpha = YES;
  NSString* astr = nil;
  
  // find ','
  begin.location = end.location + end.length;
  range = NSMakeRange(begin.location, length - begin.location);
  end = [str rangeOfString:@"," options:NSLiteralSearch range:range];
  if (end.location == NSNotFound)
  {
    isAlpha = NO;
    
    // find ')'
    end = [str rangeOfString:@")" options:NSLiteralSearch range:range];
    if (end.location == NSNotFound)
      return [UIColor blackColor];
  }
  
  // extract b
  NSString* bstr = [str substringWithRange:NSMakeRange(begin.location, end.location - begin.location)];
  
  if (isAlpha)
  {
    // find ')'
    begin.location = end.location + end.length;
    range = NSMakeRange(begin.location, length - begin.location);
    end = [str rangeOfString:@")" options:NSLiteralSearch range:range];
    if (end.location == NSNotFound)
      return [UIColor blackColor];
    
    // extract a
    astr = [str substringWithRange:NSMakeRange(begin.location, end.location - begin.location)];
  }
  
  // compose color
  CGFloat r = [rstr floatValue];
  CGFloat g = [gstr floatValue];
  CGFloat b = [bstr floatValue];
  CGFloat a = 255.f;
  if (astr != nil)
    a = [astr floatValue];
  
  return [[UIColor alloc] initWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a/255.f];
}





+ (UIColor*)colorFromString:(NSString*)str
{
  if ([[str substringWithRange:NSMakeRange(0, 3)] caseInsensitiveCompare:@"rgb"] == NSOrderedSame )
    return [BundleStylesheet colorFromRgbString:str];
  
  if ([str isEqualToString:@"black"])
    return [UIColor blackColor];
  
  if ([str isEqualToString:@"white"])
    return [UIColor whiteColor];
  
  if ([str isEqualToString:@"clear"])
    return [UIColor clearColor];
  
  if ([str isEqualToString:@"red"])
    return [UIColor redColor];
  
  if ([str isEqualToString:@"blue"])
    return [UIColor blueColor];
  
  if ([str isEqualToString:@"green"])
    return [UIColor greenColor];
  
  if ([str isEqualToString:@"darkGray"])
    return [UIColor darkGrayColor];
  
  if ([str isEqualToString:@"lightGray"])
    return [UIColor lightGrayColor];
  
  if ([str isEqualToString:@"gray"])
    return [UIColor grayColor];
  
  if ([str isEqualToString:@"cyan"])
    return [UIColor cyanColor];
  
  if ([str isEqualToString:@"yellow"])
    return [UIColor yellowColor];
  
  if ([str isEqualToString:@"magenta"])
    return [UIColor magentaColor];
  
  if ([str isEqualToString:@"orange"])
    return [UIColor orangeColor];
  
  if ([str isEqualToString:@"purple"])
    return [UIColor purpleColor];
  
  if ([str isEqualToString:@"brown"])
    return [UIColor brownColor];
  
  // default color
  return [UIColor blackColor];
}









- (UIImage*)image
{
  return [self.images valueForKey:@"up"];
}



//....................................................................................
//
// init a stylesheet using a stylesheet contents (NSDictionary), for a given bundle 
//
- (id)initWithSheet:(NSDictionary*)sheet bundle:(NSBundle*)bundle error:(NSError **)anError
{
  self = [self init];
  
  // store the sheet, to let the use access its custom properties
  _customProperties = [[NSDictionary alloc] initWithDictionary:sheet];
    
  // get position x and y
  NSInteger x = [[sheet valueForKey:@"x"] integerValue];
  NSInteger y = [[sheet valueForKey:@"y"] integerValue];
  _frame = CGRectMake(x, y, 0, 0);
  
  // optional color parameter
  NSString* colorStr = [sheet valueForKey:@"color"];
  _color = [BundleStylesheet colorFromString:colorStr];
  
  // multi-states or single state?
  NSArray* states = [sheet valueForKey:@"states"];
  id ref = nil;
  if (states != nil)
    ref = [self parseMultiStates:sheet forStates:states bundle:bundle error:anError];
  else
    ref = [self parseSingleState:sheet bundle:bundle error:anError];
  
  if (ref == nil)
    return nil;
  
  // font parsing
  
  // default font sheet
  BundleFontsheet* defaultFontsheet = nil;
  NSDictionary* fontDico = [sheet valueForKey:@"font"];
  if (fontDico)
  {
    defaultFontsheet = [[BundleFontsheet alloc] initWithSheet:fontDico forClass:@"default" defaultFontsheet:nil bundle:bundle error:anError];
    [_fontsheets setObject:defaultFontsheet forKey:@"default"];
  }

  // other font sheets:
  // can define several font sheets. for instance, "font" (<=> considered as "font.default"), "font.selected", "font.otherclass", ...
  NSArray* keys = [sheet allKeys];
  for (NSString* key in keys)
  {
    NSInteger length = [key length];
    if (length < 4)
      continue;
    
    if ([key isEqualToString:@"font"])
      continue;
    
    NSString* keyPrefix = [key substringWithRange:NSMakeRange(0, 4)];
    if (![keyPrefix isEqualToString:@"font"])
      continue;
      
    NSString* keySuffix = @"default";
    if (length > 5)
      keySuffix = [key substringWithRange:NSMakeRange(5, length-5)];
    
    NSDictionary* fontDico = [sheet valueForKey:key];
    assert (fontDico != nil);
    
    BundleFontsheet* fontsheet = [[BundleFontsheet alloc] initWithSheet:fontDico forClass:keySuffix defaultFontsheet:defaultFontsheet bundle:bundle error:anError];
    [_fontsheets setObject:fontsheet forKey:keySuffix];
  }
  
  
  return self;
}




//....................................................................................
//
// parse the given stylesheet for a single-state graphic element 
//
- (id)parseSingleState:(NSDictionary*)sheet bundle:(NSBundle*)bundle error:(NSError **)anError
{
  
    NSString* name = [sheet valueForKey:@"name"];

    UIImage* image;

    // load image file if requested
    if (name != nil)
    {
        NSString* type = [sheet valueForKey:@"type"];
        NSString* path = [sheet valueForKey:@"path"];

        if (path == nil)
        {
            NSString* tmppath = [name stringByAppendingPathExtension:type];
            image = [UIImage imageNamed:tmppath];
            if (image == nil)
            {
                NSLog(@"local image loading failed with tmppath '%@'  from name '%@' and type '%@'", tmppath, name, type);
                assert(0);
                return [BundleFileManager errorHandling:@"image" forPath:name error:anError];
            }
        }
        else
        {
            NSString* tmppath = [bundle pathForResource:name ofType:type inDirectory:path];
            image = [UIImage imageWithContentsOfFile:tmppath];
            
            if (image == nil)
            {
                NSLog(@"image loading failed with tmppath '%@'    from name '%@' and type '%@' and path '%@'", tmppath, name, type, path);
                assert(0);
                return [BundleFileManager errorHandling:@"image" forPath:name error:anError];
            }
        }

    
    [_images setValue:image forKey:@"up"];
  }
  
  // look if width and height are provided
  NSString* widthStr = [sheet valueForKey:@"width"];
  NSString* heightStr = [sheet valueForKey:@"height"];
  NSInteger width, height;
  
  // if they're not, get width and height from loaded image
  if (widthStr != nil)
    width = [widthStr integerValue];
  else if (name != nil)
    width = image.size.width;
  else width = 0;
  
  if (heightStr != nil)
    height = [heightStr integerValue];
  else if (name != nil)
    height = image.size.height;
  else height = 0;
  
  // compute resulting frame
  _frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
  
  return self;
}







//....................................................................................
//
// parse the given stylesheet for a multi-states graphic element : a roll-over UIButton for instance.
//
- (id)parseMultiStates:(NSDictionary*)sheet forStates:(NSArray*)states bundle:(NSBundle*)bundle error:(NSError **)anError
{
  
  // get source image
  NSString* name = [sheet valueForKey:@"name"];
  NSString* type = [sheet valueForKey:@"type"];
  NSString* path = [sheet valueForKey:@"path"];
  
    UIImage* src = nil;
    
    if (path == nil)
        
    {
        src = [UIImage imageNamed:[name stringByAppendingPathExtension:type]];
    }
    else
    {
        NSString* tmppath = [bundle pathForResource:name ofType:type inDirectory:path];
        src = [UIImage imageWithContentsOfFile:tmppath];
    }

    if (src == nil)
    return [BundleFileManager errorHandling:@"image" forPath:name error:anError];
  
  // look if width and height are provided
  NSString* widthStr = [sheet valueForKey:@"width"];
  NSString* heightStr = [sheet valueForKey:@"height"];
  NSInteger width, height;
  
  // if they're not, get width and height from loaded image
  if (widthStr != nil)
    width = [widthStr integerValue];
  else 
    width = src.size.width;
  
  if (heightStr != nil)
    height = [heightStr integerValue];
  else 
    height = src.size.height / [states count];
  
  // create image from source, for every states
  int srcx = 0;
  int srcy = 0;
  for (int index = 0; index < [states count]; index++, srcy += height)
  {
    CGImageRef imageRef = CGImageCreateWithImageInRect([src CGImage], CGRectMake(srcx, srcy, width, height));
    UIImage* image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);    
    
    // store the build image
    [self.images setValue:image forKey:[states objectAtIndex:index]];
  }
  
  
  // compute resulting frame
  _frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
  
  return self;
  
}




    



//....................................................................................
//
// create a button
//
- (UIButton*)makeButton
{
  UIButton* button = [[UIButton alloc] initWithFrame:self.frame];
  
  NSArray* allKeys = [self.images allKeys];
  for (NSString* key in allKeys)
  {
    if ([key isEqualToString:@"up"])
      [button setImage:[self.images valueForKey:key] forState:UIControlStateNormal];
    else if ([key isEqualToString:@"down"])
      [button setImage:[self.images valueForKey:key] forState:UIControlStateHighlighted];
    else if ([key isEqualToString:@"disabled"])
      [button setImage:[self.images valueForKey:key] forState:UIControlStateDisabled];
    else if ([key isEqualToString:@"selectedUp"])
      [button setImage:[self.images valueForKey:key] forState:UIControlStateSelected];
    else if ([key isEqualToString:@"selectedDown"])
      [button setImage:[self.images valueForKey:key] forState:(UIControlStateSelected|UIControlStateHighlighted)];
  }
    
    NSNumber* alphaNb = [self.customProperties objectForKey:@"alpha"];
    if (alphaNb != nil)
    {
        CGFloat alpha = [alphaNb floatValue];
        button.alpha = alpha;
    }
  
  return button;
}




//....................................................................................
//
// create a font
//
- (UIFont*)makeFont
{
    BundleFontsheet* fontsheet = [self.fontsheets objectForKey:@"default"];
    UIFont* font = nil;
    
    // a specific font has been requested
    if (fontsheet.name != nil)
    {
        NSString* fontName = [fontsheet.name stringByAppendingFormat:@"-%d", fontsheet.size];
        font = [gFonts objectForKey:fontName];
        
        // add the font, if it's not been done already
        if (font == nil)
        {
            font = [UIFont fontWithName:fontsheet.name size:fontsheet.size];
            if (font == nil)
                NSLog(@"BundleStylesheet error : could not get the font '%@'", fontsheet.name);
            else
                [gFonts setObject:font forKey:fontName];
        }
    }
    
    if (font != nil)
        return font;
    
    // otherwise, use the system font
    else if ([fontsheet.weight isEqualToString:@"bold"])
        font = [UIFont boldSystemFontOfSize:fontsheet.size];
    else  if ([fontsheet.weight isEqualToString:@"italic"])
        font = [UIFont italicSystemFontOfSize:fontsheet.size];
    else
        font = [UIFont systemFontOfSize:fontsheet.size];
    
    return font;
}



//....................................................................................
//
// create a label
//
- (UILabel*)makeLabel
{  
    BundleFontsheet* fontsheet = [self.fontsheets objectForKey:@"default"];

    UILabel* label = [[UILabel alloc] initWithFrame:self.frame];
    label.backgroundColor = fontsheet.backgroundColor;
    label.textColor = fontsheet.textColor;
    label.text = fontsheet.text;
    label.textAlignment = fontsheet.textAlignement;
    
    // apply shadow, if requested
    if (fontsheet.shadowIsSet)
    {
        label.layer.masksToBounds = NO;
        
        label.layer.shadowOffset = fontsheet.shadowOffset;
        label.layer.shadowRadius = fontsheet.shadowRadius;
        label.layer.shadowOpacity = fontsheet.shadowOpacity;
        label.layer.shadowColor = fontsheet.shadowColor.CGColor;
    }
    

    label.font = [self makeFont];
    
    NSNumber* alphaNb = [self.customProperties objectForKey:@"alpha"];
    if (alphaNb != nil)
    {
        CGFloat alpha = [alphaNb floatValue];
        label.alpha = alpha;
    }
    
    return label;
}




- (BOOL)applyToLabel:(UILabel*)label class:(NSString*)class
{
  if (class == nil)
    class = @"default";
  
  BundleFontsheet* fontsheet = [self.fontsheets objectForKey:class];
  if (fontsheet == nil)
    return NO;
  
  if (fontsheet.backgroundColorIsSet == YES)
    label.backgroundColor = fontsheet.backgroundColor;
  
  if (fontsheet.textColorIsSet == YES)
    label.textColor = fontsheet.textColor;
  
  if (fontsheet.textAlignmentIsSet == YES)
    label.textAlignment = fontsheet.textAlignement;
  
  UIFont* font = nil;
  
  // a specific font has been requested
  if (fontsheet.nameIsSet)
  {
    NSString* fontName = [fontsheet.name stringByAppendingFormat:@"-%d", fontsheet.size];
    font = [gFonts objectForKey:fontName];
    
    // add the font, if it's not been done already
    if (font == nil)
    {
      font = [UIFont fontWithName:fontsheet.name size:fontsheet.size];
      if (font == nil)
        NSLog(@"BundleStylesheet error : could not get the font '%@'", fontsheet.name);
      else
        [gFonts setObject:font forKey:fontName];
    }
    
  }
  
  if (font != nil)
    label.font = font;
  
  // otherwise, use the system font
  else if (fontsheet.weightIsSet && ([fontsheet.weight isEqualToString:@"bold"]))
    label.font = [UIFont boldSystemFontOfSize:fontsheet.size];
  else  if (fontsheet.weightIsSet &&  ([fontsheet.weight isEqualToString:@"italic"]))
    label.font = [UIFont italicSystemFontOfSize:fontsheet.size];
  else if (fontsheet.weightIsSet || fontsheet.sizeIsSet)
    label.font = [UIFont systemFontOfSize:fontsheet.size];
    
    NSNumber* alphaNb = [self.customProperties objectForKey:@"alpha"];
    if (alphaNb != nil)
    {
        CGFloat alpha = [alphaNb floatValue];
        label.alpha = alpha;
    }
    
    // apply shadow, if requested
    if (fontsheet.shadowIsSet)
    {
        label.layer.masksToBounds = NO;
        
        label.layer.shadowOffset = fontsheet.shadowOffset;
        label.layer.shadowRadius = fontsheet.shadowRadius;
        label.layer.shadowOpacity = fontsheet.shadowOpacity;
        label.layer.shadowColor = fontsheet.shadowColor.CGColor;
    }
  
  return YES;
}







// create UIImageView using the parsed stylesheet
- (UIImageView*)makeImage
{
  UIImageView* view = [[UIImageView alloc] initWithImage:[self image]];
  view.frame = self.frame;
    
    NSNumber* alphaNb = [self.customProperties objectForKey:@"alpha"];
    if (alphaNb != nil)
    {
        CGFloat alpha = [alphaNb floatValue];
        view.alpha = alpha;
    }
    
  return view;
}





@end








