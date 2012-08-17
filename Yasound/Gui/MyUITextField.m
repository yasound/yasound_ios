//
//  MyUITextField.m
//  Yasound
//
//  Created by neywen on 17/08/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import "MyUITextField.h"

@implementation MyUITextField

@synthesize horizontalPadding, verticalPadding, marginLeft, marginRight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + horizontalPadding + marginLeft, bounds.origin.y + verticalPadding, bounds.size.width - horizontalPadding*2 - marginLeft - marginRight, bounds.size.height - verticalPadding*2);
}


- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

@end
