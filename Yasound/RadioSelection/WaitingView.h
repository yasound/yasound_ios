//
//  WaitingView.h
//  Yasound
//
//  Created by mat on 13/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitingView : UIView
{
    UILabel* _label;
    UIActivityIndicatorView* _indicator;
}

- (id)initWithText:(NSString*)text;

@end
