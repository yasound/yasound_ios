//
//  LoginViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestflightViewController.h"
#import "UnderlinedButton.h"

@interface LoginViewController : TestflightViewController
{
    IBOutlet UILabel* _titleLabel;
    
    //...............................................
    IBOutlet UIButton* _facebookButton;
    IBOutlet UILabel* _facebookLabel;

    IBOutlet UIButton* _twitterButton;
    IBOutlet UILabel* _twitterLabel;

    IBOutlet UIButton* _yasoundButton;
    IBOutlet UILabel* _yasoundLabel;

    IBOutlet UnderlinedButton* _signupButton;
}


- (IBAction)onFacebook:(id)sender;
- (IBAction)onTwitter:(id)sender;
- (IBAction)onYasound:(id)sender;
- (IBAction)onYasoundSignup:(id)sender;



@end






