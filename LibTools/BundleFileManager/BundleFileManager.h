//
//  BundleFileManager.h
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BundleStylesheet.h"

#ifdef OPENGL_SPRITE
#import "BundleAudiosheet.h"
#import "BundleAnimsheet.h"
#endif


//BundleFileManager category for NSBundle
@interface NSBundle (BundleFileManager)
- (UIImage*)imageNamed:(NSString*)name ofType:(NSString*)type inDirectory:(NSString*)path;
@end




@interface BundleFileManager : NSObject
{
    NSDictionary* _stylesheetDictionnary;
    

#ifdef OPENGL_SPRITE
  NSDictionary* _animsheet;
  NSDictionary* _audiosheet;
#endif
}

@property (nonatomic, retain) NSDictionary* stylesheetDictionnary;

#ifdef OPENGL_SPRITE
@property (nonatomic, retain) NSDictionary* animsheet;
@property (nonatomic, retain) NSDictionary* audiosheet;
#endif



+ (BundleFileManager*) main;

//- (void)staticOptimInit;
//- (void)staticOptimUninit;

//+ (BundleFileManager*)bundleWithPath:(NSString*)path;

////.............................................................................
////
//// generic methods
////
//
//- (NSString*)pathForResource:(NSString*)localPath;
//- (NSString*)pathForResource:(NSString *)name ofType:(NSString *)ext;
//- (NSString*)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath;
//
//
//// return true if file exists
//- (BOOL)fileExistsAtPath:(NSString*)path;
//// return true if file exists
//- (BOOL)fileExistsAtPath:(NSString*)name ofType:(NSString*)type;
//// return true if file exists
//- (BOOL)fileExistsAtPath:(NSString*)name ofType:(NSString*)type inDirectory:(NSString*)directory;
//
//
//
//
//
//
//
////.............................................................................
////
//// images
////
//
//// shortcut to get a UIImage from a path
//// 'path' : is a simple node filename. Should not include "images" directory
//- (UIImage*) imageNamed:(NSString*)path;
//- (UIImage*) imageNamed:(NSString*)name ofType:(NSString*)type inDirectory:(NSString*)directory;



//.............................................................................
//
// stylesheet
//


// read info from the stylesheet entry from the bundle info.plist,
// load the corresponding image and build associated frame.
- (BundleStylesheet*) stylesheetForKey:(NSString*)key error:(NSError **)anError;

// special version of the stylesheet getter.
// - retainStylesheet : if YES, keeps the stylesheet in the static stylesheets dictionnary. useful when you have multiple access to the stylesheet, and you don't want to parse the stylesheet definition each time
// - overwriteStylesheet : if YES, and if the stylesheet is in the static stylesheets dictionnary already, force the parsing and overwrite the existing stylesheet
- (BundleStylesheet*) stylesheetForKey:(NSString*)key retainStylesheet:(BOOL)retainStylesheet overwriteStylesheet:(BOOL)overwriteStylesheet error:(NSError **)anError;




#ifdef OPENGL_SPRITE
//.............................................................................
//
// animsheet
//

// read info from the animsheet entry from the bundle info.plist,
- (BundleAnimsheet*) animsheetForKey:(NSString*)key error:(NSError **)anError;






//.............................................................................
//
// audio
//

// shortcut to get an audio object from a path
// 'path' : is a simple node filename. Should not include "audio" directory
- (NSString*) audioNamed:(NSString*)path;
- (NSString*) audioNamed:(NSString*)name ofType:(NSString*)type inDirectory:(NSString*)directory;

// same thing, but parameter is a key from the info.plist, instead of a direct filepath.
- (BundleAudiosheet*) audiosheetForKey:(NSString*)key atIndex:(NSInteger)index error:(NSError **)anError;

#endif



//.............................................................................
//
// error handling
//
+ (NSObject*) errorHandling:(NSString*)type forPath:(NSString*)path error:(NSError **)anError;





@end
