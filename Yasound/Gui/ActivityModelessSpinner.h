//
//  ActivityModelessSpinner.h
//
//  Created by Loïc Berthelot on 01/13/2012
//  Copyright (c) 2011 Yasound. All rights reserved.
//

// 
// a spinner for on-going activities, to avoir using the usual modal activity dialog.
//
// you can add and remove references
// when references count is > 0 : display a small spinner on the top right of the screen
// when references count is == 0 : make the spinner disappear 
//
//


#import <UIKit/UIKit.h>

@interface ActivityModelessSpinner : NSObject
{
    UIActivityIndicatorView* _ai;
    UIView* _view;
}

@property (nonatomic) NSInteger refcount;
@property (nonatomic) BOOL hidden;

+ (ActivityModelessSpinner*) main;

- (void)addRef;
- (void)addRefForTimeInterval:(NSTimeInterval)timeInterval;

- (void)removeRef;


@end