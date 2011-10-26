//
//  MenuHeader.m
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/25/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "MenuHeader.h"

@implementation MenuHeader

static const int INSET_X = 16;

- (id)initWithFrame:(CGRect)frame andText:(NSString*)text
{
  self = [super initWithFrame:frame];
  if (self)
  {
    label = [[UILabel alloc] init];
    label.text = text;
    
    UIFont* font = [UIFont fontWithName:@"helvetica" size:10];
    label.font = font;
    [self addSubview:label];
    CGSize size = [label sizeThatFits:frame.size];
    label.frame = CGRectMake(INSET_X, frame.size.height - size.height - 2, size.width, size.height);
    label.textColor = [UIColor colorWithRed:.741176471 green:0.0 blue:0.0 alpha:1.0];
  }
  return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorRef white = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
  CGColorRef red = [UIColor colorWithRed:.741176471 green:0.0 blue:0.0 alpha:1.0].CGColor;
  
  CGContextSetFillColorWithColor(context, white);
  CGContextFillRect(context, self.bounds);
  
  CGContextSetFillColorWithColor(context, red);
  CGSize size = [label sizeThatFits:self.frame.size];
  CGRect r1 = CGRectMake(0, self.frame.size.height - size.height, INSET_X, size.height - 4);
  CGContextFillRect(context, r1);
  CGRect r2 = CGRectMake(INSET_X + size.width, self.frame.size.height - size.height, self.frame.size.width - INSET_X + size.width, size.height - 4);
  CGContextFillRect(context, r2);
  
  [super drawRect:rect];
}

@end
