//
//  LoginViewController.h
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
    BOOL _keyboardVisible;
    BOOL _loginViewVisible;
    BOOL _yasoundLoginViewVisible;
    BOOL _yasoundSignupViewVisible;
    
    //.............................................
    IBOutlet UIView* _container;
    IBOutlet UIView* _defaultView;    
    IBOutlet UIView* _loginView;
    IBOutlet UITableView* _tableView;

    //.............................................
    IBOutlet UIView* _yasoundLoginView;
    IBOutlet UILabel* _yasoundLoginViewTitle;
    IBOutlet UITableView* _yasoundLoginTableView;
    
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
    IBOutlet UILabel* _yasoundSignupViewTitle;
    IBOutlet UITableView* _yasoundSignupTableView;

    IBOutlet UITableViewCell* _yasoundSignupCellEmail;
    IBOutlet UILabel* _yasoundSignupCellEmailLabel;
    IBOutlet UITextField* _yasoundSignupCellEmailTextField;
}

@end




@interface LoginViewController (YasoundLogin)

- (IBAction)onLoginCanceled:(id)sender;

- (void) yasoundLogin_ViewDidLoad;

- (NSInteger)yasoundLogin_numberOfSectionsInTableView;
- (NSInteger)yasoundLogin_numberOfRowsInSection:(NSInteger)section ;
- (UITableViewCell *)yasoundLogin_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)yasoundLogin_didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end




@interface LoginViewController (YasoundSignup)

- (IBAction)onSignupCanceled:(id)sender;

- (void) yasoundSignup_ViewDidLoad;

- (NSInteger)yasoundSignup_numberOfSectionsInTableView;
- (NSInteger)yasoundSignup_numberOfRowsInSection:(NSInteger)section ;
- (UITableViewCell *)yasoundSignup_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)yasoundSignup_didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

