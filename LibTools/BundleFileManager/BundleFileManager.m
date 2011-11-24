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


@synthesize stylesheet = _stylesheet;

#ifdef OPENGL_SPRITE
@synthesize animsheet = _animsheet;
@synthesize audiosheet = _audiosheet;
#endif



//+ (BundleFileManager*)bundleWithPath:(NSString*)path
//{
//  NSBundle* [NSBundle bundleWithPath:path];
//}


static BundleFileManager* _main = nil;

+ (BundleFileManager*) main
{
  if (_main == nil)
  {
    _main = [[BundleFileManager alloc] init];
    
    // stylesheet
    _main.stylesheet = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"stylesheet"];
    if (_main.stylesheet == nil)
      NSLog(@"BundleFileManager Warning : could not find any stylesheet");
    
#ifdef OPENGL_SPRITE

    // animsheet
    _main.animsheet = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"animsheet"];
    if (_main.animsheet == nil)
      NSLog(@"BundleFileManager Warning : could not find any animsheet");
    
    //audiosheet
    _main.audiosheet = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"audiosheet"];
    if (_main.audiosheet == nil)
      NSLog(@"BundleFileManager Warning : could not find any audiosheet");
#endif
  }
  
  return _main;
}


- (void) dealloc
{
}




//
////.............................................................................
////
//// generic methods
////
//
//
//- (NSString*)pathForResource:(NSString*)localPath
//{
//  NSString* name = localPath;
//  NSString* ext = [localPath pathExtension];
//  if (ext != nil)
//    name = [name substringWithRange:NSMakeRange(0, name.length - (ext.length+1))];
//
//  NSString* path  = [self pathForResource:name ofType:ext];
//  return path;
//}
//
//
//- (NSString*)pathForResource:(NSString *)name ofType:(NSString *)ext
//{
//  NSString* path = [super pathForResource:name ofType:ext];
//  
//  if (path == nil)
//  {
//    NSLog(@"BundleFileManager error : pathForResource is nil for name '@'  type '%@'", name, ext);
//    assert(0);
//  }
//  
//  return path;
//}
//
//
//- (NSString*)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath
//{
//  NSString* path = [super pathForResource:name ofType:ext inDirectory:subpath];
//  
//  if (path == nil)
//  {
//    NSLog(@"BundleFileManager error : pathForResource is nil for name '%@'  type '%@' inDirectory '%@'", name, ext, subpath);
//    assert(0);
//  }
//  
//  return path;
//}
//
//
//
////
//// return true if file exists
//// 
//- (BOOL)fileExistsAtPath:(NSString*)path
//{
//  NSString* name = path;
//  NSString* ext = [path pathExtension];
//  if (ext != nil)
//    name = [name substringWithRange:NSMakeRange(0, name.length - (ext.length+1))];
//  
//  return [self fileExistsAtPath:name ofType:ext];
//}
//
//
////
//// return true if file exists
//// 
//- (BOOL)fileExistsAtPath:(NSString*)name ofType:(NSString*)type;
//{
//  NSString* localPath = [self pathForResource:name ofType:type];
//  if (localPath == nil)
//    return NO;
//  
//  BOOL res = [[NSFileManager defaultManager] fileExistsAtPath:localPath];
//  return res;
//}
//
//
//- (BOOL)fileExistsAtPath:(NSString*)name ofType:(NSString*)type inDirectory:(NSString*)directory
//{
//  NSString* localPath = [self pathForResource:name ofType:type inDirectory:directory];
//  if (localPath == nil)
//    return NO;
//  
//  BOOL res = [[NSFileManager defaultManager] fileExistsAtPath:localPath];
//  return res;
//}











//
//
//
////.............................................................................
////
//// images
////
//
////
//// shortcut to get a UIImage from a path
//// 
//- (UIImage*) imageNamed:(NSString*)path
//{
//  NSString* name = path;
//  NSString* ext = [path pathExtension];
//  if (ext != nil)
//    name = [name substringWithRange:NSMakeRange(0, name.length - (ext.length+1))];
//  UIImage* image = [self imageNamed:name ofType:ext inDirectory:nil];
//  return image;
//}
//
//
//- (UIImage*) imageNamed:(NSString*)name ofType:(NSString*)type inDirectory:(NSString*)directory
//{
//  NSString* dir = (directory == nil)? @"images" : directory;
//  
//  NSString* imagePath = [self pathForResource:name ofType:type inDirectory:dir];
//  UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
//  
//  if (image == nil)
//    NSLog(@"BundleFileManager::imageNamed error : could not find local file '%@'   from resource path '%@' ofType '%@'", imagePath, name, type);
//  
//  return image;
//}
//
//
//
//



















