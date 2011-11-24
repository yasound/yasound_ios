//
//  BundleAnimsheet.m
//
//  Created by loic berthelot on 10/2011.
//  Copyright 2011 Loic Berthelot & Matthieu Campion. All rights reserved.
//

#import "BundleAnimsheet.h"

@implementation BundleAnimsheet



@synthesize key = _key;
@synthesize sheet = _sheet;



// init a stylesheet using an animsheet contents (NSArray), for a given bundle 
- (id)initWithSheet:(NSArray*)sheet key:(NSString*)key
{
  self = [super init];

  _key = [[NSString alloc] initWithString:key];
  _sheet = [[NSArray alloc] initWithArray:sheet];
  return self;
}






// ActionSequence* ou ActionRepeatForever*
+ (id)BAMakeAction:(BundleAnimsheet*)sheet withSprite:(Sprite*)sprite
{
  NSMutableArray* sequence = [[NSMutableArray alloc] init];
  
  // for all sequence
  for (NSDictionary* animSequence in sheet.sheet)
  {
    
    NSMutableSet* parallel = [[NSMutableSet alloc] init];
  
    // for all defined anim in parallel
    NSArray* allKeys = [animSequence allKeys];
    for (NSString* key in allKeys)
    {
      NSDictionary* anim = [animSequence valueForKey:key];

      // check the anim parameters
      NSString* name = [[NSString alloc] initWithString:key];
      CGFloat x = [[anim valueForKey:@"x"] floatValue];
      CGFloat y = [[anim valueForKey:@"y"] floatValue];
      CGFloat alpha = [[anim valueForKey:@"alpha"] floatValue];
      CGFloat duration = [[anim valueForKey:@"duration"] floatValue];
      
      // define repeat animation 
      // special case : directly returns repeat animation
      if ([name isEqualToString:@"animateLoop"])
      {
        ActionAnimate* actionAnimate = [ActionAnimate actionWithDuration:duration];
        ActionRepeatForever* actionRepeat = [ActionRepeatForever actionWithAction:actionAnimate];
        return actionRepeat;
      }

      
      // define animate action
      else if ([name isEqualToString:@"animate"] || [name isEqualToString:@"animateOnce"])
      {
        ActionAnimate* action = [ActionAnimate actionWithDuration:duration];
        [parallel addObject:action];
      }
      
      // define move animation 
      else if ([name isEqualToString:@"move"])
      {
        sprite.position = CGPointMake(x, y);
      }
      else if ([name isEqualToString:@"moveBy"])
      {
        Action* action = [ActionMoveBy actionWithDuration:duration position:CGPointMake(x, y)];
        [parallel addObject:action];
      }
      else if ([name isEqualToString:@"moveTo"])
      {
        Action* action = [ActionMoveTo actionWithDuration:duration position:CGPointMake(x, y)];
        [parallel addObject:action];
      }

      // define scale animation 
      else if ([name isEqualToString:@"scale"])
      {
        sprite.scaleX = x;
        sprite.scaleY = y;
      }
      else if ([name isEqualToString:@"scaleTo"])
      {
        Action* action = [ActionScaleTo actionWithDuration:duration scaleX:x scaleY:y];
        [parallel addObject:action];
      }
      else if ([name isEqualToString:@"scaleBy"])
      {
        Action* action = [ActionScaleBy actionWithDuration:duration scaleX:x scaleY:y];
        [parallel addObject:action];
      }

      
      // define rotate animation 
      else if ([name isEqualToString:@"rotate"])
      {
        alpha = alpha / 180.0 * M_PI;
        sprite.angle = alpha;
      }
      else if ([name isEqualToString:@"rotateTo"])
      {
        alpha = alpha / 180.0 * M_PI;
        Action* action = [ActionRotateTo actionWithDuration:duration angle:alpha];
        [parallel addObject:action];
      }
      else if ([name isEqualToString:@"rotateBy"])
      {
        alpha = alpha / 180.0 * M_PI;
        Action* action = [ActionRotateBy actionWithDuration:duration angle:alpha];
        [parallel addObject:action];
      }
      
      
      // define alpha animation 
      else if ([name isEqualToString:@"alpha"])
      {
        sprite.alpha = alpha;
      }
      else if ([name isEqualToString:@"fadeOut"])
      {
        Action* action = [ActionFadeOut actionWithDuration:duration];
        [parallel addObject:action];
      }
      else if ([name isEqualToString:@"fadeIn"])
      {
        Action* action = [ActionFadeIn actionWithDuration:duration];
        [parallel addObject:action];
      }

      
      
      
      else
      {
        NSLog(@"BAMakeAction : unimplemented '%@' animation in entry '%@'", name, sheet.key);
        assert(0);
      }
      
#ifdef _DEBUG
      NSLog(@"BAMakeAction defines animation %@  for '%@'  |   with (x,y) (%.2f, %.2f)   with duration %.2f", name, sheet.key, x, y, duration);
#endif
      
    }
    
    if (parallel.count > 0)
      [sequence addObject:[ActionParallel actionWithActionSet:parallel]];
  }

  if (sequence.count == 0)
    return nil;
  
  return [ActionSequence actionWithActionArray:sequence];
}



@end