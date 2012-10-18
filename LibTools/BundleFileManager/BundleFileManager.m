  //
//  BundleFileManager.m
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import "BundleFileManager.h"


#define APP_DOMAINE @"App"




//BundleFileManager category for NSBundle
@implementation NSBundle (BundleFileManager)
- (UIImage*)imageNamed:(NSString*)name ofType:(NSString*)type inDirectory:(NSString*)path
{
  NSString* fullname = [name stringByAppendingPathExtension:type];
  return [UIImage imageNamed:fullname];
}
@end











@implementation BundleFileManager


@synthesize stylesheetDictionnary = _stylesheetDictionnary;
@synthesize stylesheets = _stylesheets;



- (id)initMain
{
    self = [super init];
    if (self)
    {
        NSDictionary* resources = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Resources"];
        
        // stylesheet
        _stylesheetDictionnary = [resources objectForKey:@"stylesheet"];
        if (_stylesheetDictionnary == nil)
            DLog(@"BundleFileManager Warning : could not find any stylesheet");
        
        _stylesheets = [[NSMutableDictionary alloc] init];
    
    }
    
    return self;
}


- (id)initWithBundlePath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self)
    {
        // stylesheet
        _stylesheetDictionnary = [self objectForInfoDictionaryKey:@"stylesheet"];
        if (_stylesheetDictionnary == nil)
            DLog(@"BundleFileManager initWithPath Warning : could not find any stylesheet");
        
        _stylesheets = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (id)initWithStylesheet:(NSDictionary*)stylesheet
{
    self = [super init];
    if (self)
    {
        self.stylesheetDictionnary = stylesheet;
        if (self.stylesheetDictionnary == nil)
        {
            DLog(@"BundleFileManager Warning : could not find any stylesheet");
            assert(0);
        }
        
        _stylesheets = [[NSMutableDictionary alloc] init];
        
    }
    
    return self;
}






static BundleFileManager* _main = nil;

+ (BundleFileManager*) main
{
  if (_main == nil)
  {
    _main = [[BundleFileManager alloc] initMain];
  }
  
  return _main;
}


- (void) dealloc
{
    [super dealloc];
}
















//.............................................................................
//
// stylesheet
//



// read info from the stylesheet entry from the bundle info.plist,
// load the corresponding image and build associated frame.
- (BundleStylesheet*) stylesheetForKey:(NSString*)key error:(NSError **)anError 
{
  BundleStylesheet* stylesheet = [self.stylesheets objectForKey:key];
  if (stylesheet != nil)
    return stylesheet;
  
    NSDictionary* styleItem = [self stylesheetItemFromKey:key];
    
    stylesheet = [[BundleStylesheet alloc] initWithSheet:styleItem name:key bundle:self error:anError];

  return stylesheet;
}


- (BundleStylesheet*) stylesheetForKey:(NSString*)key retainStylesheet:(BOOL)retainStylesheet overwriteStylesheet:(BOOL)overwriteStylesheet error:(NSError **)anError
{
  BundleStylesheet* stylesheet = [self.stylesheets objectForKey:key];
  
  if ((stylesheet != nil) && !overwriteStylesheet)
    return stylesheet;
  
    NSDictionary* styleItem = [self stylesheetItemFromKey:key];
  
  stylesheet = [[BundleStylesheet alloc] initWithSheet:styleItem name:key bundle:self error:anError];
  
  if (retainStylesheet)
    [self.stylesheets setObject:stylesheet forKey:key];
  
  return stylesheet;
  
}



- (NSDictionary*)stylesheetItemFromKey:(NSString*)key
{
    // get stylesheet entry
    NSDictionary* styleItem = nil;
    NSRange range = NSMakeRange(0, key.length);
    NSRange pos = [key rangeOfString:@"." options:NSLiteralSearch range:range];
    if (pos.location == NSNotFound)
    {
        styleItem = [self.stylesheetDictionnary valueForKey:key];
        
        if (styleItem == nil)
        {
            DLog(@"BundleFileManager::stylesheetForKey Error : could not find item for key '%@'", key);
            assert(0);
            return nil;
        }
    }
    else
    {
        
        NSString* sub;
        styleItem = self.stylesheetDictionnary;
        while (pos.location != NSNotFound)
        {
            sub = [key substringWithRange:NSMakeRange(range.location, pos.location - range.location)];
            styleItem = [styleItem objectForKey:sub];
            
            if (styleItem == nil)
            {
                DLog(@"stylesheetForKey error : could not find sub '%@', using key '%@'", sub, key);
                assert(0);
            }
            
            range = NSMakeRange(pos.location+1, key.length - (pos.location+1));
            pos = [key rangeOfString:@"." options:NSLiteralSearch range:range];
        }
        sub = [key substringWithRange:range];
        styleItem = [styleItem objectForKey:sub];
        
        if (styleItem == nil)
        {
            DLog(@"stylesheetForKey error : could not find sub '%@', using key '%@'", sub, key);
            assert(0);
            return nil;
        }
    }
    
    return styleItem;
}








//.............................................................................
//
// error handling
//


+ (NSObject*) errorHandling:(NSString*)type forPath:(NSString*)path error:(NSError **)anError
{
  NSString* msg = [NSString stringWithFormat:@"could not find %@ file", type];
  
  NSMutableDictionary* details = [[NSMutableDictionary alloc] init];
  [details setValue:msg forKey:NSLocalizedDescriptionKey];
  [details setValue:path forKey:NSFilePathErrorKey];
  
  if (anError != NULL) 
    *anError = [[[NSError alloc] initWithDomain:APP_DOMAINE code:NSURLErrorFileDoesNotExist userInfo:details] autorelease];
  
  DLog(@"ERROR :");
  DLog([details valueForKey:NSLocalizedDescriptionKey]);
  DLog(@"'%@'", [details valueForKey:NSFilePathErrorKey]);
  
  return nil;
}













@end