//
//  WheelSelectorGenre.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 19/07/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelSelector.h"


typedef enum {
    
    eGenreStatusClosed = 0,
    eGenreStatusOpened
    
} WheelSelectorGenreStatus;


@interface WheelSelectorGenre : WheelSelector

@property (nonatomic) WheelSelectorGenreStatus status;
@property (nonatomic, retain) NSArray* genres;

- (void)moveTo:(CGFloat)posY;

@end
