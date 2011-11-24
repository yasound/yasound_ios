//
//  BundleStylesheet.m
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import "BundleStylesheet.h"
#import "BundleFileManager.h"


//..................................................................................
//  
//  BundleFontsheet
//

#pragma mark - BundleFontsheet


@implementation BundleFontsheet

@synthesize name = _name;
@synthesize size = _size;
@synthesize textAlignement = _textAlignement;
@synthesize text = _text;
@synthesize textColor = _textColor;
@synthesize backgroundColor = _backgroundColor;
@synthesize weight = _weight;


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
    return [BundleFontsheet colorFromRgbString:str];
    
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






- (id)initWithSheet:(NSDictionary*)sheet bundle:(NSBundle*)bundle error:(NSError **)anError
{
  self = [super init];

  // default init
  _size = 12;
  _textAlignement = UITextAlignmentLeft;
  _text = [[NSString alloc] initWithString:@""];
  _textColor = [UIColor blackColor];
  _backgroundColor = [UIColor clearColor];
  _weight = [[NSString alloc] initWithString:@"normal"];

  NSString* fontName = [sheet valueForKey:@"name"];
  if (fontName != nil)
    _name = [[NSString alloc] initWithString:fontName];

  NSNumber* fontSize = [sheet valueForKey:@"size"];
  if (fontSize != nil)
    _size = [fontSize integerValue];
    
  NSString* fontText = [sheet valueForKey:@"text"];
  if (fontText != nil)
    _text = [[NSString alloc] initWithString:fontText];
  
  NSString* textColor = [sheet valueForKey:@"textColor"];
  if (textColor != nil)
    _textColor = [BundleFontsheet colorFromString:[textColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

  NSString* backgroundColor = [sheet valueForKey:@"backgroundColor"];
  if (backgroundColor != nil)
    _backgroundColor = [BundleFontsheet colorFromString:backgroundColor];
  
  NSString* fontWeight = [sheet valueForKey:@"weight"];
  if (fontWeight != nil)
    _weight = fontWeight;
  
  NSString* alignement = [sheet valueForKey:@"textAlignement"];
  if (alignement != nil)
    _textAlignement = [BundleFontsheet alignementFromString:alignement];

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
@synthesize font = _font;
@synthesize customProperties = _customProperties;



static NSMutableDictionary* gFonts = nil;



- (id)init
{
  self = [super init];
  
  if (gFonts == nil)
    gFonts = [[NSMutableDictionary alloc] init];
  
  _images = [[NSMutableDictionary alloc] init];
  _frame = CGRectMake(0, 0, 0, 0);
  _font = nil;
  _customProperties = nil;

  
  return self;
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
  NSDictionary* fontSheet = [sheet valueForKey:@"font"];
  if (fontSheet != nil)
    _font = [[BundleFontsheet alloc] initWithSheet:fontSheet bundle:bundle error:anError];
  
  
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
    
    image = [bundle imageNamed:name ofType:type inDirectory:path];
    
    if (image == nil)
      return [BundleFileManager errorHandling:@"image" forPath:name error:anError];
    
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
  
  UIImage* src = [bundle imageNamed:name ofType:type inDirectory:path];
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
// static shortcut to create a button
//
+ (UIButton*)BSMakeButton:(BundleStylesheet*)stylesheet
{
  UIButton* button = [[UIButton alloc] initWithFrame:stylesheet.frame];
  
  NSArray* allKeys = [stylesheet.images allKeys];
  for (NSString* key in allKeys)
  {
    if ([key isEqualToString:@"up"])
      [button setImage:[stylesheet.images valueForKey:key] forState:UIControlStateNormal];
    else if ([key isEqualToString:@"down"])
      [button setImage:[stylesheet.images valueForKey:key] forState:UIControlStateHighlighted];
    else if ([key isEqualToString:@"disabled"])
      [button setImage:[stylesheet.images valueForKey:key] forState:UIControlStateDisabled];
    else if ([key isEqualToString:@"selectedUp"])
      [button setImage:[stylesheet.images valueForKey:key] forState:UIControlStateSelected];
    else if ([key isEqualToString:@"selectedDown"])
      [button setImage:[stylesheet.images valueForKey:key] forState:(UIControlStateSelected|UIControlStateHighlighted)];
  }
  
  return button;
}




//....................................................................................
//
// static shortcut to create a label
//
+ (UILabel*)BSMakeLabel:(BundleStylesheet*)stylesheet
{  
  UILabel* label = [[UILabel alloc] initWithFrame:stylesheet.frame];
  label.backgroundColor = stylesheet.font.backgroundColor;
  label.textColor = stylesheet.font.textColor;
  label.text = stylesheet.font.text;
  label.textAlignment = stylesheet.font.textAlignement;
  
  UIFont* font = nil;
  
  // a specific font has been requested
  if (stylesheet.font.name != nil)
  {
    NSString* fontName = [stylesheet.font.name stringByAppendingFormat:@"-%d", stylesheet.font.size];
    font = [gFonts objectForKey:fontName];
    
    // add the font, if it's not been done already
    if (font == nil)
    {
      font = [UIFont fontWithName:stylesheet.font.name size:stylesheet.font.size];
      if (font == nil)
        NSLog(@"BundleStylesheet error : could not get the font '%@'", stylesheet.font.name);
      else
        [gFonts setObject:font forKey:fontName];
    }
  }
  
  if (font != nil)
    label.font = font;
    
  // otherwise, use the system font
  else if ([stylesheet.font.weight isEqualToString:@"bold"])
    label.font = [UIFont boldSystemFontOfSize:stylesheet.font.size];
  else  if ([stylesheet.font.weight isEqualToString:@"italic"])
    label.font = [UIFont italicSystemFontOfSize:stylesheet.font.size];
  else
    label.font = [UIFont systemFontOfSize:stylesheet.font.size];

  return label;
}



// create UIImageView using the parsed stylesheet
+ (UIImageView*)BSMakeImage:(BundleStylesheet*)sheet
{
  UIImageView* view = [[UIImageView alloc] initWithImage:[sheet image]];
  view.frame = sheet.frame;
  return view;
}





@end








