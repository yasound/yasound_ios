//
//  LoginViewController_YasoundSignup.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "LoginViewController.h"

#define SECTION_LOGIN 0
#define ROW_USERNAME 0
#define ROW_PWORD 1

#define SECTION_EMAIL 1
#define ROW_EMAIL 0

#define SECTION_SUBMIT 2
#define ROW_SUBMIT 0



@implementation LoginViewController (YasoundSignup)


- (void) yasoundSignup_ViewDidLoad
{
    _yasoundSignupViewTitle.text = NSLocalizedString(@"yasoundSignup_View_title", nil);
    
}



- (NSInteger)yasoundSignup_numberOfSectionsInTableView
{
    return 3;
}


- (NSInteger)yasoundSignup_numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 2;
    
    return 1;
}


- (UITableViewCell *)yasoundSignup_cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_LOGIN) && (indexPath.row == ROW_USERNAME))
        return _yasoundLoginCellUsername;
    
    if ((indexPath.section == SECTION_LOGIN) && (indexPath.row == ROW_PWORD))
        return _yasoundLoginCellPword;
    
    if ((indexPath.section == SECTION_EMAIL) && (indexPath.row == ROW_EMAIL))
        return _yasoundSignupCellEmail;

    if ((indexPath.section == SECTION_SUBMIT) && (indexPath.row == ROW_SUBMIT))
    {
        _yasoundLoginCellSubmitLabel.text = NSLocalizedString(@"yasoundSignup_Submit_label", nil);
        return _yasoundLoginCellSubmit;
    }
    
    
    return nil;
}


- (void)yasoundSignup_didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_SUBMIT) && (indexPath.row == ROW_SUBMIT))
    {
    }    
    
}







#pragma mark - IBActions

- (IBAction)onSignupCanceled:(id)sender
{
    [self flipToView:_loginView removeView:_yasoundSignupView fromLeft:NO];
}




@end
