//
//  SignupViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"


@interface SignupViewController : TrackedUIViewController
{
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

    IBOutlet UILabel* _submitLabel;    
}


- (IBAction) onSubmit:(id)sender;

@end




