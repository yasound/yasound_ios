//
//  YasoundLoginViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaViewController.h"
#import "MyUITextField.h"

@interface YasoundLoginViewController : YaViewController
{
//    IBOutlet UIBarButtonItem* _backItem;
//    IBOutlet UIBarButtonItem* _titleItem;
    
    //...............................................
    IBOutlet UILabel* _label;
    IBOutlet MyUITextField* _email;
    IBOutlet MyUITextField* _pword;
    
    IBOutlet UIButton* _loginButton;
    IBOutlet UILabel* _loginLabel;
    IBOutlet UIButton* _signupButton;
    IBOutlet UIButton* _forgetButton;
    
}


@property (nonatomic, retain) IBOutlet UIView* container;
//@property (nonatomic, retain) IBOutlet UITextField* email;
//@property (nonatomic, retain) IBOutlet UITextField* pword;



- (IBAction) onSubmit:(id)sender;
- (IBAction)onSignupClicked:(id)sender;
- (IBAction)onForgotClicked:(id)sender;

@end






