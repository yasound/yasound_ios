//
//  BundleStylesheet.m
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import "BundleStylesheet.h"
#import "BundleFileManager.h"
#import "ObjectButton.h"
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
@synthesize textAlignment = _textAlignment;
@synthesize textAlignmentIsSet = _textAlignmentIsSet;
@synthesize text = _text;
@synthesize textColor = _textColor;
@synthesize textColorIsSet = _textColorIsSet;
@synthesize backgroundColor = _backgroundColor;
@synthesize backgroundColorIsSet = _backgroundColorIsSet;
@synthesize weight = _weight;
@synthesize weightIsSet = _weightIsSet;
@synthesize numberOfLines = _numberOfLines;
@synthesize numberOfLinesIsSet = _numberOfLinesIsSet;


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
    _numberOfLinesIsSet = NO;


  // default init
  if (([class isEqualToString:@"default"]) || (defaultFontsheet == nil))
  {
    _size = 12;
    _textAlignment = UITextAlignmentLeft;
    _text = [NSString stringWithFormat:@""];
      [_text retain];
    _textColor = [UIColor blackColor];
    _backgroundColor = [UIColor clearColor];
    _weight = [NSString stringWithFormat:@"normal"];
      [_weight retain];
  }
  else
  {
    _size = defaultFontsheet.size;
    _textAlignment = defaultFontsheet.textAlignment;
    _textColor = defaultFontsheet.textColor;
    _backgroundColor = defaultFontsheet.backgroundColor;
    _weight = [NSString stringWithFormat:defaultFontsheet.weight];
      [_weight retain];
  }

  NSString* fontName = [sheet valueForKey:@"name"];
  if (fontName != nil)
  {
    _name = [NSString stringWithFormat:fontName];
      [_name retain];
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
    _text = [NSString stringWithFormat:fontText];
      [_text retain];
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
      [_weight retain];
    _weightIsSet = YES;
  }
  
  NSString* alignement = [sheet valueForKey:@"textAlignment"];
  if (alignement != nil)
  {
    _textAlignment = [BundleFontsheet alignementFromString:alignement];
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
    
    NSNumber* numberOfLines = [sheet valueForKey:@"numberOfLines"];
    if (numberOfLines != nil)
    {
        _numberOfLines = [numberOfLines integerValue];
        _numberOfLinesIsSet = YES;
    }



  return self;
}


- (void)dealloc
{
    if (_text)
        [_text release];
    if (_weight)
        [_weight release];
    [super dealloc];
}

@end


    
















//..................................................................................
//  
//  BundleStylesheet
//

#pragma mark - BundleStylesheet
    

@implementation BundleStylesheet

@synthesize name;
@synthesize images = _images;
@synthesize frame = _frame;
@synthesize color = _color;
@synthesize fontsheets;
@synthesize customProperties = _customProperties;



static NSMutableDictionary* gFonts = nil;
static NSNumber* _isRetina = nil;
static NSMutableDictionary* gImageViews = nil;


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
  self.fontsheets = [[NSMutableDictionary alloc] init];
    
  _customProperties = nil;

  
  return self;
}


+ (BOOL)isRetina
{
    if (_isRetina == nil)
    {
        BOOL isRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2);
        isRetina &= (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
        _isRetina = [NSNumber numberWithBool:isRetina];
    }

    return [_isRetina boolValue];
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
  return [self.images valueForKey:@"normal"];
}



