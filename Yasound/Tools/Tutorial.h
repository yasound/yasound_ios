//
//  Tutorial.h
//  Yasound
//
//  Created by Loic Berthelot on 11/7/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>


#define TUTORIAL_KEY_RADIOVIEW @"Tutorial_RadioView"
#define TUTORIAL_KEY_TRACKSVIEW @"Tutorial_TracksView"


@interface Tutorial : NSObject
{
    NSMutableArray* _fifo;
}

+ (Tutorial*)main;

- (void)show:(NSString*)key everyTime:(BOOL)everyTime;

@end