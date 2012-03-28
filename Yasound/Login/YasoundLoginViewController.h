//
//  YasoundLoginViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"

@interface YasoundLoginViewController : TestflightViewController
{
    IBOutlet UILabel* _titleLabel;
    
    //...............................................
    IBOutlet UILabel* _label;
    IBOutlet UITextField* _email;
    IBOutlet UITextField* _pword;
    
    IBOutlet UIButton* _signupButton;
    
}

@end