//.............................................................................
//
// stylesheet
//




// read info from the stylesheet entry from the bundle info.plist,
// load the corresponding image and build associated frame.
- (BundleStylesheet*) stylesheetForKey:(NSString*)key error:(NSError **)anError 
{
  // get stylesheet entry
  NSDictionary* styleItem = [self.stylesheet valueForKey:key];
  if (styleItem == nil)
  {
    NSLog(@"BundleFileManager::stylesheetForKey Error : could not find item for key '%@'", key);
    return nil;
  }
  
  BundleStylesheet* stylesheet = [[BundleStylesheet alloc] initWithSheet:styleItem bundle:[NSBundle mainBundle] error:anError];

  return stylesheet;
}





#ifdef OPENGL_SPRITE


//.............................................................................
//
// animsheet
//

// read info from the animsheet entry from the bundle info.plist,
- (BundleAnimsheet*) animsheetForKey:(NSString*)key error:(NSError **)anError
{
  // get stylesheet entry
//  id item = [self.animsheet valueForKey:key];
  NSArray* item = [self.animsheet valueForKey:key];
  if (item == nil)
  {
    NSLog(@"BundleFileManager::animsheetForKey Error : could not find item for key '%@'", key);
    return nil;
  }
  
  BundleAnimsheet* sheet = [[BundleAnimsheet alloc] initWithSheet:item key:key];
  
  return sheet;
}











//.............................................................................
//
// audio
//


// shortcut to get an audio object from a path
// 'path' : is a simple node filename. Should not include "audio" directory

- (NSString*) audioNamed:(NSString*)path
{
  if (path == nil)
    return nil;
  
  NSString* name = path;
  NSString* ext = [path pathExtension];
  if (ext != nil)
    name = [name substringWithRange:NSMakeRange(0, name.length - (ext.length+1))];
  NSString* audio = [self audioNamed:name ofType:ext inDirectory:nil];
  return audio;  
}



- (NSString*) audioNamed:(NSString*)name ofType:(NSString*)type inDirectory:(NSString*)directory
{
  if (name == nil)
    return nil;

  NSString* dir = (directory == nil)? @"audio" : directory;
  
  NSString* audioPath = [self pathForResource:name ofType:type inDirectory:dir];
  
  return audioPath;
}


- (BundleAudiosheet*) audiosheetForKey:(NSString*)key atIndex:(NSInteger)index error:(NSError **)anError
{
  NSArray* objects = [self.audiosheet valueForKey:key];
  
  // error handling
  if (objects == nil)
  {
    NSLog(@"BundleFileManager::audiosheetForKey Error : could not find item for key '%@'", key);
    assert(1);
    return nil;
  }
  
  if (index >= [objects count])
  {
    NSLog(@"BundleFileManager::audiosheetForKey Error : given index [%d] is out of range [%d]", index, [objects count]);
    assert(1);
    return nil;
  }
  
  NSDictionary* item = [objects objectAtIndex:index];

  // build bundle audio sheet
  BundleAudiosheet* audiosheet = [[BundleAudiosheet alloc] initWithSheet:item bundle:[NSBundle mainBundle] error:anError];

  return audiosheet;
}



#endif









//.............................................................................
//
// error handling
//


+ (NSObject*) errorHandling:(NSString*)type forPath:(NSString*)path error:(NSError **)anError
{
  NSString* msg = [[NSString alloc] initWithFormat:@"could not find %@ file", type];
  
  NSMutableDictionary* details = [[NSMutableDictionary alloc] init];
  [details setValue:msg forKey:NSLocalizedDescriptionKey];
  [details setValue:path forKey:NSFilePathErrorKey];
  
  if (anError != NULL) 
    *anError = [[[NSError alloc] initWithDomain:APP_DOMAINE code:NSURLErrorFileDoesNotExist userInfo:details] autorelease];
  
  NSLog(@"ERROR :");
  NSLog([details valueForKey:NSLocalizedDescriptionKey]);
  NSLog(@"'%@'", [details valueForKey:NSFilePathErrorKey]);
  
  return nil;
}













@end