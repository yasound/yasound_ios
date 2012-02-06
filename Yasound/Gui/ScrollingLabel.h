//
//  ScrollingLabel.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 06/02/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BundleFileManager.h"

@interface ScrollingLabel : UIView
{
    NSTimer* _timer;
}

@property (atomic, retain) NSMutableArray* labels;
@property (atomic, retain) NSMutableArray* labelFlags;

@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) NSString* style;
@property (nonatomic, retain) UIFont* font;

- (id)initWithStyle:(NSString*)style;


@end
