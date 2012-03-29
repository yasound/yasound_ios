//
//  SignupViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"


@interface SignupViewController : TestflightViewController
{
    IBOutlet UIBarButtonItem* _backItem;
    IBOutlet UIBarButtonItem* _titleItem;
    
    //...............................................
    IBOutlet UILabel* _label;
    IBOutlet UITextField* _username;
    IBOutlet UITextField* _email;
    IBOutlet UITextField* _pword;
    
    IBOutlet UIButton* _submitButton;
    IBOutlet UILabel* _submitLabel;
}


- (IBAction) onSubmit:(id)sender;

@end