//....................................................................................
//
// init a stylesheet using a stylesheet contents (NSDictionary), for a given bundle 
//
- (id)initWithSheet:(NSDictionary*)sheet name:(NSString*)name bundle:(NSBundle*)bundle error:(NSError **)anError
{
  self = [self init];
    
    self.name = [NSString stringWithString:name];
  
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
    [self.fontsheets setObject:defaultFontsheet forKey:@"default"];
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
    [self.fontsheets setObject:fontsheet forKey:keySuffix];
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
    NSString* normal = [sheet valueForKey:@"normal"];
    if (name == nil)
        name = normal;

    UIImage* image;

    // load image file if requested
    if (name != nil)
    {
        NSString* type = [sheet valueForKey:@"type"];
        NSString* path = [sheet valueForKey:@"path"];

        NSString* highlighted = [sheet valueForKey:@"highlighted"];
        NSString* selected = [sheet valueForKey:@"selected"];
        NSString* selectedhighlighted = [sheet valueForKey:@"selected|highlighted"];
        if (selectedhighlighted == nil)
            selectedhighlighted = [sheet valueForKey:@"highlighted|selected"];
        NSString* disabled = [sheet valueForKey:@"disabled"];
        NSString* selecteddisabled = [sheet valueForKey:@"selected|disabled"];
        if (selecteddisabled == nil)
            selecteddisabled = [sheet valueForKey:@"disabled|selected"];
        
        if (path == nil)
        {
            NSString* tmppath = [name stringByAppendingPathExtension:type];
            image = [UIImage imageNamed:tmppath];
            if (image == nil)
            {
                DLog(@"local image loading failed with tmppath '%@'  from name '%@' and type '%@'", tmppath, name, type);
                assert(0);
                return [BundleFileManager errorHandling:@"image" forPath:name error:anError];
            }
            [_images setValue:image forKey:@"normal"];
            
            if (highlighted != nil)
            {
                NSString* tmppath = [highlighted stringByAppendingPathExtension:type];
                image = [UIImage imageNamed:tmppath];
                if (image != nil)
                    [_images setValue:image forKey:@"highlighted"];
            }
                
            if (selected != nil)
            {
                NSString* tmppath = [selected stringByAppendingPathExtension:type];
                image = [UIImage imageNamed:tmppath];
                if (image != nil)
                [_images setValue:image forKey:@"selected"];
            }

            if (selectedhighlighted != nil)
            {
                NSString* tmppath = [selectedhighlighted stringByAppendingPathExtension:type];
                image = [UIImage imageNamed:tmppath];
                if (image != nil)
                [_images setValue:image forKey:@"selected|highlighted"];
            }

            if (disabled != nil)
            {
                NSString* tmppath = [disabled stringByAppendingPathExtension:type];
                image = [UIImage imageNamed:tmppath];
                if (image != nil)
                [_images setValue:image forKey:@"disabled"];
            }

            if (selecteddisabled != nil)
            {
                NSString* tmppath = [selecteddisabled stringByAppendingPathExtension:type];
                image = [UIImage imageNamed:tmppath];
                if (image != nil)
                [_images setValue:image forKey:@"selected|disabled"];
            }
            
        }
        else
        {
            NSString* tmppath = [bundle pathForResource:name ofType:type inDirectory:path];
            image = [UIImage imageWithContentsOfFile:tmppath];
            
            if (image == nil)
            {
                DLog(@"image loading failed with tmppath '%@'    from name '%@' and type '%@' and path '%@'", tmppath, name, type, path);
                assert(0);
                return [BundleFileManager errorHandling:@"image" forPath:name error:anError];
            }
            [_images setValue:image forKey:@"normal"];

            if (highlighted != nil)
            {
                NSString* tmppath = [bundle pathForResource:highlighted ofType:type inDirectory:path];
                image = [UIImage imageWithContentsOfFile:tmppath];
                if (image != nil)
                    [_images setValue:image forKey:@"highlighted"];
            }
            
            if (selected != nil)
            {
                NSString* tmppath = [bundle pathForResource:selected ofType:type inDirectory:path];
                image = [UIImage imageWithContentsOfFile:tmppath];
                if (image != nil)
                    [_images setValue:image forKey:@"selected"];
            }
            
            if (selectedhighlighted != nil)
            {
                NSString* tmppath = [bundle pathForResource:selectedhighlighted ofType:type inDirectory:path];
                image = [UIImage imageWithContentsOfFile:tmppath];
                if (image != nil)
                    [_images setValue:image forKey:@"selected|highlighted"];
            }
            
            if (disabled != nil)
            {
                NSString* tmppath = [bundle pathForResource:disabled ofType:type inDirectory:path];
                image = [UIImage imageWithContentsOfFile:tmppath];
                if (image != nil)
                    [_images setValue:image forKey:@"disabled"];
            }
            
            if (selecteddisabled != nil)
            {
                NSString* tmppath = [bundle pathForResource:selecteddisabled ofType:type inDirectory:path];
                image = [UIImage imageWithContentsOfFile:tmppath];
                if (image != nil)
                    [_images setValue:image forKey:@"selected|disabled"];
            }
            
        }

    
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
        if ([BundleStylesheet isRetina])
            name = [name stringByAppendingString:@"@2x"];
        
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
    if ([key isEqualToString:@"normal"])
      [button setImage:[self.images valueForKey:key] forState:UIControlStateNormal];
      
    else if ([key isEqualToString:@"highlighted"])
      [button setImage:[self.images valueForKey:key] forState:UIControlStateHighlighted];
      
    else if ([key isEqualToString:@"disabled"])
      [button setImage:[self.images valueForKey:key] forState:UIControlStateDisabled];
      
    else if ([key isEqualToString:@"selected"])
      [button setImage:[self.images valueForKey:key] forState:UIControlStateSelected];
      
    else if ([key isEqualToString:@"selected|highlighted"])
      [button setImage:[self.images valueForKey:key] forState:(UIControlStateSelected|UIControlStateHighlighted)];

    else if ([key isEqualToString:@"selected|disabled"])
        [button setImage:[self.images valueForKey:key] forState:(UIControlStateSelected|UIControlStateDisabled)];
  }
    
    NSNumber* alphaNb = [self.customProperties objectForKey:@"alpha"];
    if (alphaNb != nil)
    {
        CGFloat alpha = [alphaNb floatValue];
        button.alpha = alpha;
    }
  
  return button;
}


