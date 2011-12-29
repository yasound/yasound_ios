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
    IBOutlet UITableView* _tableView;
    
    //.............................................
    IBOutlet UITableViewCell* _cellUsername;
    IBOutlet UILabel* _cellUsernameLabel;
    IBOutlet UITextField* _cellUsernameTextfield;
    
    IBOutlet UITableViewCell* _cellPword;
    IBOutlet UILabel* _cellPwordLabel;
    IBOutlet UITextField* _cellPwordTextfield;

    IBOutlet UIButton* _submitBtn;
}


- (IBAction) onSubmit:(id)sender;

@end





