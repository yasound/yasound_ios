//
//  LoginViewController_YasoundLogin.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "LoginViewController.h"



@implementation LoginViewController (YasoundLogin)


- (NSInteger)yasoundLogin_numberOfSectionsInTableView
{
    return 2;
}


- (NSInteger)yasoundLogin_numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 2;
    return 1;
}


- (UITableViewCell *)yasoundLogin_cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_yasoundLoginTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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


- (void)yasoundLogin_didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}




#pragma mark - IBActions

- (IBAction)onLoginCanceled:(id)sender
{
    [self flipToView:_loginView removeView:_yasoundLoginView fromLeft:NO];
}




@end
