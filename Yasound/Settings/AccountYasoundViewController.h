//
//  AccountYasoundViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 30/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountYasoundViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _backItem;
    IBOutlet UIBarButtonItem* _titleItem;
    
    IBOutlet UITextField* _email;
    IBOutlet UITextField* _pword;

    IBOutlet UILabel* _logoutLabel;
    IBOutlet UIButton* _logoutButton;
    IBOutlet UILabel* _loginLabel;
    IBOutlet UIButton* _loginButton;
    
}

- (IBAction)onBack:(id)sender;
- (IBAction)onButtonClicked:(id)sender;


@end
