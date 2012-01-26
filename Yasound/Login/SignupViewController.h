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
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;

    //.............................................
    IBOutlet UITableView* _tableView;
    
    //.............................................
    IBOutlet UITableViewCell* _cellUsername;
    IBOutlet UILabel* _cellUsernameLabel;
    IBOutlet UITextField* _cellUsernameTextfield;
    
    IBOutlet UITableViewCell* _cellPword;
    IBOutlet UILabel* _cellPwordLabel;
    IBOutlet UITextField* _cellPwordTextfield;

    IBOutlet UITableViewCell* _cellEmail;
    IBOutlet UILabel* _cellEmailLabel;
    IBOutlet UITextField* _cellEmailTextfield;

    IBOutlet UITableViewCell* _cellLegal;
    NSString* _cellLegalReadLabel;
    IBOutlet UILabel* _cellLegalValidLabel;

    
    IBOutlet UITableViewCell* _cellSubmit;
    IBOutlet UIButton* _submitBtn;
    
    BOOL _userValidatedInfo;
    BOOL _userValidatedLegal;
    
    
    NSString* _email;
    NSString* _pword;
    
}


- (IBAction)onBack:(id)sender;
- (IBAction)onSwitch:(id)sender;
- (IBAction) onSubmit:(id)sender;

@end





