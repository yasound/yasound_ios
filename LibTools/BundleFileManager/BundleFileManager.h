//
//  BundleFileManager.h
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BundleStylesheet.h"




//BundleFileManager category for NSBundle
@interface NSBundle (BundleFileManager)
- (UIImage*)imageNamed:(NSString*)name ofType:(NSString*)type inDirectory:(NSString*)path;
@end




@interface BundleFileManager : NSBundle


@property (nonatomic, retain) NSDictionary* stylesheetDictionnary;
@property (nonatomic, retain, readonly) NSMutableDictionary* stylesheets;




+ (BundleFileManager*) main;

- (id)initWithStylesheet:(NSDictionary*)stylesheet;
- (id)initWithBundlePath:(NSString *)path;



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




//.............................................................................
//
// error handling
//
+ (NSObject*) errorHandling:(NSString*)type forPath:(NSString*)path error:(NSError **)anError;





@end
