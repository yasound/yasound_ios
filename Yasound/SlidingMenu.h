//
//  SlidingMenu.h
//  Yasound
//
//  Created by Sébastien Métrot on 10/26/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlidingMenu : UIView
{
  NSMutableArray* tiles;
}

- (id)initWithFrame:(CGRect)frame menuName:(NSString*)name names:(NSArray*)names captions:(NSArray*)captions andDestinations:(NSArray*)destinations;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