- (ObjectButton*)makeObjectButton
{
    ObjectButton* button = [[ObjectButton alloc] initWithFrame:self.frame];
    
    NSArray* allKeys = [self.images allKeys];
    for (NSString* key in allKeys)
    {
        if ([key isEqualToString:@"normal"])
            [button setImage:[self.images valueForKey:key] forState:UIControlStateNormal];
        
        else if ([key isEqualToString:@"highlighted"])
            [button setImage:[self.images valueForKey:key] forState:UIControlStateHighlighted];
        
        else if ([key isEqualToString:@"disabled"])
            [button setImage:[self.images valueForKey:key] forState:UIControlStateDisabled];
        
        else if ([key isEqualToString:@"selected"])
            [button setImage:[self.images valueForKey:key] forState:UIControlStateSelected];
        
        else if ([key isEqualToString:@"selected|highlighted"])
            [button setImage:[self.images valueForKey:key] forState:(UIControlStateSelected|UIControlStateHighlighted)];
        
        else if ([key isEqualToString:@"selected|disabled"])
            [button setImage:[self.images valueForKey:key] forState:(UIControlStateSelected|UIControlStateDisabled)];
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
                DLog(@"BundleStylesheet error : could not get the font '%@'", fontsheet.name);
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


- (UIColor*)fontTextColor
{
    BundleFontsheet* fontsheet = [self.fontsheets objectForKey:@"default"];
    return fontsheet.textColor;
    
}

- (UIColor*)fontBackgroundColor
{
    BundleFontsheet* fontsheet = [self.fontsheets objectForKey:@"default"];
    return fontsheet.backgroundColor;
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
    label.textAlignment = fontsheet.textAlignment;
    
    // apply shadow, if requested
    if (fontsheet.shadowIsSet)
    {
        label.layer.masksToBounds = NO;
        
        label.layer.shadowOffset = fontsheet.shadowOffset;
        label.layer.shadowRadius = fontsheet.shadowRadius;
        label.layer.shadowOpacity = fontsheet.shadowOpacity;
        label.layer.shadowColor = fontsheet.shadowColor.CGColor;
    }
    
    if (fontsheet.numberOfLinesIsSet)
    {
        label.numberOfLines = fontsheet.numberOfLines;
        label.lineBreakMode = UILineBreakModeWordWrap;
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
    label.textAlignment = fontsheet.textAlignment;
  
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
        DLog(@"BundleStylesheet error : could not get the font '%@'", fontsheet.name);
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
    
    if (fontsheet.numberOfLinesIsSet)
    {
        label.numberOfLines = fontsheet.numberOfLines;
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

- (UIImageView*)makeImageAndRetain:(BOOL)retainView
{
    UIImageView* view = [self makeImage];
    if (retainView)
    {
        if (gImageViews == nil)
        {
            gImageViews = [[NSMutableDictionary alloc] init];
            [gImageViews retain];
        }
        [gImageViews setObject:view forKey:self.name];
    }
}

- (UIImageView*)getRetainedImage
{
    UIImageView* view = nil;
    if (gImageViews)
        [gImageViews objectForKey:self.name];
    if (view != nil)
        return view;
    
    view = [self makeImageAndRetain:YES];
    return view;
}






@end








