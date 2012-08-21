//
//  SignupViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaViewController.h"
#import "MyUITextField.h"


@interface SignupViewController : YaViewController<UITextFieldDelegate>
{
//    IBOutlet UIBarButtonItem* _backItem;
//    IBOutlet UIBarButtonItem* _titleItem;
    
    //...............................................
    IBOutlet UIView* _container;
    
    IBOutlet UILabel* _label;
    IBOutlet MyUITextField* _username;
    IBOutlet MyUITextField* _email;
    IBOutlet MyUITextField* _pword;
    IBOutlet MyUITextField* _confirmPword;
    
    IBOutlet UIButton* _submitButton;
    IBOutlet UILabel* _submitLabel;
    
    CGFloat _posMin;
    CGFloat _posRef;
    
    UIAlertView* _confirmAlert;
}


//- (IBAction) onSubmit:(id)sender;

@end





