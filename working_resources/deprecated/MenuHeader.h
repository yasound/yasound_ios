//
//  MenuHeader.h
//  UIScrollViewTest
//
//  Created by Sébastien Métrot on 10/25/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuHeader : UIView
{
  UILabel* label;
}

- (id)initWithFrame:(CGRect)frame andText:(NSString*)text;

@end
