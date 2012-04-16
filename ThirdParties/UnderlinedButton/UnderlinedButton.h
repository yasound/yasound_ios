//
//  UnderlinedButton.h
//
//  Created by David Hinson on 11/24/09.
//  Copyright 2009 Sumner Systems Management, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UnderlinedButton : UIButton 
{
    CGSize _suggestedSize;
    UITextAlignment* _textAlignment;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state textAlignement:(UITextAlignment)textAlignment;


@end

