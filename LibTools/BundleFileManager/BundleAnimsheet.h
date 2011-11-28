//
//  BundleAnimsheet.h
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef OPENGL_SPRITE
#import "Actions/ActionTransform.h"
#import "Sprite/Sprite.h"
#endif


@interface BundleAnimsheet: NSObject
{
  NSString* _key;
  NSArray* _sheet;
}

@property (nonatomic, retain, readonly) NSString* key;
@property (nonatomic, retain, readonly) NSArray* sheet;

// init a stylesheet using an animsheet contents (NSDictionary), for a given bundle 
- (id)initWithSheet:(NSArray*)sheet key:(NSString*)key;


#ifdef OPENGL_SPRITE
// ActionSequence* ou ActionRepeatForever*
+ (id)BAMakeAction:(BundleAnimsheet*)sheet withSprite:(Sprite*)sprite;
#endif



@end




