//
//  LoginViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YaViewController.h"
#import "UnderlinedButton.h"
#import "User.h"
#import "TopBarModal.h"


@interface LoginViewController : YaViewController
{
    IBOutlet UIBarButtonItem* _titleLabel;
    IBOutlet UIBarButtonItem* _backBtn;
    
    //...............................................
    IBOutlet UIButton* _facebookButton;
    IBOutlet UILabel* _facebookLabel;

    IBOutlet UIButton* _twitterButton;
    IBOutlet UILabel* _twitterLabel;

    IBOutlet UIButton* _yasoundButton;
    IBOutlet UILabel* _yasoundLabel;

    IBOutlet UnderlinedButton* _signupButton;
    
    BOOL _dismissed;
}

@property (nonatomic, retain) User* user;


- (IBAction)onFacebook:(id)sender;
- (IBAction)onTwitter:(id)sender;
- (IBAction)onYasound:(id)sender;
- (IBAction)onYasoundSignup:(id)sender;



@end






