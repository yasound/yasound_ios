//
//  ChartView.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/11/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "S7GraphView.h"

@interface ChartView : S7GraphView
{
}

@property (nonatomic, retain) NSArray* dates;
@property (nonatomic, retain) NSArray* values;

- (id)initWithFrame:(CGRect)frame minimalDisplay:(BOOL)minimalDisplay;



@end
