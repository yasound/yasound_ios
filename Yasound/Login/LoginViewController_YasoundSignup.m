//
//  LoginViewController_YasoundSignup.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "LoginViewController.h"



@implementation LoginViewController (YasoundSignup)



- (NSInteger)yasoundSignup_numberOfSectionsInTableView
{
    return 1;
}


- (NSInteger)yasoundSignup_numberOfRowsInSection:(NSInteger)section
{
    return 1;    
}


- (UITableViewCell *)yasoundSignup_cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_yasoundSignupTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {   
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.row)
    {
        case 0: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_facebook", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:[UIImage imageNamed:@"loginIconFacebook.png"]];
            break;
        }
            
        case 1: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_twitter", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:[UIImage imageNamed:@"loginIconTwitter.png"]];
            break;
        }
            
        case 2: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_yasound", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:[UIImage imageNamed:@"loginIconYasound.png"]];
            break;
        }
            
    }
    
    return cell;      
}


- (void)yasoundSignup_didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}





#pragma mark - IBActions

- (IBAction)onSignupCanceled:(id)sender
{
    [self flipToView:_loginView removeView:_yasoundSignupView fromLeft:NO];
}



@end
