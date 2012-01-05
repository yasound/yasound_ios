//
//  LoginViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"


@interface LoginViewController : TrackedUIViewController
{
    IBOutlet UIBarButtonItem* _backBtn;
    IBOutlet UILabel* _titleLabel;

    IBOutlet UITableView* _tableView;
    
    //.............................................
    IBOutlet UITableViewCell* _cellEmail;
    IBOutlet UILabel* _cellEmailLabel;
    IBOutlet UITextField* _cellEmailTextfield;
    
    IBOutlet UITableViewCell* _cellPword;
    IBOutlet UILabel* _cellPwordLabel;
    IBOutlet UITextField* _cellPwordTextfield;

    IBOutlet UIButton* _submitBtn;
    
    
    NSString* _email;
    NSString* _pword;
}


- (IBAction)onBack:(id)sender;
- (IBAction) onSubmit:(id)sender;

@end





