//
//  BundleAudiosheet.h
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BundleFileManager;

@interface BundleAudiosheet: NSObject
{
  NSString* _audioPath;
  NSString* _ldPath;
  NSString* _name;
  NSString* _shortname;
}

@property (nonatomic, retain, readonly) NSString* audioPath;
@property (nonatomic, retain, readonly) NSString* ldPath;
@property (nonatomic, retain, readonly) NSString* name;
@property (nonatomic, retain, readonly) NSString* shortname;

- (id)initWithSheet:(NSDictionary*)sheet bundle:(BundleFileManager*)bundle error:(NSError**)anError;

@end




