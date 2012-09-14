//
//  AccountYasoundViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 30/03/12.
//  Copyright (c) 2012 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarModal.h"

@interface AccountYasoundViewController : UIViewController
{
    IBOutlet TopBarModal* _topbar;
    IBOutlet UITextField* _email;
    IBOutlet UITextField* _pword;
    IBOutlet UITextField* _pwordConfirm;

    IBOutlet UILabel* _logoutLabel;
    IBOutlet UIButton* _logoutButton;
    IBOutlet UILabel* _loginLabel;
    IBOutlet UIButton* _loginButton;
    
}



- (IBAction)onButtonClicked:(id)sender;


@end
