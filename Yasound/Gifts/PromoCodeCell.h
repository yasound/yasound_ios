//
//  PromoCodeCell.h
//  Yasound
//
//  Created by mat on 13/09/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PromoCodeDelegate

- (void)promoCodeEntered:(NSString*)promoCode;

@end

@interface PromoCodeCell : UITableViewCell <UITextFieldDelegate>
{
    UILabel* _label;
    UITextField* _textField;
}

@property (retain, nonatomic) id<PromoCodeDelegate> promoCodeDelegate;

- (void)reset;

@end
