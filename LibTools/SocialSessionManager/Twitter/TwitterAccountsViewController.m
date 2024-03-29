//
//  TwitterAccountsViewController.m
//  testFBConnect_And_TwitterConnect
//
//  Created by LOIC BERTHELOT on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterAccountsViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "YasoundAppDelegate.h"


@implementation TwitterAccountsViewController


@synthesize delegate = _delegate;
@synthesize accounts = _accounts; 



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil accounts:(NSArray*)accounts target:(id)target
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) 
  {
    self.title = @"login using Twitter";
    self.delegate = target;
    
    self.accounts = accounts;
  }
  return self;
}


- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
}



#pragma mark - IBActions

- (IBAction)onCloseClicked:(id)sender
{
  [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
}





#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  // Configure the cell...
  ACAccount *account = [self.accounts objectAtIndex:[indexPath row]];
  cell.textLabel.text = account.username;
  cell.detailTextLabel.text = account.accountDescription;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
  TWRequest *fetchAdvancedUserProperties = [[TWRequest alloc] 
                                            initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/users/show.json"] 
                                            parameters:[NSDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil]
                                            requestMethod:TWRequestMethodGET];
  
  [fetchAdvancedUserProperties performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
  {
    if ([urlResponse statusCode] == 200) 
    {
      dispatch_sync(dispatch_get_main_queue(), ^
      {
        NSError *error;
        id userInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        cell.textLabel.text = [userInfo valueForKey:@"name"];
        
      });
    }
  }];
  
  TWRequest *fetchUserImageRequest = [[TWRequest alloc] 
                                      initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image/%@", account.username]] 
                                      parameters:nil
                                      requestMethod:TWRequestMethodGET];
  [fetchUserImageRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
  {
    if ([urlResponse statusCode] == 200) 
    {
      UIImage *image = [UIImage imageWithData:responseData];
      dispatch_sync(dispatch_get_main_queue(), ^
      {
        cell.imageView.image = image;
        [cell setNeedsLayout];
      });
    }
  }];
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  ACAccount* account = [self.accounts objectAtIndex:[indexPath row]];
  
  [self.delegate twitterDidSelectAccount:account];

  [APPDELEGATE.navigationController dismissModalViewControllerAnimated:YES];
}

@end
