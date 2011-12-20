//
//  LoginViewController_YasoundLogin.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "LoginViewController.h"

#define SECTION_LOGIN 0
#define ROW_USERNAME 0
#define ROW_PWORD 1

#define SECTION_SUBMIT 1
#define ROW_SUBMIT 0

#define SECTION_SIGNUP 2
#define ROW_SIGNUP 0


@implementation LoginViewController (YasoundLogin)


- (void) yasoundLogin_ViewDidLoad
{
    _yasoundLoginCellUsernameLabel.text = NSLocalizedString(@"yasoundLogin_Username_label", nil);
    _yasoundLoginCellUsernameTextField.placeholder = NSLocalizedString(@"yasoundLogin_Username_placeholder", nil);
    
    _yasoundLoginCellPwordLabel.text = NSLocalizedString(@"yasoundLogin_Pword_label", nil);
    _yasoundLoginCellPwordTextField.placeholder = NSLocalizedString(@"yasoundLogin_Pword_placeholder", nil);
    
    _yasoundLoginCellSubmitLabel.text = NSLocalizedString(@"yasoundLogin_Submit_label", nil);
    
    _yasoundLoginCellSignupLabel.text = NSLocalizedString(@"yasoundLogin_Signup_label", nil);
    
}



- (NSInteger)yasoundLogin_numberOfSectionsInTableView
{
    return 3;
}


- (NSInteger)yasoundLogin_numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 2;
    
    return 1;
}


- (UITableViewCell *)yasoundLogin_cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_LOGIN) && (indexPath.row == ROW_USERNAME))
        return _yasoundLoginCellUsername;
    
    if ((indexPath.section == SECTION_LOGIN) && (indexPath.row == ROW_PWORD))
        return _yasoundLoginCellPword;

    if ((indexPath.section == SECTION_SUBMIT) && (indexPath.row == ROW_SUBMIT))
        return _yasoundLoginCellSubmit;

    if ((indexPath.section == SECTION_SIGNUP) && (indexPath.row == ROW_SIGNUP))
        return _yasoundLoginCellSignup;

    return nil;
}


- (void)yasoundLogin_didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_SIGNUP) && (indexPath.row == ROW_SIGNUP))
    {
        NSArray* data = [NSArray arrayWithObjects:_yasoundLoginCellSignupLabel, _yasoundLoginCellSignupLabel.textColor, nil];
        _yasoundLoginCellSignupLabel.textColor = [UIColor whiteColor];
        
        [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(onLabelUnselected:) userInfo:data repeats:NO];
        return;
    }
}


- (void)onLabelUnselected:(NSTimer*)timer
{
    NSArray* data = timer.userInfo;
    UILabel* label = [data objectAtIndex:0];
    UIColor* color = [data objectAtIndex:1];
    label.textColor = color;
}






#pragma mark - IBActions

- (IBAction)onLoginCanceled:(id)sender
{
    [self flipToView:_loginView removeView:_yasoundLoginView fromLeft:NO];
}




@end
