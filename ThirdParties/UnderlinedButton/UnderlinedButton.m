//
//  UnderlinedButton.m
//
//  Created by David Hinson on 11/24/09.
//  Copyright 2009 Sumner Systems Management, Inc.. All rights reserved.
//

#import "UnderlinedButton.h"


@implementation UnderlinedButton

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        // Initialization code
    }
    return self;
}   



- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
    
    }
    
    return self;
}


- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    _suggestedSize = [title sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.frame.size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    [super setTitle:title forState:state];
}




- (void)drawRect:(CGRect)rect 
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, self.currentTitleColor.CGColor);
    
    // Draw them with a 1.0 stroke width.
    CGContextSetLineWidth(context, 1.0);
    
    CGFloat baseline = rect.size.height + self.titleLabel.font.descender + 2;
    
    // Draw a single line from left to right
    CGContextMoveToPoint(context, rect.size.width - _suggestedSize.width, baseline);
    CGContextAddLineToPoint(context, rect.size.width, baseline);
    CGContextStrokePath(context);
}



- (void)dealloc 
{
    [super dealloc];
}

@end