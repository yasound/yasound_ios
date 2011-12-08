//
//  LoginViewController.m
//  Yasound
//
//  Created by LOIC BERTHELOT on 07/12/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}








#pragma mark - TableView Source and Delegate





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 3;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.row)
    {
        case 0: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_facebook", nil);
            [cell.imageView setImage:[UIImage imageNamed:@"loginIconFacebook.png"]];
            break;
        }
            
        case 1: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_twitter", nil);
            [cell.imageView setImage:[UIImage imageNamed:@"loginIconTwitter.png"]];
            break;
        }

        case 2: 
        {
            cell.textLabel.text = NSLocalizedString(@"login_yasound", nil);
            [cell.imageView setImage:[UIImage imageNamed:@"loginIconYasound.png"]];
            break;
        }

    }
    
    return cell;
}



- (void)didSelectInSelectionTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{
//    RadioViewController* view = [[RadioViewController alloc] init];
//    [self.navigationController pushViewController:view animated:YES];
//    [view release];
}




@end
