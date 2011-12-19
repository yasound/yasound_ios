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
    IBOutlet UIView* _container;
    IBOutlet UIView* _defaultView;    
    IBOutlet UIView* _loginView;
    IBOutlet UITableView* _tableView;

    IBOutlet UIView* _yasoundLoginView;
    IBOutlet UITableView* _yasoundLoginTableView;

    IBOutlet UIView* _yasoundSignupView;
    IBOutlet UITableView* _yasoundSignupTableView;
}

@end




@interface LoginViewController (YasoundLogin)

- (IBAction)onLoginCanceled:(id)sender;

- (NSInteger)yasoundLogin_numberOfSectionsInTableView;
- (NSInteger)yasoundLogin_numberOfRowsInSection:(NSInteger)section ;
- (UITableViewCell *)yasoundLogin_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)yasoundLogin_didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end




@interface LoginViewController (YasoundSignup)

- (IBAction)onSignupCanceled:(id)sender;

- (NSInteger)yasoundSignup_numberOfSectionsInTableView;
- (NSInteger)yasoundSignup_numberOfRowsInSection:(NSInteger)section ;
- (UITableViewCell *)yasoundSignup_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)yasoundSignup_didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

