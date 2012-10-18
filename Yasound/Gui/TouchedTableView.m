//
//  TouchedTableView.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 25/05/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "TouchedTableView.h"

@implementation TouchedTableView

@synthesize actionTouched;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) 
    {
    }
    return self;
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.actionTouched != nil)
        [self.delegate performSelector:self.actionTouched withObject:touches withObject:event];

    [super touchesBegan:touches withEvent:event];
}



@end
