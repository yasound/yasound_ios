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
    BOOL _keyboardVisible;
    BOOL _loginViewVisible;
    BOOL _yasoundSignupViewVisible;
    
    UIBarButtonItem* _backBtn;
    
    //.............................................
    IBOutlet UIView* _container;
    IBOutlet UIView* _defaultView;    
    IBOutlet UIView* _loginView;
    IBOutlet UITableView* _tableView;

    //.............................................
    IBOutlet UITableViewCell* _yasoundLoginCellUsername;
    IBOutlet UILabel* _yasoundLoginCellUsernameLabel;
    IBOutlet UITextField* _yasoundLoginCellUsernameTextField;
    
    IBOutlet UITableViewCell* _yasoundLoginCellPword;
    IBOutlet UILabel* _yasoundLoginCellPwordLabel;
    IBOutlet UITextField* _yasoundLoginCellPwordTextField;

    IBOutlet UITableViewCell* _yasoundLoginCellSubmit;
    IBOutlet UILabel* _yasoundLoginCellSubmitLabel;
    
    IBOutlet UITableViewCell* _yasoundLoginCellSignup;
    IBOutlet UILabel* _yasoundLoginCellSignupLabel;

    //.............................................
    IBOutlet UIView* _yasoundSignupView;
    IBOutlet UITableView* _yasoundSignupTableView;

    IBOutlet UITableViewCell* _yasoundSignupCellEmail;
    IBOutlet UILabel* _yasoundSignupCellEmailLabel;
    IBOutlet UITextField* _yasoundSignupCellEmailTextField;
}

@end






@interface LoginViewController (YasoundSignup)

- (IBAction)onSignupCanceled:(id)sender;

- (void) yasoundSignup_ViewDidLoad;

- (NSInteger)yasoundSignup_numberOfSectionsInTableView;
- (NSInteger)yasoundSignup_numberOfRowsInSection:(NSInteger)section ;
- (UITableViewCell *)yasoundSignup_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)yasoundSignup_didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

