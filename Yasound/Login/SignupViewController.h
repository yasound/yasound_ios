//
//  SignupViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"


@interface SignupViewController : TestflightViewController<UITextFieldDelegate>
{
    IBOutlet UIBarButtonItem* _backItem;
    IBOutlet UIBarButtonItem* _titleItem;
    
    //...............................................
    IBOutlet UIView* _container;
    
    IBOutlet UILabel* _label;
    IBOutlet UITextField* _username;
    IBOutlet UITextField* _email;
    IBOutlet UITextField* _pword;
    IBOutlet UITextField* _confirmPword;
    
    IBOutlet UIButton* _submitButton;
    IBOutlet UILabel* _submitLabel;
    
    CGFloat _posMin;
    CGFloat _posRef;
}


- (IBAction) onSubmit:(id)sender;

@end





